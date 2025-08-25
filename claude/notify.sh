#!/bin/bash

input=$(cat)

session_id=$(echo "$input" | jq -r '.session_id')
transcript_path=$(echo "$input" | jq -r '.transcript_path')

path=$(pwd)
project_name=$(basename "$path")
project_category=$(basename "$(dirname "$path")")
subtitle="\[$project_category/$project_name]"
summary=$(head -n 1 "$transcript_path" | jq -r 'select(.type == "user") | .message.content' 2>/dev/null | cut -c 1-50)

if [[ -z "$summary" || "$summary" == "null" ]]; then
  message="Agent run complete"
else
  message="$summary"
fi

on_click="osascript -e 'tell application \"Ghostty\" to activate' -e 'tell application \"System Events\" to key code 49 using control down' -e 'tell application \"System Events\" to keystroke \":\"' -e 'delay 0.1' -e 'tell application \"System Events\" to keystroke \"switch-client -t ${project_name}:3\"' -e 'tell application \"System Events\" to key code 36'"

group_name="claude-$project_name-$session_id"

terminal-notifier \
  -title "Claude Code" \
  -subtitle "$subtitle" \
  -message "$message" \
  -group "$group_name" \
  -execute "$on_click" &> /dev/null
