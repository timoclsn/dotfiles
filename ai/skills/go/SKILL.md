---
name: go
description: "End-to-end task execution: implement, check, polish, prove, open a PR (draft unless `--ready`), then babysit CI to green (plus AI review comments with `--ready`). Only use when the user explicitly asks for it, by typing `/go` or by telling you to use the go skill (e.g. in a `/session` prompt). Never pick it on your own for ordinary tasks."
---

Execute the task below end-to-end, running all steps in order without stopping for confirmation between them.

Flags: if the task contains `--ready`, it isn't part of the task. Open the PR ready for review instead of as a draft, and babysit CI plus AI review comments (step 6) instead of just CI.

If no task is given (apart from flags), the implementation is already done in this conversation or working tree. Skip step 1 and start at step 2.

## Task

$ARGUMENTS

## Steps

1. **Implement the task.** Do the work described above.

2. **Check.** Run every applicable check for this project:
   - typecheck (e.g. `tsc --noEmit`, `tsc -b`, language equivalent)
   - tests (unit/integration — whatever the project uses)
   - lint (e.g. `eslint`, `biome`, `ruff`)

   Detect available checks from `package.json` scripts, `Makefile`, or project conventions. Skip a check only if no tooling exists for it.

   Fix any failures before continuing.

3. **Polish.** Invoke the `polish` skill to simplify and review the changed code and fix what holds up. If it meaningfully affected behavior, re-run the relevant checks from step 2.

4. **Prove.** Invoke the `proof` skill on the final code, and fix any failures it uncovers (then re-run the checks from step 2).

5. **Ship.** Create a branch if needed, commit, push, and open a PR. Write the description with the PR description/body skill if one is available. Include the proof from step 4 in it: attach screenshots/recordings with `gh pr edit --attach` (with alt text), or for non-visual changes, include the relevant command output. Keep media files out of the repo, and never upload them anywhere else.

6. **Babysit.** Invoke the `babysit-ci` skill to watch the PR's CI and shepherd it to green, automatically fixing and pushing any failures. With `--ready`, invoke the `babysit-ci-ai` skill instead, which additionally works through AI reviewers' comments and stops once CI is green and the AI reviewer is satisfied.

Report briefly at the end: what shipped, which checks ran, the proof that it works, the final CI state, and the PR URL.
