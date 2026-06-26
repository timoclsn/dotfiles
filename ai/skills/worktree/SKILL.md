---
name: worktree
description: Create a new git worktree as a sibling of the current repo, branched off the default branch (main/master) by default — or off a given branch, tag, or PR. Names it after the repo plus a semantic extension, and optionally runs a given task inside it. Use when the user invokes `/worktree`, or asks to spin up / create a worktree to work on something in isolation, on a specific branch, or to check out a PR.
argument-hint: "[base branch/tag/PR and/or task to run in the worktree (optional)]"
---

# Create a worktree

Create a fresh git worktree as a **sibling** of the current repo (one level up, not nested inside it), on a **new branch off the default branch**, then optionally carry out a task inside it.

## Steps

1. **Gather context.** Always anchor on the **main worktree** (the original repo), never the current checkout — otherwise running this from inside an existing worktree would name the new one after the worktree folder (e.g. `dotfiles-w-auth-w-feature` instead of `dotfiles-w-feature`).
   - Main repo root: the first entry of `git worktree list` is always the main checkout. Equivalently, take the parent of `git rev-parse --git-common-dir` (resolved to an absolute path), which points at the original repo regardless of which worktree you're in. Do **not** use `git rev-parse --show-toplevel` — that returns the current worktree.
   - Repo name: basename of the main repo root
   - Parent dir: the directory containing the main repo root — worktrees go here as siblings
   - Default branch: read `git symbolic-ref refs/remotes/origin/HEAD` and strip to the branch name; if that fails, use `main` if it exists, otherwise `master`

2. **Pick a semantic extension** — a short kebab-case slug describing the work (e.g. `auth-refactor`, `login-fix`, `docs`). Derive it from the task argument or the current conversation. Only ask the user if there's genuinely nothing to infer it from.
   - Worktree path: `<parent-dir>/<repo-name>-w-<extension>` (the `-w-` infix marks it as a worktree and groups it next to the repo; directory name never contains a `/`)

3. **Derive the branch name from the project's convention.** Inspect existing branches (`git branch -a`, including remotes) and match their style:
   - If they follow conventional-commit style (`feat/…`, `fix/…`, `chore/…`, `docs/…`, etc.), pick the type that fits the work and name the branch `<type>/<extension>`.
   - Mirror whatever separator/casing the existing branches actually use (e.g. `feature/…`, or a Jira-key prefix like `ABC-123-…`) rather than forcing a style the project doesn't use.
   - If there's no discernible convention, the branch name is just `<extension>`.

4. **Determine the base.** Default to the latest default branch, but honor an explicit base named in the instruction:
   - **No base given:** if the repo has a remote, `git fetch` the default branch and base off `origin/<default>`; otherwise the local default branch. Never branch off the current HEAD.
   - **A branch or tag given** (e.g. "based on `staging`"): `git fetch` it and base the new branch off that ref instead.
   - **A PR given** (e.g. "for PR 123", a `#123`, or a PR URL): resolve and check out the PR's actual head branch rather than creating a new branch off it — checking out a PR means working on *that* branch. Use the GitHub CLI (`gh pr checkout`/`gh pr view`) to get the PR's branch into a worktree; this also handles fork PRs. In this case skip the new-branch creation in step 6 and the convention naming in step 3, and derive the directory extension from the PR (e.g. its number or branch slug).

5. **Guard before creating.** Abort and propose a different extension if the target path already exists or the branch name is already taken.

6. **Create the worktree.** For new work, create it with the new branch off the base from step 4 — directory uses the plain extension, branch uses the convention-aware name from step 3:
   ```sh
   git worktree add -b <branch-name> <parent-dir>/<repo-name>-w-<extension> <base-ref>
   ```
   For a PR (step 4), instead create a worktree that checks out the PR's existing branch (no `-b`) — e.g. `git worktree add <path> <pr-branch>`, or let `gh pr checkout` populate it.
   Don't use the built-in `EnterWorktree` to *create* it — that tool nests worktrees under `.claude/worktrees/`, which violates the sibling-placement requirement. Create it with `git worktree add` so you control the location and name.

7. **Switch the session into the worktree** with the built-in tool, passing the path you just created:
   ```
   EnterWorktree({ path: "<parent-dir>/<repo-name>-w-<extension>" })
   ```
   This moves the session's working directory into the worktree (so subsequent steps and any task run there), tracks it for exit-time cleanup, and wires up tmux. Because it was entered via `path`, `ExitWorktree` will not delete it — the worktree stays put.

8. **Install dependencies** if the worktree contains a dependency manifest. Detect the package manager from its lockfile (e.g. `pnpm-lock.yaml`, `yarn.lock`, `bun.lockb`, `package-lock.json`) and run the matching install. Skip silently if there's no manifest.

9. **Report the result** — print the absolute worktree path so the user knows where the work lives.

## Running a task in the worktree

If a task/instruction was passed as the argument, carry it out now — the session is already inside the worktree after step 7, so just work normally. When done, summarize what changed and remind the user of the worktree path. To leave the worktree later, the user can use `ExitWorktree` (`keep` to preserve it, which is the safe default here).
