---
name: pr-comment
description: Post selected issues from an earlier list of possible PR problems as concise inline comments on a pending PR review. Use when the user invokes `/pr-comment` with issue numbers like `1,3,4 and 6`.
argument-hint: "<issue numbers, e.g. 1,3,4 and 6>"
---

Post the selected issues from the numbered list earlier in this conversation as inline comments on a **pending** review of that PR (or the current branch's PR).

Selected: $ARGUMENTS

- If there's no list or a number doesn't match, ask — don't guess.
- Anchor each comment to the best-fitting line in the PR diff. If none fits, use the closest changed line and mention it in your report.
- Keep comments concise.
- Create the review without an event and with an empty body. Never submit it. If a pending review already exists, add to it.
- Finish with a list of posted comments (number → `file:line`) and the PR link.
