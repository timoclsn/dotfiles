---
name: ci-failure
description: Investigate failing CI checks on the current branch's PR, analyze the logs, and walk the user through each failure with a root cause and suggested fix. Read-only — no changes are made. Use when the user invokes `/ci-failure` to triage red CI before deciding what to act on.
---

You are investigating the failing CI checks on the current branch's pull request. **Read-only**: do not edit files, push, re-run jobs, or comment. Your job is to gather, analyze, and explain.

## Steps

1. Find the PR for the current branch and identify every failing or cancelled check. If there is no PR, fall back to the latest CI runs for the branch.

2. For each failing check, pull the logs and find the actual error — the assertion, stack trace, or non-zero exit. Skip setup noise.

3. Tie the failure back to the code. Read the relevant files at HEAD and judge whether it's caused by this branch, a flake, environmental (missing secret, cache, dependency), or pre-existing on main.

4. Walk the user through them. For each failing check:
   - **Check name + job/step**
   - **Failure** — the key error line(s), quoted, trimmed to the signal
   - **Root cause** — one or two lines grounded in the logs and code you read
   - **Category** — code bug / test failure / lint / type error / flake / infra / config
   - **Suggested fix** — concretely what you would change or try next. Plan only, no edits.

   Group related failures (same root cause across multiple jobs) into one entry.

5. End with a summary: total failing checks, how many share a root cause, what looks like a real bug vs. flake/infra, and what needs the user's judgment before acting.
