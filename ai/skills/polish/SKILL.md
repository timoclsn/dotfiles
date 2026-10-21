---
name: polish
description: Run `/simplify`, then `/code-review --fix`, then `/security-review` on the current changes. Use when the user invokes `/polish`.
---

1. Invoke `simplify` with the user's target, if any.
2. Invoke `code-review --fix` with the same target and any other user arguments.
3. Invoke `security-review` on the same changes. Fix the findings you're confident about; leave the rest for the user.
4. Summarize changes and any unfixed findings.
