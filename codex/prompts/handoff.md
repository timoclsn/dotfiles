---
description: resume work on existing branch/PR
argument-hint: <INSTRUCTIONS>
---

Gather context on what has already been implemented in this branch/PR, then continue with the new user instructions. Context to gather (use repo/PR ground truth):

- Determine the parent branch / merge-base and review the FULL diff of the branch against the parent (not just the last commit).
- Include the working copy: uncommitted and unstaged changes (new/modified/deleted files).
- Review recent commits on this branch to understand intent and sequencing.
- If a PR already exists for this branch, read the PR title and description/body to infer the goal, scope, and any TODOs/checklists. Prefer PR text + diffs over assumptions.

While continuing the task:

- Use the gathered context to avoid duplicating work and to stay consistent with existing decisions and conventions in this branch.
- If there are contradictions between PR description and code, treat the code/diff as authoritative and adjust accordingly.

New user instructions:
$ARGUMENTS
