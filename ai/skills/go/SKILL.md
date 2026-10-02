---
name: go
description: "End-to-end task execution: implement, verify, simplify, review, then open a draft PR. Use when the user invokes `/go` with a task description and wants the full pipeline run without further prompts."
disable-model-invocation: true
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

   Detect available checks from `package.json` scripts, `Makefile`, or project conventions. Skip a check only if no tooling exists for it.

   Then: **Give me irrefutable proof that this is now fixed / done.** Run the project yourself (e.g. via the `run` skill — start the app, call the CLI, hit the endpoint, open it in the browser) and exercise the new behavior by hand. Passing checks are not proof. When the change is visible, capture screenshots or a screen recording that show it working, for the PR. If running it isn't possible, say why in the final report.

   Fix any failures before continuing.

3. **Simplify.** Invoke the `simplify` skill to clean up the changed code.

4. **Review.** Invoke the `code-review` skill with the `--fix` flag on effort `high` to review changed code (including the simplify edits) and apply its fixes. If steps 3–4 meaningfully affected behavior, re-run the relevant checks from step 2.

5. **Ship.** Invoke the `commit-commands:commit-push-pr` skill. The PR must be a **draft** and **assigned to the current user** (`@me`). Then add the proof from step 2 to the PR description: attach screenshots/recordings with `gh pr edit --attach` (with alt text), or for non-visual changes, include the relevant command output. Keep media files out of the repo, and never upload them anywhere else.

6. **Babysit CI.** Invoke the `babysit-ci` skill to watch the PR's CI and shepherd it to green, automatically fixing and pushing any failures.

Report briefly at the end: what shipped, which checks ran, the proof that it works, the final CI state, and the PR URL.
