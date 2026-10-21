---
name: polish
description: Run `/simplify`, then `/code-review` and `/security-review` in parallel, adversarially verify their findings, and fix the ones that hold up. Use when the user invokes `/polish`.
---

1. Invoke `simplify` with the user's target, if any.
2. Run `code-review` (with the user's target and any other arguments) and `security-review` (on the same changes) in parallel. Both only report; fixing happens in the next step.
3. Merge the findings and drop duplicates. Adversarially verify each one against the current code: try to refute it (stale, already handled, misread, or not applicable here), and fix the ones that survive.
4. Reply with one concise summary of what each step did: what `simplify` changed, what each review found, which findings were rejected and why, and what was fixed or left unfixed.
