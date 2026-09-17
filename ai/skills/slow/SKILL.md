---
name: slow
description: Diagnose why the Mac is currently running slow and propose concrete fixes. Use when the user invokes `/slow`, or asks things like "why is my mac slow", "my mac is slow", "check what's slowing my mac down", or reports sluggishness, fan noise, or a hot machine.
---

# Diagnose a slow Mac

Find the actual cause — don't guess. Work top-down: CPU/load, then memory, then disk
and thermals. Don't stop at the first mildly-high number; confirm it's the real outlier.

## 1. Headline numbers

- **Load average vs. core count** (`sysctl -n hw.ncpu`), across all three windows —
  a sustained excess is the real signal, not a 1-minute blip. Note uptime too; long
  uptimes accumulate cruft (step 4).
- **Top CPU** and **top memory** consumers as separate views — rarely the same process.
- **Swap and paging activity**, not just free RAM % — heavy swapping is a real cause
  even when "free memory" looks fine.

Use these to pick a branch: CPU/load problem, memory problem, or neither (→ step 4).

## 2. Abnormal CPU/load: find the cause

A single process rarely explains an order-of-magnitude-high load. Look for **process
count anomalies** — many instances of the same command — by grouping on parent PID
and command. This catches fork bombs and runaway background jobs a top-N CPU list
would spread thin and hide.

For any suspicious process: read its **full command line** (the name alone tells you
nothing), check its **working directory** to place which project it belongs to, and
if still unclear, **sample it** to see if it's genuinely busy or stuck spinning.

Leftover processes from a coding agent's shell sessions are a common, first-class
suspect — background dev servers, test watchers, or busy-loop scripts left running
by a script that never reached its cleanup step. Look for tells like shell-snapshot
sourcing in the command line, worktree paths in the cwd, or orphaned backgrounded
jobs, rather than dismissing these as generic "other apps."

## 3. Memory bottleneck

Identify top resident-memory processes, and separately confirm whether swapping is
happening *right now* — a process that allocated a lot once but is idle differs from
one actively thrashing swap.

## 4. CPU and memory both look normal

- **Disk space**: a nearly-full boot volume causes broad sluggishness.
- **Long-uptime cruft**: many orphaned/idle shells can accumulate over days of uptime;
  usually not the direct cause, but worth a "reboot would clean this up" note.
- **Thermal throttling**: for fan-noise/heat complaints, check thermal pressure state.

## 5. Report, then confirm before acting

State plainly what's consuming resources, why (command line/cwd/sample as evidence),
and whether it's safe to kill. Distinguish normal background noise (window server,
spotlight, browser helpers) from real anomalies.

Propose concrete fixes — kill specific PIDs, restart an app, free disk space, or
reboot for orphan accumulation. **Always ask before killing anything not unambiguously
yours to kill** — it may belong to in-progress work (another agent/dev-server session,
a test run). If unsure whose process it is, ask rather than assume it's abandoned.
