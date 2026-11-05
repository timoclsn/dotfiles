---
name: rex-workarounds-check
description: Check the Rex release notes and feedback for changes that make one of this repo's Rex workarounds unnecessary, report what can be dropped, and update rex/WORKAROUNDS.md. Use when the user has updated Rex, asks what's new in Rex, or asks whether any Rex workaround can be removed.
---

# Rex workarounds check

`rex/WORKAROUNDS.md` lists everything we built or bent to get tmux behaviour in Rex, with
the upstream request behind each one and a "Last checked" line. This skill compares new
Rex releases against that list.

## Process

1. **Find the starting point.** Read `rex/WORKAROUNDS.md`: the "Last checked" line names
   the Mac and CLI versions already covered, and the tables say what each workaround
   is waiting for.
2. **Read the new releases.** Use the `superlogical` MCP (load its tools via ToolSearch).
   List the changelog and read every Mac and CLI post newer than the last check. Skip
   iOS and Linux server posts unless they touch something we use. If reading a post by
   version returns the wrong post, fall back to the link in the listing.
3. **Check feedback.** For each upstream request in the status table, search the feedback
   for its current status (active, accepted, deferred, completed). The search only matches
   single keywords, so try several words per topic. Treat "completed" as a candidate to
   drop, even if the changelog doesn't mention it.
4. **Match against our code.** For each candidate, look at the workaround itself
   (`rex/init.lua`, `nvim/plugin/rex-navigator.lua`, `scripts/rex-sessionizer`,
   `scripts/rex.ts`, the notify hooks) and confirm the new feature really covers what the
   workaround does. Beware of near misses: a CLI flag does not cover the Lua API, and a
   new command palette action is not a new keybinding option.
5. **Report in two parts.**
   1. First print the complete changelog post of the newest Mac version, verbatim, as
      the user can't see tool output. Don't summarise or shorten it, and don't print
      other releases (CLI posts are only used in the analysis).
   2. Then the analysis. Per workaround: droppable, not yet, or newly interesting, with
      the reason in one line. Add what we could adopt: new features from any of the
      releases that could replace something or improve our setup, even if they don't fit
      a workaround one-to-one.
6. **Update the notes.** Set the "Last checked" line to today and the versions covered,
   refresh the feedback status table, and add short notes for near misses so the next run
   doesn't re-investigate them.
7. **Only drop on approval.** If something is droppable, propose the removal (code, table
   rows, and any mentions in `CLAUDE.md`) and wait for the user before deleting. Remove
   the matching entries from `WORKAROUNDS.md` once it's done.

## Notes

- Some fixes need a server restart or a setting before they apply. Say so in the report.
- Don't commit unless asked.
