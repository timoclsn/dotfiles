#!/usr/bin/env bun
// Finds the worktrees made by the `session` skill (`<repo>-w-<slug>` folders)
// across all repos and decides which are safe to remove: the branch has a
// merged PR and the worktree has no uncommitted changes.
//
//   clean-sessions.ts            only report what would be removed
//   clean-sessions.ts --remove   also remove those, via session-remove's script
//
// Prints a JSON array to stdout. Each entry has `path`, `branch` and either
// `remove: true`, or `remove: false` with a `reason`. With --remove, entries
// that were removed also carry `removed: true` plus what was closed, and ones
// that session-remove refused (commits made after the PR merged) get a reason.

import { $ } from "bun";
import { existsSync, readFileSync, readdirSync, realpathSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { parseArgs } from "node:util";

const { values: args } = parseArgs({ options: { remove: { type: "boolean", default: false } } });

const lines = (text: string) => text.split("\n").filter(Boolean);

// The project roots live in the sessionizer script next to this skill's
// directory in the dotfiles repo, so they are defined in one place only.
const scriptDir = realpathSync(import.meta.dir);
const sessionizer = join(scriptDir, "../../../../scripts/rex-sessionizer");
const roots = (readFileSync(sessionizer, "utf8").match(/^dirs=\(\n([\s\S]*?)\n\)/m)?.[1] ?? "")
  .split("\n")
  .map((line) => line.trim().replace(/^~/, homedir()).replaceAll("\\ ", " "))
  .filter(Boolean);
if (roots.length === 0) throw new Error(`no project roots found in ${sessionizer}`);

// PR lookups must run as the personal account; another account can't see these
// repos' PRs and would report every worktree as unmerged.
const ghUser = (await $`gh api user --jq .login`.nothrow().quiet().text()).trim();
if (ghUser !== "timoclsn") throw new Error(`gh runs as "${ghUser}", run: gh auth switch --user timoclsn`);

// A repo outside the roots can still be cleaned up when run from inside it.
const [currentTopPath, currentCommonDir] = lines(
  await $`git rev-parse --path-format=absolute --show-toplevel --git-common-dir`.nothrow().quiet().text(),
);
const currentTop = currentTopPath && realpathSync(currentTopPath);
const currentRepoParent = currentCommonDir && dirname(dirname(currentCommonDir));
const searchRoots = [...new Set([...roots, currentRepoParent])].filter(existsSync);

const folders = searchRoots.flatMap((root) =>
  readdirSync(root, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && entry.name.includes("-w-"))
    .map((entry) => join(root, entry.name)),
);

const inspect = async (path: string) => {
  // Folders left behind by dev servers (.next, .vite) have no .git.
  if (!existsSync(join(path, ".git"))) return { path, remove: false, reason: "not a worktree" };
  const [gitDir, commonDir] = lines(
    await $`git -C ${path} rev-parse --path-format=absolute --git-dir --git-common-dir`.text(),
  );
  if (gitDir === commonDir) return { path, remove: false, reason: "main checkout" };
  if (realpathSync(path) === currentTop) return { path, remove: false, reason: "current session" };

  const branch = (await $`git -C ${path} branch --show-current`.text()).trim();
  if (!branch) return { path, remove: false, reason: "detached HEAD" };

  const [uncommitted, pr] = await Promise.all([
    $`git -C ${path} status --porcelain`.text().then(lines),
    $`gh pr list --head ${branch} --state merged --json number --jq length`.cwd(path).nothrow().quiet(),
  ]);
  if (pr.exitCode !== 0) return { path, branch, remove: false, reason: "gh failed; merge can't be verified" };

  if (Number(pr.text()) === 0) return { path, branch, remove: false, reason: "no merged PR" };
  if (uncommitted.length > 0) return { path, branch, remove: false, reason: "uncommitted changes", uncommitted };
  return { path, branch, remove: true };
};

// One broken worktree must not hide the others.
const inspectSafely = (path: string) =>
  inspect(path).catch((error: Error) => ({ path, remove: false, reason: `git failed: ${error.message}` }));

const entries = await Promise.all(folders.map(inspectSafely));

// session-remove does its own check for work that would be lost and never gets
// --discard here. Removals run one after another since they can share a repo.
const worktreeRemove = join(scriptDir, "../../session-remove/scripts/worktree-remove.ts");

const remove = async (entry: (typeof entries)[number]) => {
  const result = await $`${worktreeRemove} --target ${entry.path}`.nothrow().quiet();
  if (result.exitCode === 0) return { ...entry, removed: true, ...result.json() };
  if (result.exitCode === 2) {
    const summary = result.json();
    const reason = summary.unpushed.length > 0 ? "unpushed commits" : "uncommitted changes";
    return { ...entry, remove: false, reason, ...summary };
  }
  return { ...entry, remove: false, reason: `session-remove failed: ${result.stderr.toString().trim()}` };
};

const results: object[] = [];
for (const entry of entries) results.push(args.remove && entry.remove ? await remove(entry) : entry);

console.log(JSON.stringify(results, null, 2));
