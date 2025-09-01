---
description: implement jira ticket
---

Implement the following Jira ticket.

Ticket key: SF-$ARGUMENTS

- Use the Jira cli to get the ticket information `acli jira workitem view [Ticket key] --fields "*all"`.
- Update the ticket state to "in-progress" and assign the ticket to myself.
- Create a new branch (name should be the sanitized ticket title with the ticket key as prefix, e.g. "SF-100-datenabruf-inaktiv") from the "main"-branch.
- Implement the ticket and verify it is working.
- Run typecheck, lint and test.
- Use the @judge to do code review for the changes.
- Implement the code review feedbck if changes are necessary.
- Create a commit using conventional commit style.
- Create a draft PR (using the GitHub cli "gh") with the commit title as the PR title (postfixed with the ticket key in square brackets "… [SF-100]"), a description in in german (what was changed and why) and assign it to myself.
