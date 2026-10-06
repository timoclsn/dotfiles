---
name: polish
description: Run `/simplify`, then `/code-review --fix` on the current changes. Use when the user invokes `/polish`.
---

1. Invoke `simplify` with the user's target, if any.
2. Invoke `code-review --fix` with the same target and any other user arguments.
3. Summarize changes and any unfixed findings.
