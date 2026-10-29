#!/usr/bin/env bun
// Removes a worktree made by the `worktree` skill: the worktree folder, its
// local branch, and the tmux and Rex sessions opened on it.
//
//   worktree-remove.ts [--target <slug|folder name|branch|path>] [--discard]
//
// Without --target it removes the worktree it runs in. Before deleting anything
// it checks for work that would be lost: uncommitted or untracked changes, and
// commits that are on no other branch and not in a merged PR. If it finds any,
// it deletes nothing, prints them as JSON with `"removed": false` and exits 2.
// --discard skips that check. The sessions are closed last, since this script
// may run inside one of them; the JSON summary is printed before that.

import { $ } from "bun";
import { existsSync, realpathSync } from "node:fs";
import { basename } from "node:path";
import { parseArgs } from "node:util";

const log = (message: string) => console.error(`worktree-remove: ${message}`);

const fail = (message: string): never => {
  log(message);
  process.exit(1);
};

const print = (summary: object) => console.log(JSON.stringify(summary, null, 2));

const { values: args } = parseArgs({
  options: {
    target: { type: "string" },
    discard: { type: "boolean", default: false },
  },
});

const succeeds = async (command: ReturnType<typeof $>) => (await command.nothrow().quiet()).exitCode === 0;

const lines = (text: string) => text.split("\n").filter(Boolean);

// --- Find the worktree -------------------------------------------------------

const { target } = args;
// A path given as target can point into a repo other than the current one.
// Only explicit paths count, so a slug that happens to name a folder here
// isn't mistaken for one.
const isPath = target !== undefined && /^[./]/.test(target) && existsSync(target);
const targetPath = isPath ? realpathSync(target) : undefined;
const lookupDir = targetPath ?? process.cwd();

const worktreeList = await $`git -C ${lookupDir} worktree list --porcelain`
  .text()
  .catch(() => fail(`${lookupDir} is not in a git repo`));
const worktrees = worktreeList.split("\n\n").map((block) => ({
  path: block.match(/^worktree (.+)$/m)?.[1] ?? "",
  branch: block.match(/^branch refs\/heads\/(.+)$/m)?.[1],
}));
// git lists the main checkout first.
const mainRoot = worktrees[0].path;
const repoName = basename(mainRoot);

const findTarget = (name: string) => {
  const matches = worktrees.filter(
    (worktree) =>
      worktree.path === targetPath ||
      basename(worktree.path) === name ||
      basename(worktree.path) === `${repoName}-w-${name}` ||
      worktree.branch === name,
  );
  if (matches.length > 1) fail(`${name} matches several worktrees: ${matches.map((match) => match.path).join(", ")}`);
  return matches[0] ?? fail(`no worktree of ${repoName} matches ${name}`);
};

const findCurrent = async () => {
  const currentRoot = (await $`git -C ${lookupDir} rev-parse --show-toplevel`.text()).trim();
  return worktrees.find((worktree) => worktree.path === currentRoot) ?? fail(`${currentRoot} is not a worktree`);
};

const worktree = target ? findTarget(target) : await findCurrent();

if (worktree.path === mainRoot) fail(`${worktree.path} is the main checkout, not a worktree`);

// --- Check for work that would be lost ---------------------------------------

// Commits that only exist on this branch: on no remote branch and no other
// local branch, and in none of the given commits (merged PR heads).
const listOwnCommits = async (alsoExclude: string[] = []) => {
  const ownBranch = worktree.branch ? [`--exclude=${worktree.branch}`] : [];
  return lines(
    await $`git -C ${worktree.path} log --oneline HEAD --not --remotes ${ownBranch} --branches ${alsoExclude}`.text(),
  );
};

// A squash- or rebase-merged PR leaves its commits off the base branch, even
// though their changes landed there. Only the commits up to the PR's merged
// head are safe; anything committed on top of it afterwards is not.
const listMergedPrHeads = async () => {
  if (!worktree.branch) return [];
  const prs = await $`gh pr list --head ${worktree.branch} --state merged --json headRefOid --jq .[].headRefOid`
    .cwd(worktree.path)
    .nothrow()
    .quiet();
  if (prs.exitCode !== 0) return [];
  const heads = await Promise.all(
    lines(prs.text()).map(async (head) =>
      (await succeeds($`git -C ${worktree.path} cat-file -e ${`${head}^{commit}`}`)) ? [head] : [],
    ),
  );
  return heads.flat();
};

const [uncommitted, ownCommits] = await Promise.all([
  // Ignored files are left out: the worktree skill only symlinks or clones them
  // from another checkout, so they exist elsewhere too.
  $`git -C ${worktree.path} status --porcelain`.text().then(lines),
  listOwnCommits(),
]);

const unpushed =
  ownCommits.length > 0 && !args.discard ? await listOwnCommits(await listMergedPrHeads()) : ownCommits;
const location = { path: worktree.path, branch: worktree.branch };

if (!args.discard && (uncommitted.length > 0 || unpushed.length > 0)) {
  print({ removed: false, ...location, uncommitted, unpushed });
  process.exit(2);
}

// --- Remove the worktree and its branch --------------------------------------

// The sessionizers name a session after the folder; tmux can't have dots in it.
const folderName = basename(worktree.path);
const tmuxSession = folderName.replaceAll(".", "_");

const findRexSession = async () => {
  const result = await $`rex ls --json --autostart=false`.nothrow().quiet();
  if (result.exitCode !== 0) return undefined;
  const sessions: { session_id: string; label: string }[] = result.json().sessions ?? [];
  return sessions.find((session) => session.label === folderName);
};

// Look the sessions up before deleting anything, so a failing lookup can't
// leave the worktree half removed.
const [hasTmuxSession, rexSession] = await Promise.all([
  succeeds($`tmux has-session -t=${tmuxSession}`),
  findRexSession(),
]);

// This script may run inside the worktree; commands can't start from a deleted
// directory.
process.chdir(mainRoot);

log(`removing ${worktree.path}`);
await $`git worktree remove --force ${worktree.path}`.quiet();
if (worktree.branch) {
  log(`deleting branch ${worktree.branch}`);
  await $`git branch -D ${worktree.branch}`.quiet();
}

print({
  removed: true,
  ...location,
  discarded: { uncommitted, unpushed },
  closedSessions: { tmux: hasTmuxSession ? tmuxSession : undefined, rex: rexSession?.label },
});

// --- Close the sessions ------------------------------------------------------

const closeTmux = async () => hasTmuxSession && (await $`tmux kill-session -t=${tmuxSession}`.nothrow().quiet());
const closeRex = async () => rexSession && (await $`rex kill ${rexSession.session_id}`.nothrow().quiet());

// Close the session this script runs in last, since that ends the script.
const runsInRexSession = rexSession !== undefined && process.env.REX_SESSION === rexSession.session_id;
for (const close of runsInRexSession ? [closeTmux, closeRex] : [closeRex, closeTmux]) await close();
