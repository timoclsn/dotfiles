---
name: proof
description: Test the current changes fully end to end in this environment and deliver irrefutable proof that the change works and nothing else broke. Use when the user invokes `/proof`, or asks to prove a change works, test it end to end, or show it hasn't broken anything.
disable-model-invocation: true
argument-hint: "[optional: what to focus on]"
---

Test this fully end to end in here and provide irrefutable proof that it works and that you haven't broken anything.

$ARGUMENTS

Passing checks alone are not proof — run the real thing and show what you observed. If something can't be tested here, say so.
