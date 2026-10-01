---
name: worktree
description: Create and set up a new git worktree as a sibling of the current repo, branched off the default branch (main/master) by default — or off a given branch, tag, or PR. Names it after the repo plus a semantic extension derived from whatever content you give it, opens a detached tmux session on it via tmux-sessionizer, and starts a Claude session in its agents pane on the task. Use when the user invokes `/worktree`, or asks to spin up / create a worktree to work on something in isolation, on a specific branch, or to check out a PR.
argument-hint: "[the task to work on (also used to name the worktree/branch), and/or a base branch/tag/PR (optional)]"
---

# Create a worktree

Create and set up a fresh git worktree as a **sibling** of the current repo (one level up, not nested inside it), on a **new branch off the default branch**, then open a detached tmux session on it whose `agents` pane starts a Claude session on the task.

The argument serves two purposes: it **names** the worktree/branch and picks the **base**, and its task content becomes the **prompt** for the new Claude session. Never carry out the task in *this* session — the new session owns the work.

The mechanical part (creating the worktree, carrying over gitignored files, installing dependencies, opening tmux and starting Claude on the task) is done by the bundled script `${CLAUDE_SKILL_DIR}/scripts/worktree-create.ts` (`scripts/worktree-create.ts` in this skill's directory). The judgment around it — naming, picking the base, writing the task prompt — is done by a subagent.

## Delegate the whole thing to a subagent

Don't run the steps below in this session — spawn a subagent (via the `Agent` tool) and have it execute all of them, so their tool output doesn't clutter this conversation. It starts with no context, so write it a self-contained prompt: the argument verbatim, the current working directory, the script's absolute path, and (only if the argument's content alone doesn't yield a good semantic extension) whatever you can infer from the conversation to help name it. Tell it to carry out every step in this skill exactly as written and to reply with nothing but the result from step 6.

Once it finishes, relay that result to the user in one or two lines. Don't narrate its intermediate work.

## Steps

1. **Pick a semantic extension** — a short kebab-case slug describing the work (e.g. `auth-refactor`, `login-fix`, `docs`). Derive it from the argument's content or the current conversation. Only ask the user if there's genuinely nothing to infer it from. The worktree will live at `<parent of the main checkout>/<repo-name>-w-<extension>`.

   For a PR, derive it from the **PR's title/content** instead (`gh pr view <pr> --json title`) — e.g. "Add OAuth login flow" → `oauth-login`. Never use a bare `pr-<number>` slug; only fall back to the PR's branch name if the title yields nothing meaningful.

2. **Derive the branch name from the project's convention** (skip for a PR — it keeps its own branch). Inspect existing branches, including remotes, and match their style:
   - Conventional-commit style (`feat/…`, `fix/…`, `chore/…`, …): pick the type that fits and name it `<type>/<extension>`.
   - Otherwise mirror whatever the branches actually use (e.g. `feature/…`, a Jira-key prefix like `ABC-123-…`).
   - No discernible convention: just `<extension>`.

3. **Determine the base.** By default the script bases off the freshly fetched default branch — pass nothing. Only pass a base when the instruction names one (e.g. "based on `staging`", a tag). For a PR ("for PR 123", `#123`, a PR URL), pass the PR instead: it checks out the PR's own branch rather than creating a new one.

4. **Write the task prompt** for the new Claude session, which starts on it as its first message. Pass the user's task through as they phrased it — don't restate it as an instruction to create a worktree (the session will already be sitting in it), and drop the base-selection noise ("based on staging", "for PR 123") that only steered this skill. Mention the branch if that isn't obvious from the task.

   Also tell it to stop once the work is done: implement the task and leave the changes in the working tree, but don't commit, push, or open a PR. The user reviews the result first and asks for those separately. Only add this if the user's own task didn't already ask for a commit or PR.

   Write no prompt when the argument carries no actual task — a bare `/worktree`, or a PR checkout with nothing asked of it. The session then just starts empty, ready for the user.

5. **Run the script** from the current repo (any of its worktrees works — it anchors on the main checkout), passing the prompt as `--task` if there is one:
   ```sh
   <skill-dir>/scripts/worktree-create.ts --name <extension> --branch <branch-name> [--base <ref>] [--task <prompt>]
   <skill-dir>/scripts/worktree-create.ts --name <extension> --pr <number-or-url> [--task <prompt>]
   ```
   It refuses if the path or branch already exists — pick a different extension and rerun. It prints progress to stderr and a JSON summary to stdout with the worktree `path`, `branch`, `tmuxSession` and what it carried over. Don't redo any of its work by hand. For context, it:
   - carries over gitignored files matching its allowlist from the checkout of the base branch (the main checkout if the base isn't checked out anywhere): `.env*`, `config/local*.json` and `.claude/settings.local.json` are symlinked, `node_modules` folders are cloned copy-on-write; everything else that's ignored is left behind
   - only installs dependencies where a lockfile differs from the copied node_modules' origin
   - opens the tmux session with `tmux-sessionizer --detach`, so the user isn't pulled out of their current session, and starts Claude in its `agents` pane on the task

6. **Report the result** — keep it minimal: only the worktree directory name, the branch, and the tmux session name. Add a single extra line only if something went wrong (e.g. the script failed). The user jumps to it with `prefix + f` (or `tmux switch-client -t <session-name>`).

The skill ends here. The new session does the work; **don't start working on the task in this session**, and don't wait around for the other session to finish unless the user asks you to.
