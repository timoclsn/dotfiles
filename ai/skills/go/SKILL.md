---
name: go
description: End-to-end task execution: implement, verify, simplify, then open a draft PR. Use when the user invokes `/go` with a task description and wants the full pipeline run without further prompts.
---

Execute the task below end-to-end, running all steps in order without stopping for confirmation between them.

## Task

$ARGUMENTS

## Steps

1. **Implement the task.** Do the work described above.

2. **Verify.** Run every applicable check for this project:
   - typecheck (e.g. `tsc --noEmit`, `tsc -b`, language equivalent)
   - tests (unit/integration — whatever the project uses)
   - lint (e.g. `eslint`, `biome`, `ruff`)

   Detect available checks from `package.json` scripts, `Makefile`, or project conventions. Skip a check only if no tooling exists for it. Fix any failures before continuing.

3. **Simplify.** Invoke the `simplify` skill to review changed code for reuse, quality, and efficiency, and apply its fixes. If the changes meaningfully affect behavior, re-run the relevant checks from step 2.

4. **Ship.** Invoke the `commit-commands:commit-push-pr` skill. The PR must be a **draft** and **assigned to the current user** (`@me`).

Report briefly at the end: what shipped, which checks ran, and the PR URL.
