#!/usr/bin/env bash
# Prints one JSON object with the SonarQube quality gate, unresolved issues and
# security hotspots flagged on a pull request. Read-only.
#
# Usage: fetch-pr-issues.sh [sonarqube-issues-url]
# Without a URL it uses the current branch's PR and the `sonar.projectKey` from
# sonar-project.properties at the repo root.
# Needs: $SONARQUBE_URL, $SONARQUBE_TOKEN, curl, jq (and git + gh without a URL).
set -euo pipefail

fail() {
  echo "error: $*" >&2
  exit 1
}

[ "$#" -le 1 ] || fail "usage: $0 [sonarqube-issues-url]"
[ -n "${SONARQUBE_URL:-}" ] && [ -n "${SONARQUBE_TOKEN:-}" ] ||
  fail "SONARQUBE_URL and SONARQUBE_TOKEN must both be set in this shell"
host="${SONARQUBE_URL%/}"

if [ "$#" -eq 1 ]; then
  project_key="$(sed -n 's/.*[?&]id=\([^&]*\).*/\1/p' <<<"$1")"
  pull_request="$(sed -n 's/.*[?&]pullRequest=\([^&]*\).*/\1/p' <<<"$1")"
else
  properties="$(git rev-parse --show-toplevel)/sonar-project.properties"
  [ -f "$properties" ] || fail "no sonar-project.properties in the repo root; pass the SonarQube issues URL instead"
  project_key="$(sed -n 's/^sonar\.projectKey[[:space:]]*=[[:space:]]*//p' "$properties" | tr -d '\r')"
  pull_request="$(gh pr view --json number --jq .number)"
fi
[ -n "$project_key" ] && [ -n "$pull_request" ] ||
  fail "could not work out the project key and PR number"

# Prints the response body. The token goes to curl on stdin so it never shows up
# in the process list.
api() {
  local path="$1"
  shift
  local response status
  response="$(
    printf 'header = "Authorization: Bearer %s"\n' "$SONARQUBE_TOKEN" |
      curl -sS -m 30 -K - -G -w '\n%{http_code}' \
        "$host$path" --data-urlencode "pullRequest=$pull_request" "$@"
  )" || fail "could not reach $host (VPN?)"
  status="${response##*$'\n'}"
  [ "$status" = 200 ] ||
    fail "SonarQube answered HTTP $status for $path (401/403: token expired, revoked or no access; 404: wrong project key or PR)"
  printf '%s' "${response%$'\n'*}"
}

# Component keys look like "<project-key>:<path>"; keep only the path.
defs='def file: .component | ltrimstr($key + ":");'

quality_gate="$(api /api/qualitygates/project_status --data-urlencode "projectKey=$project_key" |
  jq '{
    status: .projectStatus.status,
    failedConditions: [
      .projectStatus.conditions[]
      | select(.status == "ERROR")
      | {metric: .metricKey, actual: .actualValue, threshold: .errorThreshold, comparator}
    ]
  }')"

# The issues API returns at most 500 per page; collect every page.
issues='[]'
page=1
while :; do
  response="$(api /api/issues/search \
    --data-urlencode "componentKeys=$project_key" \
    --data-urlencode "resolved=false" \
    --data-urlencode "ps=500" \
    --data-urlencode "p=$page")"
  issues="$(jq -n --arg key "$project_key" --argjson all "$issues" --argjson page "$response" "$defs"'
    $all + [$page.issues[] | {severity, type, rule, message, file: file, line}]')"
  [ "$((page * 500))" -ge "$(jq '.paging.total' <<<"$response")" ] && break
  page=$((page + 1))
done

hotspots="$(api /api/hotspots/search \
  --data-urlencode "projectKey=$project_key" \
  --data-urlencode "status=TO_REVIEW" \
  --data-urlencode "ps=500" |
  jq --arg key "$project_key" "$defs"'[.hotspots[] | {vulnerabilityProbability, securityCategory, message, file: file, line}]')"

jq -n \
  --arg url "$host/project/issues?id=$project_key&pullRequest=$pull_request&resolved=false" \
  --argjson qualityGate "$quality_gate" \
  --argjson issues "$issues" \
  --argjson hotspots "$hotspots" \
  '["BLOCKER", "CRITICAL", "MAJOR", "MINOR", "INFO"] as $order
  | {
      url: $url,
      qualityGate: $qualityGate,
      issues: ($issues | sort_by(.severity as $s | $order | index($s))),
      hotspots: $hotspots
    }'
