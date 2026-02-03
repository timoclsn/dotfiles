---
description: commit uncommitted changes (single or atomic series)
---

Commit the currently uncommitted changes (staged and unstaged).

## Process

1. Run `git status` and `git diff` to understand all changes
2. Analyze the changes and decide:
   - **Single commit**: if changes are cohesive and serve one purpose
   - **Multiple atomic commits**: if changes can be logically separated (e.g., refactor + feature, or multiple independent fixes)
3. For multiple commits, group related changes and commit them in logical order (dependencies first)

## Commit Guidelines

- Write concise commit messages (1-2 sentences) focusing on "why" not "what"
- Use conventional commit style if the repo uses it
- Each commit should be self-contained and not break the build
- Stage files explicitly, avoid `git add -A`

## Rules

- Never force push
- Never amend existing commits unless explicitly asked
- If unsure about grouping, prefer fewer commits over many tiny ones
