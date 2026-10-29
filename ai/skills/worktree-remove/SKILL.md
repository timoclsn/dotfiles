---
name: worktree-remove
description: Undo the `worktree` skill — delete a git worktree, its local branch, and the tmux/Rex session opened on it. Refuses and asks the user first when uncommitted changes or unpushed commits would be lost. Works from inside the worktree's own session (removes that one) or from elsewhere given a name. Use when the user invokes `/worktree-remove`, or says they're done with a worktree, or asks to delete, remove, clean up, or close a worktree or its session.
argument-hint: "[worktree to remove: slug, folder name, branch, or path (optional; defaults to the current worktree)]"
---

# Remove a worktree

Undo what the `worktree` skill set up: the sibling worktree folder, its local branch, and the tmux and Rex sessions opened on it. The remote branch and any PR are left alone.

The bundled script `${CLAUDE_SKILL_DIR}/scripts/worktree-remove.ts` (`scripts/worktree-remove.ts` in this skill's directory) does the removal. It checks for work that would be lost before it deletes anything. Run it directly in this session; don't delegate to a subagent.

## Steps

1. **Pick the target.**
   - No argument: the worktree this session runs in. If the current directory is the main checkout and not a worktree, list the repo's worktrees (`git worktree list`) and ask which one to remove.
   - An argument: pass it as `--target`. The script accepts the slug (`auth-refactor`), the folder name (`repo-w-auth-refactor`), the branch, or a path starting with `/` or `.`. If you're not inside the worktree's repo, pass a path, e.g. `../<repo>-w-<slug>` next to the repo you're in.

2. **Run the script**, without `--discard`:
   ```sh
   ${CLAUDE_SKILL_DIR}/scripts/worktree-remove.ts [--target <name>]
   ```
   It prints a JSON summary to stdout and its progress to stderr.

3. **If it exits 2 (`"removed": false`)**, nothing was deleted, because work would be lost:
   - `uncommitted`: modified, staged, or untracked files (in `git status --porcelain` format)
   - `unpushed`: commits that are on no remote branch, on no other local branch, and not part of a merged PR

   Show the user what's at risk in a few lines, then ask with `AskUserQuestion` what to do. Offer:
   - **Keep it**: stop here and leave everything as it is (recommended).
   - **Save, then remove**: commit the changes and push the branch, or whatever subset the user names, then run the script again without `--discard`.
   - **Discard and remove**: run the script again with `--discard`.

   Never pass `--discard` without the user explicitly choosing it.

4. **Report the result** in one line: the folder and branch that were removed, and the sessions that were closed. If the script ran inside the session it closed, the session ends before you can reply. That's expected.

## Notes

- Ignored files (`node_modules`, `.env*`) don't count as lost work. The `worktree` skill only cloned or symlinked them from another checkout.
- The branch is deleted with `-D`. That's safe here, since the check above already covers unmerged commits, and it also deletes branches whose PR was squash-merged. Commits made after the PR merged still count as unpushed.
- Sessions are matched by name. Both sessionizers name a session after the worktree folder (tmux replaces `.` with `_`). The script closes whichever sessions exist, in tmux, Rex, or both.
