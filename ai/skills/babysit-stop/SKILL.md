---
name: babysit-stop
description: Stop a running babysit loop (babysit-ci, babysit-pr, or any /loop-driven watcher) in the current session. Ends the loop now — stops background monitors and does not schedule a new wake-up — and records the stop clearly in the conversation so an already-scheduled wake-up that fires later re-reads the history, sees it was stopped, and self-terminates instead of acting. Use when the user invokes `/babysit-stop` or asks to stop, halt, cancel, or end babysitting, the CI/PR babysit loop, or a self-paced loop that won't stop.
---

# Stop the babysit loop

The user wants the babysit loop in **this session** to stop. A babysit loop (babysit-ci, babysit-pr, or any `/loop`-driven watcher) is kept alive by two things: background monitor tasks, and a re-scheduled wake-up (`ScheduleWakeup`) that re-invokes the loop each round. Stopping means tearing both down.

There is no per-session flag file. The stop signal lives in the **conversation history**: a fired wake-up re-invokes the loop within this same session with the context preserved, so a clear "babysitting stopped by the user" statement in your response is what a later wake-up reads to know it should self-terminate. This is naturally scoped to this session — parallel babysits in other sessions have their own histories and are unaffected.

## Steps

1. **Stop running monitors.** Use `TaskList` to find running background tasks, and `TaskStop` each one that belongs to a babysit/loop/CI watcher (background `Bash`, `Monitor`, or workflow tasks polling CI/PR state). If unsure whether a task is part of the loop, prefer stopping watcher/poller tasks over leaving them running. Don't touch unrelated user tasks.

2. **Do not schedule a new wake-up.** End the loop: do **not** call `ScheduleWakeup` and do not start a new `/loop`. This turn is the last active round.

3. **Record the stop clearly and end the turn.** State explicitly that babysitting has been **stopped by the user** for this session and will not resume on its own. Phrase it unambiguously (e.g. "Babysitting stopped — I will not assess, fix, push, or reschedule, and any wake-up already scheduled will self-terminate when it fires.") so a later wake-up reading the history recognizes the stop. Briefly confirm what was torn down (monitors stopped, no new wake-up scheduled).

## When an already-scheduled wake-up fires later

A wake-up scheduled before the stop cannot be cancelled, so it will still fire and re-invoke the loop prompt. The babysit skills handle this: at the start of each round they review the conversation history and, if the user has asked to stop (a `/babysit-stop`, "stop", "halt", etc.) since the loop started, they do nothing and do not reschedule. So a stray wake-up self-terminates — you don't need to do anything else here.

To resume, the user explicitly starts babysitting again (`/babysit-ci` or `/babysit-pr`), which begins a new loop.
