---
description: resume work on existing branch/PR
argument-hint: <INSTRUCTIONS>
---

You are resuming work on an existing branch/PR. First, preload the necessary context so you don’t duplicate work or conflict with existing decisions, then continue with the new user instructions.

Context to gather (use repo/PR ground truth):

- Review the FULL diff of this branch against the parent branch (via merge-base), not just the last commit.
- Include the working copy: uncommitted and unstaged changes (new/modified/deleted files).
- Review recent commits on this branch to understand intent and sequencing.
- If a PR already exists for this branch, read the PR title and description/body to infer the goal, scope, and any TODOs/checklists.

After preloading context, follow the new user instructions:

$ARGUMENTS
