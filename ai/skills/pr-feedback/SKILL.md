---
name: pr-feedback
description: Triage review feedback — either pulled from the current branch's PR or passed directly as text — by verifying each point against the codebase and walking the user through them. Read-only by default; pass `--fix` to also apply the points you're confident about. Use when the user invokes `/pr-feedback` (optionally with feedback text) before deciding what to act on.
argument-hint: "[feedback text (optional)] [--fix]"
---

You are triaging review feedback. By default this is **read-only**: do not edit files, push, or reply to comments. Your job is to gather, verify, and explain.

If the arguments below contain `--fix`, strip that flag out (it is not feedback text) and follow the "Applying fixes" section after the walkthrough.

## Feedback

$ARGUMENTS

## Steps

1. **Source the feedback.**
   - If the **Feedback** section above contains text, treat that as the complete feedback to triage. Do **not** fetch the PR. Parse it into individual points (one per concern, even if the user wrote it as a paragraph).
   - If the **Feedback** section is empty, find the PR for the current branch and pull all review feedback (inline review comments, top-level reviews, and issue-style PR comments). Skip resolved/outdated threads unless asked.

2. **Verify each point adversarially against the current code.** Don't reflexively trust the comment — a reviewer can be wrong, out of date, or misreading. For each point, actively try to _refute_ it: is the referenced line stale or moved (find the code at HEAD)? Was it already addressed? Did the reviewer misread the code? Is it valid in general but not in this context? Accept the point only if it survives that scrutiny.

3. **Walk the user through them.** For each point:
   - **Source** — reviewer + file:line for PR comments; just file:line (or "general") for local feedback
   - **Comment** — short paraphrase, or quote if short
   - **Verdict** — valid / partially valid / invalid / already addressed / out-of-date, with a one-line reason grounded in what you read
   - **Suggested fix** (if valid) — concretely what you would change. Plan only, no edits.

   Group by file or reviewer, whichever scans easier. Trivial valid points can be one line.

4. **End with a summary**: total points, how many valid, how many you'd act on, anything needing the user's judgment.

## Applying fixes (`--fix`)

If `--fix` was passed, after the walkthrough apply only the points that **survived refutation in step 2** and have a concrete, unambiguous fix. The bar is higher here because you're editing without user confirmation: if you couldn't refute the point and the fix is clear, apply it. Skip anything you flagged as invalid, out-of-date, already addressed, or needing the user's judgment (design trade-offs, unclear intent), and list those for the user.

Edit files only. Do **not** commit, push, or reply to comments — leave that to the user. End with a clear list of what you changed and what you left for them.
