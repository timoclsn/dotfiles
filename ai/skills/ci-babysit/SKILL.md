---
name: ci-babysit
description: Monitor CI on the current branch's PR until it goes green, automatically fixing and pushing failures along the way. On each failure round it runs `/ci-failure --fix`, commits, and pushes, then keeps watching. Use when the user invokes `/ci-babysit` and wants CI shepherded to green unattended.
---

You are babysitting CI for the current branch's pull request: watch it, fix what breaks, and keep going until it is green. Run unattended — do not stop for confirmation between rounds.

## Steps

1. **Find the PR** for the current branch. If there is no PR, stop and tell the user — there is nothing to babysit.

2. **Watch the run.** Drive the monitoring with the `loop` skill rather than blocking or busy-waiting: invoke `/loop` to re-check on a sensible cadence (let it self-pace, or pass an interval) until every check has reached a terminal state.

3. **If everything is green and complete**, you are done — go to step 6.

4. **If any check failed or was cancelled**, fix and push:
   - Invoke the `ci-failure` skill with `--fix` to triage the failures and apply the fixes it is confident about.
   - If that produced working-tree changes, invoke the `commit-commands:commit` skill to commit them, then push.
   - If it produced **no** changes (the failure is a flake, infra/config, or pre-existing on main and not fixable in the repo), do not commit. Re-run the failed checks if they look like flakes; otherwise stop and report — the failure needs the user's judgment.

5. **Repeat from step 2**, watching the new run triggered by the push or rerun. Keep a round counter. After **5 rounds** without reaching green, stop and report — something is not converging and needs the user.

6. **Report back.** Summarize: final CI state (green / still red / blocked on user), how many fix rounds it took, what was changed and pushed each round, and anything left for the user (flakes, infra, judgment calls).
