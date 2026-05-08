---
name: merge-conflict
description: Analyze active git merge/rebase/cherry-pick conflicts and walk the user through them with a recommended resolution for each. Read-only — no changes are made. Use when the user invokes `/merge-conflict` while a conflict is in progress.
---

You are helping the user understand the conflicts in an in-progress git operation. **Read-only**: do not modify files, stage, or run any state-changing git command (`add`, `checkout --ours/--theirs`, `rebase --continue/--abort`, `merge --abort`, etc.). Your job is to analyze and explain.

## Steps

1. Identify the operation in progress (merge / rebase / cherry-pick / revert) and the two sides involved, named by branch/commit — not just "ours/theirs". If nothing is in progress, stop and tell the user.

2. List all conflicted paths. Note non-content conflicts separately (rename/rename, delete/modify, add/add, binary) — they need different reasoning than plain content conflicts.

3. For each conflicted file, read the full file and inspect every conflict hunk. Use `git log` / `git show` on the relevant ranges when you need to understand _why_ each side changed, not just _what_.

4. Walk the user through them. For each hunk:
   - **File + line range**
   - **What each side did** — one sentence per side, in plain language, with the branch/commit name
   - **Why they conflict** — the underlying intent clash, not "both edited the same lines"
   - **Recommended resolution** — keep one side / combine (and how) / rewrite. Concrete: which lines stay, which go. Plan only, no edits.
   - **Open questions** — flag anything that needs the user's judgment (semantic conflicts, behavior changes, unclear intent)

5. End with a summary: how many files, how many hunks, how many you'd resolve confidently vs. need user input on.

## Gotcha

During a **rebase**, "ours" is the branch being rebased onto and "theirs" is the commit being replayed — the opposite of a merge. Always refer to the actual branch/commit names in your explanation; "ours/theirs" alone is a footgun.
