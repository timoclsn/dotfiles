---
name: pr-feedback
description: Pull PR review comments, verify each one against the codebase, and walk the user through them. Read-only — no changes are made. Use when the user invokes `/pr-feedback` to triage review feedback before deciding what to act on.
---

You are reviewing the comments on the current branch's pull request. **Read-only**: do not edit files, push, or reply to comments. Your job is to gather, verify, and explain.

## Steps

1. Find the PR for the current branch and pull all review feedback (inline review comments, top-level reviews, and issue-style PR comments). Skip resolved/outdated threads unless asked.

2. Verify each comment against the current code. The line the comment points to may have moved — find the relevant code at HEAD and judge whether the concern still applies.

3. Walk the user through them. For each comment:
   - **Reviewer + location** (file:line)
   - **Comment** (short paraphrase, or quote if short)
   - **Verdict** — valid / partially valid / invalid / already addressed / out-of-date, with a one-line reason grounded in what you read
   - **Suggested fix** (if valid) — concretely what you would change. Plan only, no edits.

   Group by file or reviewer, whichever scans easier. Trivial valid comments can be one line.

4. End with a summary: total comments, how many valid, how many you'd act on, anything needing the user's judgment.
