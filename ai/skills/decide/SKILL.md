---
name: decisions
description: Surface open decisions that are the user's to make and ask them with the AskUserQuestion tool instead of guessing or burying them in prose. Use when the user invokes `/decisions`, or asks where their input is needed, which decisions are open, or to be asked rather than assumed.
---

# Decisions

Identify where you need a decision from the user and ask with the `AskUserQuestion` tool.

1. List the open decisions in the current task: choices you can't resolve from the request, the code, or sensible defaults.
2. Drop anything with a conventional default. Pick it, and mention it in your reply.
3. Ask the rest with `AskUserQuestion`, batched into one call.
   - Put your recommended option first, labelled "(Recommended)".
   - Give each option a short description of its trade-off.
4. Continue with the answers. Don't re-ask what's already been decided.
