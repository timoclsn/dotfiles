#!/usr/bin/env bun
// Creates a sibling git worktree and makes it ready to work in, so the
// `worktree` skill only has to pick names and hand over the task.
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
// came from. It finally opens a detached tmux session whose Claude session
// starts on `--task`, and prints a JSON summary to stdout (progress goes to
// stderr).

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
const hasOrigin = await succeeds($`git -C ${mainRoot} remote get-url origin`);

if (existsSync(worktreePath)) fail(`${worktreePath} already exists`);
if (newBranch && (await succeeds($`git -C ${mainRoot} show-ref --verify refs/heads/${newBranch}`)))
  fail(`branch ${newBranch} already exists`);

const readDefaultBranch = async () => {
  const head = await $`git -C ${mainRoot} symbolic-ref --short refs/remotes/origin/HEAD`.nothrow().quiet();
  if (head.exitCode === 0) return head.text().trim().replace(/^origin\//, "");
  return (await succeeds($`git -C ${mainRoot} show-ref --verify refs/heads/main`)) ? "main" : "master";
};

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

// --- Create the worktree -----------------------------------------------------

// A PR worktree only starts at HEAD until gh checks out the PR's branch, so it
// needs no fetched base.
const baseRef = args.pr ? "HEAD" : await resolveBase(args.base ?? (await readDefaultBranch()));

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

const branch = (await $`git -C ${worktreePath} branch --show-current`.text()).trim();

// --- Carry over gitignored files ---------------------------------------------

// A PR branch can't be checked out twice, so its source is always the main checkout.
const findSourceCheckout = async () => {
  if (args.pr) return mainRoot;
  const baseBranch = baseRef.replace(/^origin\//, "");
  const porcelain = await $`git -C ${mainRoot} worktree list --porcelain`.text();
  const checkout = porcelain
    .split("\n\n")
    .map((block) => ({
      path: block.match(/^worktree (.+)$/m)?.[1],
      branch: block.match(/^branch refs\/heads\/(.+)$/m)?.[1],
    }))
    .find((entry) => entry.branch === baseBranch && entry.path !== worktreePath);
  return checkout?.path ?? mainRoot;
};

const sourceRoot = await findSourceCheckout();

// `--directory` collapses fully ignored directories into one entry. It also
// lists untracked directories that merely contain ignored paths (e.g. `.claude/`
// next to `.claude/settings.local.json`), so only the innermost entries are the
// actually ignored ones.
const listIgnoredPaths = async () => {
  const output = await $`git -C ${sourceRoot} ls-files --others --ignored --exclude-standard --directory`.text();
  const paths = output.split("\n").filter(Boolean);
  return paths.filter((path) => !paths.some((other) => other !== path && path.endsWith("/") && other.startsWith(path)));
};

const libc = dlopen("libSystem.B.dylib", {
  clonefile: { args: [FFIType.ptr, FFIType.ptr, FFIType.u32], returns: FFIType.i32 },
});
const CLONE_NOFOLLOW = 1;
const cString = (value: string) => Buffer.from(`${value}\0`);

// One clonefile call clones a whole directory tree, several times faster than
// `cp -c -R`, which clones file by file. Falls back to cp when cloning isn't
// possible, e.g. across volumes.
const cloneInto = async (from: string, to: string) => {
  const fromPath = cString(from);
  const toPath = cString(to);
  if (libc.symbols.clonefile(ptr(fromPath), ptr(toPath), CLONE_NOFOLLOW) === 0) return;
  await $`cp -R ${from} ${to}`.quiet();
};

const matchesAny = (patterns: Bun.Glob[], path: string) =>
  patterns.some((pattern) => pattern.match(path) || pattern.match(basename(path)));

const carriedOver = { linked: [] as string[], cloned: [] as string[] };

for (const entry of await listIgnoredPaths()) {
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

  if (matchesAny(CLONED_PATTERNS, relativePath)) {
    mkdirSync(dirname(to), { recursive: true });
    await cloneInto(from, to);
    carriedOver.cloned.push(relativePath);
  }
}

log(
  `linked ${carriedOver.linked.length}, cloned ${carriedOver.cloned.length} ignored paths from ${sourceRoot}`,
);

// --- Reconcile dependencies --------------------------------------------------

// The copied node_modules match the source checkout's lockfiles, so only
// install where the new branch's lockfile is different.
const lockfiles = (await $`git -C ${worktreePath} ls-files`.text())
  .split("\n")
  .filter((path) => basename(path) in INSTALL_COMMANDS);

const isLockfileUnchanged = (lockfile: string) => {
  const sourceLockfile = join(sourceRoot, lockfile);
  return (
    existsSync(sourceLockfile) &&
    existsSync(join(worktreePath, dirname(lockfile), "node_modules")) &&
    readFileSync(sourceLockfile).equals(readFileSync(join(worktreePath, lockfile)))
  );
};

const installedIn: string[] = [];

for (const lockfile of lockfiles.filter((path) => !isLockfileUnchanged(path))) {
  const directory = dirname(lockfile);
  log(`${lockfile} differs from ${sourceRoot}, installing`);
  await $`${INSTALL_COMMANDS[basename(lockfile)]}`.cwd(join(worktreePath, directory)).quiet();
  installedIn.push(directory);
}

// --- Open the tmux session ---------------------------------------------------

const tmuxSession = (
  await $`tmux-sessionizer --detach ${args.task ? ["--prompt", args.task] : []} ${worktreePath}`.text()
).trim();

console.log(
  JSON.stringify(
    {
      path: worktreePath,
      branch,
      base: baseRef,
      source: sourceRoot,
      tmuxSession,
      linked: carriedOver.linked,
      cloned: carriedOver.cloned,
      installedIn,
    },
    null,
    2,
  ),
);
