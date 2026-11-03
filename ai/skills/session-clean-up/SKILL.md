---
name: session-clean-up
description: Remove every worktree (and its session, if any) created by the `session` skill whose branch's PR has been merged and which has no local changes, by running `/session-remove` on each. Covers all repos, not just the current one. Skips sessions with open or no PRs, uncommitted changes, or unpushed commits, and reports what it removed and kept. Use when the user invokes `/session-clean-up`, or asks to clean up, prune, or tidy finished sessions or worktrees.
---

# Clean up finished sessions

Bulk version of `session-remove`: delete every worktree and session whose work has landed and that holds nothing worth keeping. Nothing is ever discarded; anything uncertain is left alone and reported.

## Steps

1. **Collect candidates from every repo, not just the current one.** A session is a linked git worktree named `<repo>-w-<slug>`, a sibling of its main checkout. It may or may not still have a tmux or Rex session; the worktree alone is enough. Find them all:
   - read the project root folders from the `dirs` list in `scripts/rex-sessionizer` in the dotfiles repo (`tmux-sessionizer` has the same list), and glob each root one level deep for `*-w-*` folders
   - also glob the parent folder of the current repo, and the parent folders of the repos behind any open tmux or Rex sessions
   - keep only folders that are linked worktrees, and note the main checkout of each, which is how its repo is identified
   - also include every other linked worktree of those repos, even if it isn't named `-w-`

   Never include a main checkout. Skip the worktree this session runs in; it would end the session mid-run. Mention it as skipped if it would otherwise qualify.

2. **Check each candidate for a merged PR.** Look up PRs for the worktree's branch with `gh`, using the `timoclsn` account. Keep it only if one is merged. Open, closed-unmerged, or missing PR: keep the session. Detached HEAD: keep it.

3. **Check for local changes.** Keep it if `git status --porcelain` is non-empty. Commits made after the PR merged are also local changes, but `session-remove` catches them in step 4, so don't duplicate that check.

4. **Remove the survivors** with the `session-remove` skill, one at a time and without `--discard`. Pass a path for each so it works from any repo. If it refuses (exit 2), treat the session as kept and note why. Do not ask the user to discard; this skill only removes clean sessions.

5. **Report** in a short list: removed (folder and branch), and kept with a one-line reason each (no merged PR, uncommitted changes, unpushed commits, current session). If there were no candidates, say so.

## Notes

- Confirmation isn't needed before removing: the criteria guarantee no lost work, and remote branches and PRs stay untouched.
- If `gh` can't be reached, remove nothing and say so; without it a merge can't be verified.
