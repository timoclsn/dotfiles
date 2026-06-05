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

2. **Verify each point against the current code.** For PR comments, the line referenced may have moved — find the relevant code at HEAD. For local feedback, locate the code the user is referring to. Judge whether the concern still applies.

3. **Walk the user through them.** For each point:
   - **Source** — reviewer + file:line for PR comments; just file:line (or "general") for local feedback
   - **Comment** — short paraphrase, or quote if short
   - **Verdict** — valid / partially valid / invalid / already addressed / out-of-date, with a one-line reason grounded in what you read
   - **Suggested fix** (if valid) — concretely what you would change. Plan only, no edits.

   Group by file or reviewer, whichever scans easier. Trivial valid points can be one line.

4. **End with a summary**: total points, how many valid, how many you'd act on, anything needing the user's judgment.

## Applying fixes (`--fix`)

If `--fix` was passed, after the walkthrough apply the points you're confident about directly to the working tree — the valid ones with a concrete, unambiguous fix. Skip anything you flagged as invalid, out-of-date, already addressed, or needing the user's judgment (design trade-offs, unclear intent), and list those for the user.

Edit files only. Do **not** commit, push, or reply to comments — leave that to the user. End with a clear list of what you changed and what you left for them.
