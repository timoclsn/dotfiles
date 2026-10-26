---
name: recap
description: Gather what the user did on a day or date range across GitHub and Slack and condense it into a short, skimmable list. Defaults to the previous workday, for daily standup. Use when the user invokes `/recap`, or asks what they did yesterday, on a given day or over a period, for a standup, a daily, a status update or a weekly recap.
argument-hint: "[date | date range]"
---

Build a short "what I did" list, by default for daily standup. This is **read-only**: don't post, comment, react or edit anything.

## Steps

1. **Pick the period.** With no argument, use the previous workday: on Monday that's Friday, otherwise yesterday. The argument can be a single day or a range, in any natural form: a date (`2026-03-03`), a weekday (`tuesday`, meaning the most recent one), a relative day (`2 days ago`), or a range (`monday to wednesday`, `2026-03-02..2026-03-04`, `last week`). Resolve it to concrete start and end dates in the user's local timezone and state them at the top. If it's ambiguous, pick the most recent past interpretation instead of asking.

2. **Gather activity from both sources in parallel.** Ignore activity outside the chosen period.
   - **GitHub** (`gh`, on the account from the global instructions): PRs the user opened, pushed to, merged or closed, and PRs by others they reviewed, approved or commented on. Search by date across all orgs, then check each PR to confirm what the user actually did in the period (their commits, their reviews, their merges), not just that the PR was updated.
   - **Slack** (Slack MCP): messages the user sent in the period, including threads and DMs. Look for decisions, help they gave, questions they raised, announcements and incidents. Skip greetings, emoji-only replies and small talk.

   If a source is unavailable or not authenticated, skip it and say so in one line at the end. Don't stop.

3. **Merge into themes.** Group by piece of work (a feature, ticket, incident or project), not by tool. A PR and the Slack thread about it belong in one line.

4. **Make it skimmable.** The user glances at this while talking, they don't read it. Optimize for finding the next thing to say at a glance:
   - One line per theme: a **bold label**, then 2–3 terse fragments separated by `·`. No full sentences, no explanations. Max ~12 words after the label.
   - Name things by their title, not their ID. The label is the ticket or project title, the fragments name PRs by title. Shorten titles to their recognizable core (drop conventional-commit prefixes and ticket keys). IDs only go in brackets after the title, as links: `CSV export (PROJ-123)`, `addressed review ([#412](…))`.
   - Lead each fragment with a verb in past tense ("shipped", "approved", "fixed").
   - 3–6 lines for a single day, up to ~10 for a range. For a range, still group by theme, not by day. Fold small items into one **Also** line.
   - End with an **Open** line: what's still in flight, as fragments too.
   - Nothing after the list except one line naming any source that couldn't be checked.

## Example output

```
**Tue, Mar 3**

- **Search filters** · addressed review · merged ([#412](…))
- **CSV export (PROJ-123)** · opened export PR · waiting for review ([#418](…))
- **Login alert** · traced to expired token · fixed on main · tuned alert
- **Reviews** · approved Alex's "cache user settings" ([#409](…))
- **Also** · answered a question on locale defaults

**Open** · CSV export review · follow up on the caching rollout
```
