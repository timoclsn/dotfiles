---
name: session-clean-up
description: Remove every worktree (and its session, if any) created by the `session` skill whose branch's PR has been merged and which has no local changes. Covers all repos, not just the current one. Skips worktrees with open or no PRs, uncommitted changes, or unpushed commits, and reports what it removed and kept. Use when the user invokes `/session-clean-up`, or asks to clean up, prune, or tidy finished sessions or worktrees.
---

# Clean up finished sessions

Bulk version of `session-remove`: delete every `<repo>-w-<slug>` worktree and session whose work has landed and that holds nothing worth keeping. Nothing is ever discarded; anything uncertain is left alone and reported.

One bundled script does all of it: `${CLAUDE_SKILL_DIR}/scripts/clean-sessions.ts`. It finds the worktrees in all repos (the project roots come from the sessionizer script), checks each for a merged PR and uncommitted changes, and removes the clean ones through `session-remove`'s script, which also refuses when commits would be lost. Run it directly in this session.

## Steps

1. **Run it:**
   ```sh
   ${CLAUDE_SKILL_DIR}/scripts/clean-sessions.ts --remove
   ```
   It prints a JSON array with one entry per `-w-` folder. Entries with `removed: true` were removed. All others were kept and carry a `reason`: no merged PR, uncommitted changes, unpushed commits, current session, main checkout, detached HEAD, not a worktree, or a failure (`gh failed`, `git failed`, `session-remove failed`). If every entry failed with `gh failed`, say that nothing could be verified.

2. **Report** in a short list: removed (folder and branch), and kept with a one-line reason each. Entries with reason `not a worktree` are leftover cache folders (`.next`, `.vite`) from a dev server; mention them and offer to delete them. If there were no entries, say so.

Without `--remove` the script only reports what it would remove. Use that if the user wants a preview first.

## Notes

- No confirmation is needed before removing: the criteria guarantee no lost work, and remote branches and PRs stay untouched.
- Only `-w-` folders are considered, so worktrees made by hand under other names are never touched.
