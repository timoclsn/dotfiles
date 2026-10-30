# Rex workarounds

Things we built or bent to get tmux behaviour in Rex. Check this list against the
Rex release notes now and then (the `superlogical` MCP has `list_changelog` /
`search_changelog`, and `search_feedback` shows what the team accepted). When a
release covers one, delete the workaround and its note here.

Last checked: 2026-10-29 against Mac preview.23 (nothing droppable yet, see below).
The `superlogical` MCP's search only matches single keywords, and `read_changelog`
by id returned the latest post every time, so use `list_changelog` and read the posts
on Discord if a link matters.

## Status of upstream requests (as of 2026-10-29)

| Workaround | Feedback status |
| --- | --- |
| `last_tab`, `last_session`, history | "Focus last pane" is **accepted** and mentions `client.tab.last` and `session.last` as the same idea. "Switch back to the previous session" is **deferred**. Not shipped. |
| `ctrl+h/j/k/l` and `rex-navigator.lua` | "Seamless ctrl-hjkl navigation (vim-tmux-navigator equivalent)" is **deferred** |
| `popup()` | "add tmux-style popups" is **active** |
| Key names and a tmux-style prefix | "Keybindings for tmux/herdr folk" is **active**. The team says they're working toward a tmux default and have a key-sequences docs page |
| Session metadata, selected session | "session metadata and selected-session visibility for tools built on Rex" is **active** |
| `session.select` through `rex.client.queue` | Bug "`session.select` errors with remote hosts" is **active**. Check it if we ever use remote hosts |

Nothing on tabs per session, sidebar sort, `grid`, `cycle_width`, the server PATH, or the pane cwd in `ctx` was found, in either the changelog or the feedback. Search again with other words before concluding they don't exist.

Related, shipped in preview.23: sessions now survive server restarts. That is not a workaround of ours, but it makes `~/.local/state/rex-history` less important. Session IDs are kept, so the history stays valid.

## Keymaps (`rex/init.lua`)

| Workaround | Why | Drop when Rex has |
| --- | --- | --- |
| `tab_goto`, `tab_step` actions (`prefix+1-9`, `n`, `p`) | Built-in tab actions count tabs across all sessions, tmux counts per session | Per-session tab actions, or a setting for it |
| `last_tab`, `last_session` actions, `remember()` history in memory + `~/.local/state/rex-history` | No focus history (tmux `prefix+l` / `prefix+L`) | A built-in last tab / last session action |
| `track_switch` wrapper around built-in `client.tab.new`, `session.switch`, `session.previous/next`, `pane.move_to_new_tab` | Built-ins don't record where you came from, so the history above misses them. Clicking is only noticed on the next key | The same history feature as above |
| `newest_session` (`prefix+A`) | No "most recently created session" action; relies on session IDs starting with the creation time | Such an action |
| `sort_sessions` + sorting on `create_session` (attach and `session.move` each one) | No alphabetical sidebar order, only manual moves | A sidebar sort setting |
| `expand_sessions` action (`prefix+E`) | Rex has Expand Session for one session only, no expand-all | An expand-all sessions action |
| `close_pane` action (`prefix+x`) | Built-in `pane.close` does nothing on the only pane of a tab, tmux's kill-pane closes the window | `pane.close` closing the tab (or a setting for it) |
| `grid` action (`prefix++`) | No 2x2 split. Queues five pane actions | A grid / layout action |
| `cycle_width` action (`prefix+Z`) | No 1/3, 1/2, 2/3 cycle. Walks the layout tree and calls `resize_pane` | A pane size preset or cycle action |
| German layout key names: `alt+7` for `\|`, `shift+8` for `(`, `[Backquote]`, `[Backslash]` … | Keys without a Rex name need physical key codes or the modifier combo | Layout-aware key names |
| `ctrl+h/j/k/l` binding that checks `foreground(ctx)` and returns `false` for nvim/vim/view/fzf | Replaces vim-tmux-navigator: pass the key through to some programs | A per-program or conditional keybinding option |
| `popup()` helper using `new_layer` with `exit.on_completion` | No tmux `display-popup` equivalent for the fzf picker and agents dashboard | A first-class popup/command-palette API |
| `rex.client.queue("session.select", …)` to switch tabs and sessions | The app tracks the visible tab itself, so the server-side API can't switch it. Needs Remote Control on in Rex settings | Server-side session/tab selection that works without Remote Control |
| `open_repo`, `copy_path`, `diff` use `foreground(ctx).cwd` | No `#{pane_current_path}` for key bindings | A pane cwd in the action context (`ctx`) |
| `PATH` rebuilt in `run()` | Rex server starts with a minimal PATH | The server inheriting the user's shell PATH |
| `agent_command`: `fish -ic 'cc $argv; exec fish'` | The pane should stay open after the agent exits | Per-session startup command or an exit-behaviour setting that makes this unneeded |

## Around the config

- `scripts/rex-sessionizer` and the `sessionizer` action: Rex version of `tmux-sessionizer` (`--detach`, `--prompt`). The `session` and `session-remove` skills branch on Rex vs tmux. Drop when Rex has a built-in project picker.
- `nvim/plugin/rex-navigator.lua`: ctrl-hjkl hands over from Neovim splits to Rex via `rex focus`. Drop together with the `ctrl+h/j/k/l` binding when Rex handles pass-through to programs natively.
- `scripts/rex.ts` `runsInRex()` and the early return in the Claude, Codex, OpenCode and Pi notify hooks: Rex does its own agent notifications. Drop if Rex notifications become configurable or stop duplicating ours.
- Fish trial: Rex's Startup Command setting plus `exec fish` in `agent_command`. Not Rex-specific, ends with the shell trial.
- `rex-sessionizer` sets `FZF_DEFAULT_OPTS_FILE` because the popup doesn't load zshrc. Drop when popups run in the user's shell environment.
