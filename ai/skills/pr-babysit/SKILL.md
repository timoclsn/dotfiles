---
name: pr-babysit
description: Keep the current branch's PR mergeable, unattended. Each round it shepherds CI to green, syncs with the base branch and resolves conflicts, and addresses review feedback (Copilot + human) — fixing, committing, pushing, and replying as it goes. Runs as a persistent watcher that does not self-terminate; it keeps babysitting until you stop it. Use when the user invokes `/pr-babysit` and wants the PR driven to and held in a mergeable state without supervision.
---

You are babysitting the current branch's pull request: keep it mergeable. Watch it, fix what blocks a merge, and keep going. Run unattended — do not stop for confirmation between rounds, and do not self-terminate when the PR is clean; keep watching until the user stops you.

Three things block a merge, and each round you address whichever are actionable:

1. **CI** — checks are red, cancelled, or incomplete.
2. **Base sync** — the branch is behind its base (main/master) or conflicts with it.
3. **Review comments** — unaddressed feedback from Copilot or human reviewers.

The narrow case (waiting on a Copilot review you requested) is just this loop on a PR where CI is already green and the branch is current — it collapses to the comment step.

## Steps

1. **Find the PR** for the current branch. If there is no PR, stop and tell the user — there is nothing to babysit.

2. **Start the monitoring loop — always, and before assessing anything.** Invoke the `loop` skill (`/loop`, self-paced or with an interval) to run the per-round cycle (steps 3–8) on a sensible cadence. Start it **unconditionally**: do this even if you expect or already know the PR is currently mergeable. A clean PR is not a reason to skip the loop — it can regress at any time (new commits land on the base, a reviewer or Copilot comments, a check re-runs and goes red). The only thing that stops the loop is the user. Do not assess first and bail early because it looks clean; establish the loop, then let each round assess.

3. **Assess the merge state** (once per round, inside the loop). Determine: CI status (per check), whether the branch is behind or conflicts with its base, and what review comments are open (inline review comments, top-level reviews, issue-style PR comments) from both Copilot and humans. Skip resolved/outdated threads. If nothing is actionable this round, that is a normal clean round — report briefly (step 8) and let the loop continue; do **not** exit.

4. **Fix CI** if any check failed or was cancelled:
   - Invoke the `ci-failure` skill with `--fix` to triage and apply confident fixes.
   - If it produced working-tree changes, invoke `commit-commands:commit` to commit, then push.
   - If it produced **no** changes (flake, infra/config, or pre-existing on the base branch), do not commit. Re-run the failed checks if they look like flakes; otherwise note it for the report — it needs the user's judgment.

5. **Sync with base** if the branch is behind or conflicts with main/master:
   - Merge the base branch in. If it merges cleanly, commit (if a commit is needed) and push.
   - If it conflicts, invoke the `merge-conflict` skill with `--fix` to resolve the hunks it is confident about, then stage, complete the merge, and push. Leave any hunks it flagged as needing judgment for the report — do not guess on semantic conflicts.

6. **Address review comments** if any are open:
   - Invoke the `pr-feedback` skill with `--fix` to verify each point adversarially and apply the ones that survive refutation.
   - If it produced working-tree changes, commit and push them.
   - For each thread it **addressed**, post a concise reply noting what changed. For **Copilot** threads, also resolve the thread once the fix is committed and pushed (don't resolve before the push lands). For **human** threads, only reply — leave them open for the reviewer to resolve.
   - For points it judged invalid, out-of-date, already addressed, or needing the user's judgment, do **not** auto-reply or argue with the reviewer — leave the thread open and list it for the report.

7. **Let the loop run the next round (back to step 3).** Watch the new run triggered by any push, and re-check for comments that landed while you were working (a requested review may arrive mid-round). The loop does **not** self-terminate — keep babysitting until the user stops you. Guard against thrashing per workstream: if the same CI check, conflict, or comment fails to converge after a couple of attempts (your fix didn't take, or it bounces back), stop pushing more changes at it, leave it for the user, and keep watching the rest rather than looping on a fix that isn't working.

8. **Report after each round of activity** (and whenever the PR reaches a clean state): summarize the current merge state and, per workstream, what changed this round — CI failures fixed and pushed, base-sync/conflict resolution, comments addressed (and replied/resolved) vs. left for the user — plus anything needing the user's judgment (flakes, infra, semantic conflicts, design-trade-off comments, non-converging fixes). Then keep watching.
