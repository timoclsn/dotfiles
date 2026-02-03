---
description: simplify code (same result with less code)
argument-hint: <SCOPE>
---

Review the code changes and simplify them while preserving the exact same behavior focusing on maintainabillity.

## Scope

- Scope is: $ARGUMENTS
- If scope is empty default to uncommited changes.

## Guidelines

Look for opportunities to:

- Remove unnecessary abstractions and indirection
- Inline single-use helper functions
- Simplify conditional logic (early returns, remove nested if/else)
- Remove redundant type annotations (let TypeScript infer)
- Consolidate duplicate code patterns
- Remove defensive checks that can't fail
- Use more concise language features

## Rules

- The result must be functionally identical
- Don't introduce new dependencies
- Maintain the existing code style of the file
- Only simplify the changed code, don't refactor surrounding code
