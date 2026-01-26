---
description: resume work on existing branch/PR
---

$ARGUMENTS

You are resuming work on an existing branch/PR. First, preload the necessary context using a subagent then continue with the new user instructions.

Context to gather:

- Review the FULL diff of this branch against the parent branch (via merge-base), not just the last commit.
- Include the working copy: uncommitted and unstaged changes (new/modified/deleted files).
- Review recent commits on this branch to understand intent and sequencing.
- If a PR already exists for this branch, read the PR title and description/body to infer the goal, scope, and any TODOs/checklists.

The subagent output must be ONLY a "Context Summary" (no implementation plan), containing:

```
Context Summary
1) What this branch/PR is about (2-6 sentences)
2) High-level changes (bullets)
3) Key files touched (grouped by area, include paths)
4) Notable decisions/assumptions inferred from code or PR text
5) TODO / follow-ups visible in code, comments, failing tests, or PR description
6) How to run/verify (only if discoverable from repo/docs)
```

Keep it short (aim ~150-300 words), but include file paths and concrete facts.
