---
name: pr-brief
description: Brief the user on a complex PR/branch they've pulled locally before they review and test it — what it claims to do, what it actually changes, which parts deserve close attention, and how to run it locally to exercise the change. Read-only. Use when the user invokes `/pr-brief` (optionally with a PR number or branch name) while about to do or in the middle of code review on something checked out locally.
argument-hint: "[PR number or branch (optional)]"
---

You are briefing the user before they review a change they've checked out locally. This is **read-only**: do not edit files, comment, push, or fix anything. Your job is to orient them, in the terminal, as a walkthrough — not a written document or artifact.

## Target

$ARGUMENTS

- If a PR number or branch name was given above, use that (check it out only if the user asks — otherwise inspect it via `gh`/`git` without switching branches from under them).
- If empty, use the current branch's PR (or if there's no PR, just the current branch against the repo's default branch).

## Steps

1. **Establish the claimed intent.** Pull the PR title/description via `gh` (using this repo's configured account, per CLAUDE.md conventions). If it references a Jira key or issue, pull that too (via `acli` for Jira). Summarize in a couple of plain-language sentences: what is this branch trying to do, and why.

2. **Independently summarize the actual diff.** Diff the branch against its base (detect the base from the PR, or the repo's default branch if there's no PR) — don't rely on the PR description here. Read enough of the changed files to understand the shape of the change, then summarize what actually changed, grouped by file or area. Doing this independently of step 1 is the point: it's how you catch a description that's stale, incomplete, or oversells/undersells the change.

3. **Call out where to focus review.** Don't just list every changed file — rank or flag what actually needs scrutiny:
   - Non-obvious or intricate logic
   - Changed public APIs, contracts, or shared/critical paths
   - Migrations or anything touching persisted data
   - Auth/permission-sensitive changes
   - Changed behavior with no or weak test coverage
   Mechanical, low-risk changes (renames, formatting, generated files, version bumps) can be mentioned in passing, not dwelt on.

4. **Explain how to run it locally to test the change.** Work out how this project actually runs — check for scripts, a README, a Makefile, or established conventions for this repo/stack. Give concrete steps: how to start it, which flow/route/command exercises the changed behavior specifically (not just "start the app"), any env vars/seed data/fixtures the change depends on, and which existing tests are most relevant to run.

## Output

Present all four as a single walkthrough directly in the terminal. Keep it proportional to the change — a small PR gets a short brief, a genuinely complex one gets more depth in step 3. End with a one-line summary of what you'd personally look at first.
