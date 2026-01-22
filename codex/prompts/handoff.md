---
description: resume work on existing branch/PR
argument-hint: <INSTRUCTIONS>
---

You are resuming work on an existing branch/PR. Use a TWO-PHASE workflow.

## PHASE 1 — Context Gather

First, gather evidence and produce a concise, structured handoff summary.

You MUST inspect:
- The full diff of this branch/PR against the parent branch (via merge-base), not just the last commit
- The working copy, including uncommitted/unstaged files
- Recent commits on this branch (subjects + what changed)
- If a PR already exists: the PR title and description/body to infer intent/scope (and any checklist/todos)

Prefer ground truth from diffs and PR text over assumptions. Use repo-native tooling (git; PR tooling like `gh` if available).

Produce a "Context Summary" containing:

```
Context Summary
1) What this branch/PR is about (2-6 sentences)
2) High-level changes (bullets)
3) Key files touched (grouped by area, include paths)
4) Notable decisions/assumptions inferred from code or PR text
5) TODO / follow-ups visible in code, comments, failing tests, or PR description
6) How to run/verify (only if discoverable from repo/docs)
7) Risks/regressions to watch
```

Keep it short (aim ~150-300 words), but include file paths and concrete facts.

## PHASE 2 — Execute

Treat the Context Summary as the authoritative preloaded context. Then proceed with the NEW user instructions below. If anything is unclear, investigate the code/diffs first rather than asking the user to restate prior context.

## NEW USER INSTRUCTIONS

$ARGUMENTS
