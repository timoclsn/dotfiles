---
name: babysit-ci-ai
description: Shepherd the current branch's PR through its automated feedback, unattended — CI checks and AI reviewer comments (Copilot, CodeRabbit, etc.). Each round it fixes failing CI and fixes or dismisses AI review comments, pushing and replying as it goes, and it stops by itself once CI is green and the AI reviewer is satisfied. Ignores human review comments and base-branch sync (use `/babysit-pr` for those). Use when the user invokes `/babysit-ci-ai`.
---

You are babysitting the automated feedback on the current branch's pull request: CI and AI reviewers. Watch it, fix or dismiss what comes in, and keep going until both are settled. Run unattended — do not stop for confirmation between rounds. Leave human reviewers' comments and base-branch sync alone.

## Steps

1. **Find the PR** for the current branch. If there is no PR, stop and tell the user — there is nothing to babysit.

2. **Watch, via the `loop` skill.** Invoke `/loop` (self-paced, or with an interval) to run steps 3–6 each round until the stop condition in step 6 is met.

3. **Assess** (once per round): the status of every CI check, and the open review threads from AI reviewers. Skip resolved and outdated threads, and ignore anything written by a human.

4. **Fix CI** if any check failed or was cancelled:
   - Invoke the `ci-failure` skill with `--fix` to triage and apply the fixes it is confident about.
   - If that produced working-tree changes, commit them and push.
   - If it produced **no** changes (flake, infra/config, or pre-existing on the base branch), do not commit. Re-run the failed checks if they look like flakes; otherwise note it for the report — it needs the user's judgment.

5. **Handle AI review comments** if any are open:
   - Invoke the `pr-feedback` skill with `--fix` on them to verify each point adversarially and apply the ones that survive.
   - If it produced changes, invoke the `pr-reply` skill with `--resolve` to commit, push, reply to the **fixed** threads and resolve them.
   - For points that are clearly wrong, stale or already handled, reply with the reason and resolve the thread.
   - For points that need the user's judgment, do not reply or resolve — leave the thread open and list it for the report.

6. **Check the stop condition.** Done when **both** hold:
   - every CI check has finished and is green;
   - the AI reviewer is satisfied: it has approved the PR and no AI threads are left open, **or** it has reviewed the latest commit and no AI threads are left open. Many AI reviewers never post an approval, so the second form must count.

   If done, go to step 8. Otherwise let the loop run the next round (back to step 3) — watch the run triggered by any push, and expect a new AI review of it to arrive. Keep a round counter per workstream; after **5 rounds** without CI going green or AI threads clearing, stop pushing changes at it, leave it for the user, and end with what's left.

7. **Do not touch anything outside this scope** — no base sync, no conflict resolution, no replies to human threads.

8. **Report back.** Summarize: final CI state, whether the AI reviewer approved or simply has no open threads, how many rounds it took, what was fixed and pushed each round, which AI comments were dismissed and why, and anything left for the user (flakes, infra, comments needing judgment).
