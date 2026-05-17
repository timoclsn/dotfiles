---
name: diff-comments
description: Process review comments saved by comview from `.comview/comments.json` — work through each draft, apply the change (or answer the question), and delete the entry as it's resolved. Supports two modes: local (default, edits files in the working copy) and PR mode (`/diff-comments <PR#>`, read-only Q&A against `gh pr diff <N>`). Use when the user asks to address comview comments, work through review notes, or act on `.comview/comments.json`.
argument-hint: "[PR number (optional)]"
---

# comview comments

comview is a TUI for reviewing diffs. It stores the user's review comments as JSON at `.comview/comments.json` (relative to the repo root). Your job is to read those comments, address each one, and delete the entry from the file as you finish — so what's left in the file is always "still to do."

## Modes

The skill takes an optional PR number argument that decides which code the comments anchor to:

- **Local mode (no argument)** — the user reviewed the local working copy. `path` + `line` resolve against files on disk. You may edit files.
- **PR mode (`/diff-comments 540`)** — the user reviewed a PR's diff via `gh pr diff 540 | comview` without checking the branch out. The local working copy does **not** match. Fetch the diff with `gh pr diff <N>` and treat that as ground truth for what the comments refer to. **Read-only**: do not edit any files. Answer/discuss in chat only. If the user wants you to make changes, tell them to `gh pr checkout <N>` first and re-run without the argument.

The PR number, if any, will be in `$ARGUMENTS`.

## File shape

```json
{
  "version": 1,
  "comments": [
    {
      "path": "tui/app.go",
      "line": 4685,
      "side": "RIGHT",
      "start_line": 4683,
      "start_side": "RIGHT",
      "body": "the user's note"
    }
  ]
}
```

Fields you care about:

- `path` — file the comment is on, relative to repo root.
- `line` + `side` — anchor line. `RIGHT` is the new/post-change side; `LEFT` is the removed/old side.
- `start_line` + `start_side` — present when the comment spans multiple lines.
- `body` — the user's note. Usually an instruction ("rename this to X", "extract this into a helper"), sometimes a question ("why are we doing it this way?"), sometimes an observation. Handle each kind differently — see Workflow.

Other fields (`id`, `github_id`, `diff_hunk`, `commit_id`, `original_commit_id`, `start_column`, `end_column`) may be present — preserve them on entries you don't touch, but don't rely on them.

## Workflow

1. **Determine the mode.** If `$ARGUMENTS` contains a PR number, you're in PR mode — run `gh pr diff <N>` once up front and keep it in context as the source of truth. Otherwise you're in local mode.
2. **Read** `.comview/comments.json`. If the file is missing or `comments` is empty, tell the user there's nothing to do and stop.
3. **Process comments one at a time, top of the array first.** For each:
   1. Locate the target code:
      - **Local mode** — open `path` and find the code at/around `line` on the given `side`.
      - **PR mode** — find `path` in the fetched PR diff and locate the hunk containing `line` on `side` (RIGHT = added/context, LEFT = removed).
   2. Classify the body and act. Don't narrate the classification ("this is a question, so I'll..."); just do the thing:
      - **Instruction** — local mode: apply the change (ask first if ambiguous). PR mode: don't edit; describe in chat what the change would be and remind the user to check the branch out if they want it applied.
      - **Question** — answer it in chat.
      - **Observation with no clear ask** — surface it and propose what (if anything) you'd do.
   3. **Delete that entry from the `comments` array and save the file immediately** — every processed comment is deleted, whether you edited code, answered a question, or just responded to an observation. The chat is the record; the file only tracks what's still to do. Save before moving on so the file stays accurate if you're interrupted.
   4. Briefly note what you did (one line) so the user can follow along.
4. **When you've been through every comment, write a final summary.** One section per comment in original order:
   - File + line (e.g. `tui/app.go:4685`)
   - One-line paraphrase of the comment
   - What you did: `edited` (with a short description of the change), `answered` (with the answer in one line), or `noted` (for observations)

   End with totals: how many edited, how many answered, how many noted, and whether anything still needs the user's decision or a follow-up.

5. Don't delete the file itself or change `version` / `source`; comview reuses them.

## Rules

- Never reorder or rewrite entries you aren't actively resolving — only delete the one you just handled.
- Preserve the JSON shape: keep `version` and `source`, keep unrelated fields on remaining entries. Don't normalize the file.
- If a comment's target code is gone (refactored away, file deleted), surface it and ask whether to delete the entry or skip — don't silently drop it.
- Don't run comview, commit, or push. Just edit code and update the JSON.
