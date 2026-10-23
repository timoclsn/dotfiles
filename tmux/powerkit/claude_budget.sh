#!/usr/bin/env bash
# =============================================================================
# Plugin: claude_budget
# Description: Claude usage for the account of the current pane's project
#
# Lives in the dotfiles and is symlinked into tmux-powerkit's plugin folder by
# setup.sh, because powerkit only loads plugins from there. The numbers come
# from the `claude-budget` script, which fetches the official usage each time
# powerkit collects (see cache_ttl). `claude-config-dir` picks the account the
# same way the `claude` wrapper does: work projects show the spend vs. the
# Enterprise spend limit, personal projects the subscription's 5-hour and
# weekly usage.
# =============================================================================

POWERKIT_ROOT="${POWERKIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "${POWERKIT_ROOT}/src/contract/plugin_contract.sh"

plugin_get_metadata() {
    metadata_set "id" "claude_budget"
    metadata_set "name" "Claude Budget"
    metadata_set "description" "Claude usage for the current project's account"
}

plugin_declare_options() {
    declare_option "icon" "icon" "✽" "Plugin icon"
    # Each collect asks the API, so this is also how often the usage is fetched.
    # It's one cache for all sessions, so after switching between a work and a
    # personal session the segment can show the other account for up to this long.
    declare_option "cache_ttl" "number" "300" "Cache duration in seconds"
}

plugin_get_content_type() { printf 'dynamic'; }
plugin_get_presence() { printf 'always'; }
plugin_get_state() { printf 'active'; }

plugin_get_health() {
    local health
    health=$(plugin_data_get "health")
    printf '%s' "${health:-ok}"
}

plugin_collect() {
    local path config_dir output
    path=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)
    config_dir=$(claude-config-dir "$path")
    output=$(CLAUDE_CONFIG_DIR="$config_dir" claude-budget status 2>/dev/null) || return 1
    plugin_data_set "health" "${output%%$'\t'*}"
    plugin_data_set "summary" "${output#*$'\t'}"
}

plugin_render() {
    plugin_data_get "summary"
}

plugin_get_icon() {
    get_option "icon"
}
