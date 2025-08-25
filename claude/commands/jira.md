---
description: implement jira ticket
---

Implement the following ticket pulled from Jira.

Ticket key: SF-$ARGUMENTS

- Use the Jira cli to get the ticket information `acli jira workitem view [Ticket key] --fields "*all"`
- Create a new branch (name should be the sanitized ticket title with the ticket key as prefix, e.g. "SF-100-datenabruf-inaktiv")
- Implement the ticket and verify it is working.
- Run typecheck, lint and test
- Commit the changes using conventional commit style
- Create a PR (using the GitHub cli "gh") with the commit name as the title and a description (what was changed and why)
