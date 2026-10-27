---
description: copy the current session ID to the clipboard
allowed-tools: Bash(printf:*), Bash(pbcopy:*)
---

!`printf %s "$CLAUDE_CODE_SESSION_ID" | pbcopy && printf %s "$CLAUDE_CODE_SESSION_ID"`

The session ID above has been copied to the clipboard. Reply with only: "Copied session ID `<id>`". Do nothing else.
