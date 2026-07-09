---
name: merge-conflict
description: Analyze active git merge/rebase/cherry-pick conflicts and walk the user through them with a recommended resolution for each. Read-only by default; pass `--fix` to also resolve the conflicts you're confident about. Use when the user invokes `/merge-conflict` while a conflict is in progress.
argument-hint: "[--fix]"
---

You are helping the user understand the conflicts in an in-progress git operation. By default this is **read-only**: do not modify files, stage, or run any state-changing git command (`add`, `checkout --ours/--theirs`, `rebase --continue/--abort`, `merge --abort`, etc.). Your job is to analyze and explain.

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

5. Look beyond the conflicts. A conflict is only where the two sides touched the *same* lines — but the incoming side almost always brings in changes that merged **cleanly** too, and those can still be semantically at odds with the work on this branch. Skim what the merge brought in overall (`git diff` / `git log` on the incoming side, focused on files this branch also touched) and ask whether it fits the direction of our work: renamed/removed APIs we still call, changed behavior or assumptions our code relies on, new patterns that make our approach redundant or wrong. Treat the conflicts as a signal that the two sides diverged here — the clean parts may need attention too. Flag anything you find as an open question for the user.

6. End with a summary: how many files, how many hunks, how many you'd resolve confidently vs. need user input on — plus any concerns from the clean-merge review in step 5.

## Applying fixes (`--fix`)

If `--fix` was passed, after the walkthrough fix **everything that doesn't need the user's input** directly in the working tree:

- Resolve the conflict hunks you're confident about — remove the conflict markers and write the resolution you recommended.
- Also apply the follow-up fixes surfaced by the clean-merge review in step 5 when they're unambiguous — e.g. update our call sites to a renamed/moved incoming API, remove code the incoming side made redundant, adjust to changed behavior our code relied on.

Leave anything that needs the user's judgment (semantic conflicts, unclear intent, behavior changes, design decisions) untouched — conflict markers intact where present — and list those for the user.

Edit files only. Do **not** stage (`git add`), and do **not** continue or abort the operation (`rebase --continue/--abort`, `merge --abort`, `cherry-pick --continue`) — leave that to the user. End with a clear list of what you resolved and what you left for them.

## Gotcha

During a **rebase**, "ours" is the branch being rebased onto and "theirs" is the commit being replayed — the opposite of a merge. Always refer to the actual branch/commit names in your explanation; "ours/theirs" alone is a footgun.
