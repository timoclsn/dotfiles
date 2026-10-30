#!/usr/bin/env bun
// Creates a sibling git worktree and makes it ready to work in, so the
// `session` skill only has to pick names and hand over the task.
//
//   worktree-create.ts --name <slug> --branch <branch> [--base <ref>] [--task <prompt>]
//   worktree-create.ts --name <slug> --pr <number|url> [--task <prompt>]
//
// Run it from anywhere inside the repo. It creates the worktree at
// `<parent of main checkout>/<repo>-w-<slug>`, then carries over the gitignored
// files matching an allowlist from the checkout of the base branch (the main
// checkout if the base isn't checked out anywhere). Env files are symlinked so
// they stay in sync; node_modules is cloned with APFS copy-on-write, which takes
// seconds and uses no extra disk space until a file changes. Dependencies are
// only installed where a lockfile differs from the one the copied node_modules
// came from. It finally opens a tmux or Rex session, matching the terminal it
// runs in, without switching to it, whose Claude session starts on `--task`, and prints a JSON summary to stdout (progress goes to
// stderr).
//
// To be fast, everything that doesn't depend on something else runs at the same
// time: the lookups before the worktree exists, listing the files to carry over
// while the base is fetched, and finally opening the session while node_modules
// is cloned and dependencies are installed. The symlinked files (.env*, local
// Claude settings) are in place before the session opens, because Claude reads
// them on startup.

import { $ } from "bun";
import { dlopen, FFIType, ptr } from "bun:ffi";
import { existsSync, mkdirSync, readFileSync, realpathSync, symlinkSync } from "node:fs";
import { basename, dirname, join, resolve } from "node:path";
import { parseArgs } from "node:util";

// Which gitignored paths are carried over into the new worktree, like VS Code's
// `git.worktreeIncludeFiles`. A pattern without a `/` matches the file or folder
// name at any depth, one with a `/` the path from the repo root. Everything else
// that's ignored (build outputs, caches, virtualenvs) is left behind.
const LINKED_PATTERNS = [".env*", "config/local*.json", ".claude/settings.local.json"].map(
  (pattern) => new Bun.Glob(pattern),
);
const CLONED_PATTERNS = ["node_modules"].map((pattern) => new Bun.Glob(pattern));

const INSTALL_COMMANDS: Record<string, string[]> = {
  "package-lock.json": ["npm", "install"],
  "pnpm-lock.yaml": ["pnpm", "install"],
  "yarn.lock": ["yarn", "install"],
  "bun.lock": ["bun", "install"],
  "bun.lockb": ["bun", "install"],
};

const log = (message: string) => console.error(`worktree-create: ${message}`);

const fail = (message: string): never => {
  log(message);
  process.exit(1);
};

const { values: args } = parseArgs({
  options: {
    name: { type: "string" },
    branch: { type: "string" },
    base: { type: "string" },
    pr: { type: "string" },
    task: { type: "string" },
  },
});

const name = args.name ?? fail("--name is required");
const newBranch = args.pr ? undefined : (args.branch ?? fail("--branch is required unless --pr is given"));

const succeeds = async (command: ReturnType<typeof $>) => (await command.nothrow().quiet()).exitCode === 0;

// --- Locate the repo ---------------------------------------------------------

// Anchor on the main checkout so running this from inside another worktree
// still names the new one after the repo, not after that worktree.
const commonDir = resolve((await $`git rev-parse --git-common-dir`.text()).trim());
const mainRoot = dirname(commonDir);
const repoName = basename(mainRoot);
const worktreePath = join(dirname(mainRoot), `${repoName}-w-${name}`);

const readDefaultBranch = async () => {
  const head = await $`git -C ${mainRoot} symbolic-ref --short refs/remotes/origin/HEAD`.nothrow().quiet();
  if (head.exitCode === 0) return head.text().trim().replace(/^origin\//, "");
  return (await succeeds($`git -C ${mainRoot} show-ref --verify refs/heads/main`)) ? "main" : "master";
};

const [hasOrigin, branchExists, baseName] = await Promise.all([
  succeeds($`git -C ${mainRoot} remote get-url origin`),
  newBranch ? succeeds($`git -C ${mainRoot} show-ref --verify refs/heads/${newBranch}`) : false,
  args.pr ? undefined : (args.base ?? readDefaultBranch()),
]);

if (existsSync(worktreePath)) fail(`${worktreePath} already exists`);
if (branchExists) fail(`branch ${newBranch} already exists`);

const isCommit = (ref: string) => succeeds($`git -C ${mainRoot} rev-parse --verify ${`${ref}^{commit}`}`);

// Prefer the freshly fetched remote branch, fall back to a local branch or tag.
const resolveBase = async (ref: string) => {
  if (hasOrigin) {
    await $`git -C ${mainRoot} fetch origin ${ref}`.nothrow().quiet();
    if (await isCommit(`origin/${ref}`)) return `origin/${ref}`;
  }
  if (await isCommit(ref)) return ref;
  return fail(`base ${ref} not found`);
};

// --- Find the files to carry over (runs while the worktree is created) -------

// A PR branch can't be checked out twice, so its source is always the main checkout.
const findSourceCheckout = async () => {
  if (!baseName) return mainRoot;
  const baseBranch = baseName.replace(/^origin\//, "");
  const porcelain = await $`git -C ${mainRoot} worktree list --porcelain`.text();
  const checkout = porcelain
    .split("\n\n")
    .map((block) => ({
      path: block.match(/^worktree (.+)$/m)?.[1],
      branch: block.match(/^branch refs\/heads\/(.+)$/m)?.[1],
    }))
    .find((entry) => entry.branch === baseBranch);
  return checkout?.path ?? mainRoot;
};

// `--directory` collapses fully ignored directories into one entry. It also
// lists untracked directories that merely contain ignored paths (e.g. `.claude/`
// next to `.claude/settings.local.json`), so only the innermost entries are the
// actually ignored ones.
const listIgnoredPaths = async (sourceRoot: string) => {
  const output = await $`git -C ${sourceRoot} ls-files --others --ignored --exclude-standard --directory`.text();
  const paths = output.split("\n").filter(Boolean);
  return paths.filter((path) => !paths.some((other) => other !== path && path.endsWith("/") && other.startsWith(path)));
};

const findCarryOver = async () => {
  const sourceRoot = await findSourceCheckout();
  return { sourceRoot, ignoredPaths: await listIgnoredPaths(sourceRoot) };
};

// --- Create the worktree -----------------------------------------------------

const createWorktree = async () => {
  // A PR worktree only starts at HEAD until gh checks out the PR's branch, so it
  // needs no fetched base.
  const baseRef = baseName ? await resolveBase(baseName) : "HEAD";

  if (newBranch) {
    log(`creating ${worktreePath} on ${newBranch} off ${baseRef}`);
    await $`git -C ${mainRoot} worktree add -b ${newBranch} ${worktreePath} ${baseRef}`.quiet();
  } else {
    // Start detached and let gh check out the PR's own branch, which also
    // handles PRs from forks.
    log(`creating ${worktreePath} for PR ${args.pr}`);
    await $`git -C ${mainRoot} worktree add --detach ${worktreePath} ${baseRef}`.quiet();
    await $`gh pr checkout ${args.pr}`.cwd(worktreePath).quiet();
  }

  const branch = newBranch ?? (await $`git -C ${worktreePath} branch --show-current`.text()).trim();
  return { baseRef, branch };
};

const [{ sourceRoot, ignoredPaths }, { baseRef, branch }] = await Promise.all([findCarryOver(), createWorktree()]);

// --- Carry over gitignored files ---------------------------------------------

const matchesAny = (patterns: Bun.Glob[], path: string) =>
  patterns.some((pattern) => pattern.match(path) || pattern.match(basename(path)));

const carriedOver = { linked: [] as string[], cloned: [] as string[] };

for (const entry of ignoredPaths) {
  const relativePath = entry.replace(/\/$/, "");
  const from = join(sourceRoot, relativePath);
  const to = join(worktreePath, relativePath);

  if (existsSync(to)) continue;

  if (matchesAny(LINKED_PATTERNS, relativePath)) {
    mkdirSync(dirname(to), { recursive: true });
    symlinkSync(realpathSync(from), to);
    carriedOver.linked.push(relativePath);
    continue;
  }

  if (matchesAny(CLONED_PATTERNS, relativePath)) carriedOver.cloned.push(relativePath);
}

log(
  `linking ${carriedOver.linked.length}, cloning ${carriedOver.cloned.length} ignored paths from ${sourceRoot}`,
);

// --- Work out which dependencies need installing -----------------------------

// The copied node_modules match the source checkout's lockfiles, so only
// install where the new branch's lockfile is different.
const lockfiles = (await $`git -C ${worktreePath} ls-files`.text())
  .split("\n")
  .filter((path) => basename(path) in INSTALL_COMMANDS);

const isLockfileUnchanged = (lockfile: string) => {
  const sourceLockfile = join(sourceRoot, lockfile);
  const modules = join(dirname(lockfile), "node_modules");
  return (
    existsSync(sourceLockfile) &&
    (carriedOver.cloned.includes(modules) || existsSync(join(worktreePath, modules))) &&
    readFileSync(sourceLockfile).equals(readFileSync(join(worktreePath, lockfile)))
  );
};

const staleLockfiles = lockfiles.filter((lockfile) => !isLockfileUnchanged(lockfile));

// --- Open the session and set up dependencies at the same time ---------------

// tmux sets TMUX in its panes and Rex sets REX_SESSION in its terminals. tmux
// wins when both are set, since it then runs inside a Rex terminal.
const sessionizer = !process.env.TMUX && process.env.REX_SESSION ? "rex-sessionizer" : "tmux-sessionizer";

// Claude can start working before node_modules is in place, so say so in its first message.
const isSettingUpDependencies = carriedOver.cloned.length > 0 || staleLockfiles.length > 0;
const task =
  args.task && isSettingUpDependencies
    ? `${args.task}\n\n(Dependencies are still being set up in the background. If a command fails because of missing modules, wait a moment and retry.)`
    : args.task;

// One clonefile call clones a whole directory tree, several times faster than
// `cp -c -R`, which clones file by file. Falls back to cp when cloning isn't
// possible, e.g. across volumes.
const libc = dlopen("libSystem.B.dylib", {
  clonefile: { args: [FFIType.ptr, FFIType.ptr, FFIType.u32], returns: FFIType.i32 },
});
const CLONE_NOFOLLOW = 1;
const cString = (value: string) => Buffer.from(`${value}\0`);

const cloneInto = async (from: string, to: string) => {
  const fromPath = cString(from);
  const toPath = cString(to);
  if (libc.symbols.clonefile(ptr(fromPath), ptr(toPath), CLONE_NOFOLLOW) === 0) return;
  await $`cp -R ${from} ${to}`.quiet();
};

const setUpDependencies = async () => {
  for (const relativePath of carriedOver.cloned) {
    const to = join(worktreePath, relativePath);
    mkdirSync(dirname(to), { recursive: true });
    await cloneInto(join(sourceRoot, relativePath), to);
  }

  return Promise.all(
    staleLockfiles.map(async (lockfile) => {
      const directory = dirname(lockfile);
      log(`${lockfile} differs from ${sourceRoot}, installing`);
      await $`${INSTALL_COMMANDS[basename(lockfile)]}`.cwd(join(worktreePath, directory)).quiet();
      return directory;
    }),
  );
};

// The body runs up to its first await right away, so the session is already
// opening while the (blocking) clones below run.
const sessionOpened = (async () => {
  const child = Bun.spawn([sessionizer, "--detach", ...(task ? ["--prompt", task] : []), worktreePath], {
    stdout: "pipe",
    stderr: "inherit",
  });
  const [output, exitCode] = await Promise.all([new Response(child.stdout).text(), child.exited]);
  if (exitCode !== 0) throw new Error(`${sessionizer} exited with ${exitCode}`);
  return output.trim();
})();
const dependenciesReady = setUpDependencies();

// Let both finish before reporting a failure, so a failed install doesn't
// cut off the session that is still opening.
const outcomes = await Promise.allSettled([sessionOpened, dependenciesReady]);
const failure = outcomes.find((outcome) => outcome.status === "rejected");
if (failure) throw failure.reason;

const [session, installedIn] = await Promise.all([sessionOpened, dependenciesReady]);

console.log(
  JSON.stringify(
    {
      path: worktreePath,
      branch,
      base: baseRef,
      source: sourceRoot,
      session,
      linked: carriedOver.linked,
      cloned: carriedOver.cloned,
      installedIn,
    },
    null,
    2,
  ),
);
