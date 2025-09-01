---
description: implement jira ticket
---

Implement the following Jira ticket.

Ticket key: SF-$ARGUMENTS

- Use the Jira cli to get the ticket information `acli jira workitem view [Ticket key] --fields "*all"`
- Create a new branch (name should be the sanitized ticket title with the ticket key as prefix, e.g. "SF-100-datenabruf-inaktiv")
- Implement the ticket and verify it is working.
- Run typecheck, lint and test
- Commit the changes using conventional commit style
- Create a draft PR (using the GitHub cli "gh") with the commit name as the title (postfixed with the ticket key in square brackets "… [SF-100]"), a description in in german (what was changed and why) and assign it to myself (timoclsn)
