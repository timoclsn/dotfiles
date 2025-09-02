---
description: review pr
---

## Context

- GitHub PR number: $ARGUMENTS

## Task

Please provide a detailed pull request review on the given GitHub PR.

Follow these steps:

1. Use `gh pr view [PR number]` to pull the information of the PR.
2. Use `gh pr diff [PR number]` to view the diff of the PR.
3. Understand the intent of the PR using the PR description.
4. If PR description is not detailed enough to understand the intent of the PR,
   make sure to note it in your review.
5. Search the codebase if required.
6. Write a concise review of the PR, keeping in mind to encourage strong code
   quality and best practices.

- Never update or add anything to the PR, just show your review locally.
