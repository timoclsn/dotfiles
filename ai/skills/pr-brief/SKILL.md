---
name: pr-brief
description: Brief the user on a complex PR/branch they've pulled locally before they review and test it — what it claims to do, what it actually changes, which parts deserve close attention, how risky it is to ship, and how to run it locally to exercise the change. Read-only. Pass `--artifact` to also build an interactive Artifact that guides the user through the review step by step. Use when the user invokes `/pr-brief` (optionally with a PR number or branch name) while about to do or in the middle of code review on something checked out locally.
argument-hint: "[PR number or branch (optional)] [--artifact]"
---

You are briefing the user before they review a change they've checked out locally. This is **read-only**: do not edit files, comment, push, or fix anything. Your job is to orient them, in the terminal, as a walkthrough — not a written document. The only exception is `--artifact` (see below).

## Target

$ARGUMENTS

- Ignore `--artifact` when reading the target; it's a flag, not a branch name.
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

4. **Assess the risk of shipping it.** Step 3 is about where to look in the code; this is about what could go wrong once it's merged and deployed. Give an overall rating (low / medium / high) with a one-line reason, then cover only what applies:
   - Blast radius: who or what is affected if it breaks (all users, one feature, internal tooling only)
   - Failure modes: the most likely ways it breaks in production, including edge cases the tests don't exercise
   - Deploy and rollback: ordering dependencies, migrations, config/env changes, feature flags, and whether a plain revert is safe
   - Compatibility: effects on other services, clients, or consumers of changed APIs, data formats, or shared code
   Base each risk on something concrete in the diff, not generic worries. If the change is genuinely low-risk, say so in a line and move on.

5. **Explain how to run it locally to test the change.** Work out how this project actually runs — check for scripts, a README, a Makefile, or established conventions for this repo/stack. Give concrete steps: how to start it, which flow/route/command exercises the changed behavior specifically (not just "start the app"), any env vars/seed data/fixtures the change depends on, and which existing tests are most relevant to run.

## Output

Present all five as a single walkthrough directly in the terminal. Keep it proportional to the change — a small PR gets a short brief, a genuinely complex one gets more depth in step 3. End with a one-line summary of what you'd personally look at first.

## Interactive review guide (`--artifact`)

If `--artifact` was passed, after the terminal walkthrough also publish an Artifact that walks the user through reviewing the change, built from the same findings. The terminal brief stays the overview; the artifact is what they keep open beside their editor while they review. Load the artifact design guidance before writing it, as the Artifact tool requires.

Design it around the order you'd actually review in, not the order of the diff:

- **Header** — PR title/link, branch and base, overall risk rating with its one-line reason, and a short "what this PR does" from steps 1–2. Flag any mismatch between the description and the actual diff here.
- **Review path** — the core of the page. An ordered list of steps, starting with what to read first to understand the change (usually the entry point or the core logic, not the tests) and ending with the mechanical bits. Each step names the files or areas involved with `path:line` references, explains in a sentence or two why it matters and how it connects to the previous step, and lists the concrete questions to answer there (edge cases, contracts, missing tests). Include short, relevant diff excerpts where they save the reader a jump to the editor, but don't paste the whole diff. Group low-risk, mechanical changes into one final "skim" step.
- **Progress** — let the user tick off each step and each question as they go, with an overall progress indicator. Keep this in per-viewer browser storage; it's a personal convenience, not shared state.
- **Notes** — a place per step to jot down review comments as they go, so they can be copied out into the PR afterwards. Also per-viewer browser storage.
- **Risk** — the shipping risks from step 4, each tied back to the review step where it's visible in the code.
- **Test it** — the run-locally steps from step 5 as a checklist, with commands in copyable code blocks.

Keep it proportional: a small PR gets a few steps, not a dashboard. Make it keyboard-navigable and accessible, and keep it readable in both light and dark mode.

Publishing the artifact is the only thing this flag adds — the rest of the skill stays read-only. Leave out secrets, tokens, and env values you came across while reading the code. End the terminal output with the artifact link.
