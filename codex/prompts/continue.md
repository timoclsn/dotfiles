---
description: resume work on existing branch/PR
argument-hint: <INSTRUCTIONS>
---

$ARGUMENTS

You are resuming work on an existing branch/PR. First, preload the necessary context then continue with the new user instructions.

Context to gather:

- Review the FULL diff of this branch against the parent branch (via merge-base), not just the last commit.
- Include the working copy: uncommitted and unstaged changes (new/modified/deleted files).
- Review recent commits on this branch to understand intent and sequencing.
- If a PR already exists for this branch, read the PR title and description/body to infer the goal, scope, and any TODOs/checklists.
