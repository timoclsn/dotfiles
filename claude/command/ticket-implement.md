---
description: implement jira ticket
---

Implement the following Jira ticket.

Ticket key: SF-$ARGUMENTS

- Use the Jira cli to get the ticket information `acli jira workitem view [Ticket key] --fields "*all"`.
- Update the ticket state to "In Progress" and assign the ticket to myself `acli jira workitem transition --key "[Ticket key]" --status "In Progress"`, `acli jira workitem assign --key "[Ticket key]" --assignee "@me"`.
- Create a new branch (name should be the sanitized ticket title with the ticket key as prefix, e.g. "SF-100-datenabruf-inaktiv") from the "main"-branch.
- Create a plan on how to implement the ticket.
- Implement on the plan for the ticket.
- Very your implementation is working (e.g. run typecheck, lint and test).
- Use the judge subagent to do code review for the changes.
- Implement the code review feedbck if changes are necessary.
- Create a commit using conventional commit style.
- Create a draft PR (using the GitHub cli "gh") with the commit title as the PR title (postfixed with the ticket key in square brackets "… [SF-100]"), a description in in german (what was changed and why) and assign it to myself.
