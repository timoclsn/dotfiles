#!/usr/bin/env bash
# =============================================================================
# Plugin: github_pr
# Description: The GitHub PR for the current pane's branch: number, CI, review
#
# Lives in the dotfiles and is symlinked into tmux-powerkit's plugin folder by
# setup.sh, because powerkit only loads plugins from there. The segment colour
# shows the PR state: draft, the most common, looks like the other segments;
# open is green, closed red, and merged yellow as a nudge to leave the branch.
# The glyphs follow the agents-dashboard: CI ✓ passing, ✗ failing, • pending; review
# ✓ approved (a single ✓ when CI passes too), ! changes requested, ? review
# required. Hidden when the branch has no PR.
# =============================================================================

POWERKIT_ROOT="${POWERKIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "${POWERKIT_ROOT}/src/contract/plugin_contract.sh"

plugin_get_metadata() {
    metadata_set "id" "github_pr"
    metadata_set "name" "GitHub PR"
    metadata_set "description" "PR state, CI and review for the current branch"
}

plugin_check_dependencies() {
    require_cmd "gh" || return 1
}

plugin_declare_options() {
    declare_option "icon" "icon" $'\uf09b' "Plugin icon"
    # Each collect asks gh, so this is also how often the PR is fetched. It's
    # one cache for all sessions, so after switching sessions the segment can
    # show the previous branch's PR for up to this long.
    declare_option "cache_ttl" "number" "30" "Cache duration in seconds"
}

# Checked on every render, so leaving a repo hides the segment right away
# instead of after the next collect
plugin_should_be_active() {
    local path
    path=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)
    [[ -n "$path" ]] && git -C "$path" rev-parse --is-inside-work-tree &>/dev/null
}

plugin_get_state() {
    [[ -n "$(plugin_data_get "number")" ]] && printf 'active' || printf 'inactive'
}

plugin_get_health() {
    case "$(plugin_data_get "state")" in
        open) printf 'good' ;;
        merged) printf 'warning' ;;
        closed) printf 'error' ;;
        *) printf 'ok' ;;
    esac
}

# Same mapping as the agents-dashboard (src/github/pr.ts): the first PR for the
# branch, any state, as "number<TAB>state<TAB>checks<TAB>review".
_PR_JQ='
def result: if (.conclusion // "") != "" then .conclusion else (.state // "") end | ascii_upcase;
.[0] // empty
| (.statusCheckRollup // []) as $checks
| [
    .number,
    (if .state == "MERGED" then "merged"
     elif .state == "CLOSED" then "closed"
     elif .isDraft then "draft"
     else "open" end),
    (if ($checks | length) == 0 then "none"
     elif any($checks[]; result | IN("FAILURE", "ERROR", "CANCELLED", "TIMED_OUT", "ACTION_REQUIRED", "STARTUP_FAILURE")) then "failing"
     elif any($checks[]; ((.status // "") | ascii_upcase | IN("IN_PROGRESS", "QUEUED")) or (result | IN("SUCCESS", "NEUTRAL", "SKIPPED") | not)) then "pending"
     else "passing" end),
    ({"APPROVED": "approved", "CHANGES_REQUESTED": "changes", "REVIEW_REQUIRED": "required"}[.reviewDecision // ""] // "none")
  ]
| @tsv'

plugin_collect() {
    local path branch
    path=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)
    [[ -d "$path" ]] || return 0
    branch=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null) || return 0

    local pr
    pr=$(cd "$path" && gh pr list --head "$branch" --state all --limit 1 \
        --json number,state,isDraft,reviewDecision,statusCheckRollup --jq "$_PR_JQ" 2>/dev/null)
    [[ -z "$pr" ]] && return 0

    local number state checks review
    IFS=$'\t' read -r number state checks review <<<"$pr"
    plugin_data_set "number" "$number"
    plugin_data_set "state" "$state"
    plugin_data_set "checks" "$checks"
    plugin_data_set "review" "$review"
}

plugin_render() {
    local text="#$(plugin_data_get "number")"
    local checks review
    checks=$(plugin_data_get "checks")
    review=$(plugin_data_get "review")

    # Passing and approved collapse into one ✓: "all good"
    [[ "$checks" == "passing" && "$review" == "approved" ]] && {
        printf '%s ✓' "$text"
        return
    }

    case "$checks" in
        passing) text+=" ✓" ;;
        failing) text+=" ✗" ;;
        pending) text+=" •" ;;
    esac
    case "$review" in
        approved) text+=" ✓" ;;
        changes) text+=" !" ;;
        required) text+=" ?" ;;
    esac
    printf '%s' "$text"
}

plugin_get_icon() {
    get_option "icon"
}
