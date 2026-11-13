---
name: sonarqube-issues
description: Read the SonarQube issues, quality gate status and security hotspots flagged on a pull request via the self-hosted SonarQube API. Read-only. Use when a CI check is a failing SonarQube analysis or quality gate, or the user asks what Sonar flagged on a PR.
argument-hint: "[sonarqube-issues-url]"
---

Fetch what SonarQube flagged on a PR and report it. Read-only: never change issue status or comment. May run unattended (e.g. inside `/babysit-ci`), so never ask questions.

Needs `$SONARQUBE_URL` and `$SONARQUBE_TOKEN` in the environment (the host may need the VPN).

## Steps

1. **Check the SonarQube analysis check** on the PR. If it is still running, the results belong to the previous push: say so in the report rather than waiting.

2. **Run `${CLAUDE_SKILL_DIR}/scripts/fetch-pr-issues.sh`**, passing a SonarQube issues URL only if the user gave one. It works out the PR and project key itself and prints JSON: `url`, `qualityGate`, `issues` (unresolved, most severe first) and `hotspots`. On error, stop and report its message; don't retry.

3. **Check the code.** Read each flagged file at HEAD. If the lines don't match the issue message, the analysis is stale: say so instead of guessing. Ignore issues outside the PR's changes.

4. **Report**, grouped by rule:
   - Quality gate status and failed conditions (coverage and duplication show up here, not in issues)
   - Per issue: `file:line`, severity, rule, message, one-line fix
   - Summary: counts by severity, what blocks the gate, likely false positives, and the `url`

If the gate failed but the issues are empty, say so; don't invent any.
