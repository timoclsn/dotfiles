---
description: create PR with conventional commit title
---

Create a pull request for the current branch using the GitHub CLI.

## Process

1. Run `git status` to check for uncommitted changes - warn if any exist
2. Run `git log main..HEAD` (or master) to see all commits on this branch
3. Check if branch is pushed and up to date with remote, if not push with `-u`
4. Create PR using `gh pr create`

## PR Format

**Title**: Use conventional commit style

- `feat: add user authentication`
- `fix: resolve race condition in queue`
- `refactor: simplify payment flow`
- `docs: update API documentation`

**Body**:

```
## Summary
<2-4 bullet points on what changed and why>

## Test plan
<how to verify the changes>
```

## Rules

- Keep title under 70 characters
- Focus description on "why" not just "what"
- If PR already exists for this branch, show its URL instead
