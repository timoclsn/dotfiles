---
description: review code changes
---

## Context

- scope: "$ARGUMENTS"

## Task

- Use the judge subagent to do code review on the scope.
- Delegate the task of finding changes within the scope to the subagent.
- Do not provide the subagent with code review rules; it uses its own built-in instructions.
- If the given scope has no changes it should abort the request and let the user clarify the scope.
- If no scope is given review all changes compared to the parent branch.
- Don't directly implement the review feedback just list it.
