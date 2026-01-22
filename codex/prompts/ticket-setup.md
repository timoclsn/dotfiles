---
description: setup branch from jira ticket
argument-hint: <TICKET_NUMBER>
---

Setup a branch from the following Jira ticket.

Ticket key: SF-$ARGUMENTS

- Use the Jira cli to get the ticket information `acli jira workitem view [Ticket key] --fields "*all"`.
- Update the ticket state to "In Progress" and assign the ticket to myself `acli jira workitem transition --key "[Ticket key]" --status "In Progress"`, `acli jira workitem assign --key "[Ticket key]" --assignee "@me"`.
- Create a new branch (name should be my github username and the sanitized ticket title with the ticket key as prefix, e.g. "timoclsn/SF-100-datenabruf-inaktiv") from the "main"-branch.
