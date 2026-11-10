# Rex workarounds

Things we built or bent to get tmux behaviour in Rex. Check this list against the
Rex release notes now and then (the `superlogical` MCP has `list_changelog` /
`search_changelog`, and `search_feedback` shows what the team accepted). When a
release covers one, delete the workaround and its note here.

Last checked: 2026-11-06 against Mac preview.27 and CLI 01d6c4f (nothing droppable yet, see below).
preview.26 added `--interactive` for `rex run/split/new` (reads ~/.zshrc), but that is a CLI flag;
our `PATH` rebuild is for `rex.exec` in Lua, which it doesn't cover.
preview.27 has nothing on our list (remote uploads, Handoff, sidebar text size, `client.update.*`
actions, pane rename, crash fixes). Its server crash fix on restoring many terminals needs one
server restart. `client.update.*` is another Remote Control action, not a selection API.
The `superlogical` MCP's search only matches single keywords. `read_changelog` takes a
version only when it is the full string (`0.1.0-preview.27-1853-379536d`); the short
`0.1.0-preview.27` finds nothing. The message id from `list_changelog` also works.

## Status of upstream requests (as of 2026-11-06)

| Workaround | Feedback status |
| --- | --- |
| `last_tab`, `last_session`, history | "Focus last pane" is **accepted** and mentions `client.tab.last` and `session.last` as the same idea. "Switch back to the previous session" is **deferred**. "Go to previously active tab" and "Keybind to toggle back to the previously active tab, across sessions" are **active**. "Last session shortcut" is **deferred**. "Expose session last-accessed time (for MRU session ordering)" is **active** (would also cover `newest_session`-style needs). Not shipped. |
| `ctrl+h/j/k/l` and `rex-navigator.lua` | "Seamless ctrl-hjkl navigation (vim-tmux-navigator equivalent)" is **deferred** |
| `popup()` | "add tmux-style popups" is **accepted**. Not shipped. Related and **active**: a floating layer that closes on program exit doesn't return focus; "Lua API to show a native picker with custom items". **Accepted**: focus moves to the wrong pane when a floating pane's program exits |
| Key names and a tmux-style prefix | "Keybindings for tmux/herdr folk" is **active**. The team says they're working toward a tmux default and have a key-sequences docs page |
| Session metadata, selected session | "session metadata and selected-session visibility for tools built on Rex" is **active** |
| `session.select` through `rex.client.queue` | Bug "`session.select` errors with remote hosts" is **active**. Check it if we ever use remote hosts. "Queued session.select for a window created in the same action is dropped" is **active** too |
| Startup Command ignored after a server restart (fish trial) | Bug "Rex doesn't use configured startup command on server restart" is **active**. Updates restart the server, so the panes Rex reopens start zsh; new tabs start fish. More reports of the same, all still open: "Shell startup command not called after Rex Server restart" (**active**), "Terminals start default shell after upgrade" (**deferred**). Related: "Per-session startup command for new tabs" and "shell arg for client.tab.new" are **active** |
| `PATH` rebuilt in `run()` | "Rex does not export path to its binary" is **active**, but that is about the `rex` binary, not the server's PATH |
| `copy_path`, `copy_session_id` give no confirmation | "Let custom actions show a success notice" is **active** (asks for a `rex.client.notice{ ... }` call or a notice in `run`'s return value). Not shipped. Searching for `toast` finds the existing notices; they only exist for errors and built-in actions |

Nothing on tabs per session, sidebar sort, `grid`, `cycle_width`, the server PATH, or the pane cwd in `ctx` was found, in either the changelog or the feedback. Search again with other words before concluding they don't exist.

Related, shipped in preview.23: sessions now survive server restarts. That is not a workaround of ours, but it makes `~/.local/state/rex-history` less important. Session IDs are kept, so the history stays valid.

## Keymaps (`rex/init.lua`)

| Workaround | Why | Drop when Rex has |
| --- | --- | --- |
| `tab_goto` action (`prefix+1-9`) | Built-in tab actions count tabs across all sessions, tmux counts per session | Per-session tab actions, or a setting for it |
| `last_tab`, `last_session` actions, `remember()` history in memory + `~/.local/state/rex-history` | No focus history (tmux `prefix+l` / `prefix+L`) | A built-in last tab / last session action |
| `track_switch` wrapper around built-in `client.tab.new`, `session.switch` | Built-ins don't record where you came from, so the history above misses them. Clicking is only noticed on the next key | The same history feature as above |
| `newest_session` (`prefix+n`) | No "most recently created session" action; relies on session IDs starting with the creation time | Such an action |
| `sort_sessions` + sorting on `create_session` (attach and `session.move` each one) | No alphabetical sidebar order, only manual moves | A sidebar sort setting |
| `expand_sessions` action (`prefix+E`) | Rex has Expand Session for one session only, no expand-all | An expand-all sessions action |
| `close_pane` action (`prefix+x`) | Built-in `pane.close` does nothing on the only pane of a tab, tmux's kill-pane closes the window | `pane.close` closing the tab (or a setting for it) |
| `grid` action (`prefix++`) | No 2x2 split. Queues five pane actions | A grid / layout action |
| `equalize` action (`prefix+=`) | No even-sizes layout. Walks the layout tree and calls `resize_pane` per split | A pane size preset or equalize action |
| `cycle_width` action (`prefix+Z`) | No 1/3, 1/2, 2/3 cycle. Walks the layout tree and calls `resize_pane` | A pane size preset or cycle action |
| German layout key names: `alt+7` for `\|`, `shift+8` for `(`, `[Backquote]`, `[Backslash]` … | Keys without a Rex name need physical key codes or the modifier combo | Layout-aware key names |
| `ctrl+h/j/k/l` binding that checks `foreground(ctx)` and returns `false` for nvim/vim/view/fzf | Replaces vim-tmux-navigator: pass the key through to some programs | A per-program or conditional keybinding option |
| `diff` action (`prefix+d`) shells out to `rex split` through `rex_command` | Found no Lua call that splits a pane with a command and a working directory; the `pane.split.right` action takes neither | A split action or Lua call that takes a command and cwd |
| `popup()` helper using `new_layer` with `exit.on_completion` | No tmux `display-popup` equivalent for the fzf picker and lazygit. The lazygit action also toggles the layer with `set_layer_state` (minimize/restore) | A first-class popup/command-palette API |
| `sessionizer` passes `REX_CLIENT` of the app that pressed the key to the picker popup | The picker runs `rex do sessionizer dir=…` from the CLI, which only finds the app by itself when exactly one is connected ("no client is targeted" otherwise, e.g. with an iPhone attached or during an update relaunch) | Popups or CLI calls from a pane inheriting the client that opened them |
| `rex.client.queue("session.select", …)` to switch tabs and sessions | The app tracks the visible tab itself, so the server-side API can't switch it. Needs Remote Control on in Rex settings | Server-side session/tab selection that works without Remote Control |
| `open_repo`, `copy_path` use `foreground(ctx).cwd` | No `#{pane_current_path}` for key bindings | A pane cwd in the action context (`ctx`) |
| `copy_path` (`prefix+ctrl+y`) and `copy_session_id` (`prefix+shift+y`) copy with `pbcopy` and show no notice; built-in `pane.copy_id` (`prefix+y`) does | No Lua call posts a notice, only `error(…, 0)` does, and no client action copies an arbitrary string | A notice call for custom actions, or a copy-to-clipboard client action. Then add the notice to both actions |
| `restore-focus.lua`, started detached by `popup()` | When a popup's program exits, Rex focuses the last pane of the tab instead of the pane you were in (feedback: "Focus moves to the wrong pane when a floating pane's program exits", **accepted**). `rex.on`/`rex.wait` only work in scripts, not in `init.lua`, hence the separate script that waits for the popup's `block_closed` and calls `session.focus_block` | Rex returning focus to the previous pane itself |
| `PATH` rebuilt in `run()` | Rex server starts with a minimal PATH | The server inheriting the user's shell PATH |
| `rex_command`, the absolute path to the `rex` binary inside the Rex app | `popup()` needs `rex` to start `restore-focus.lua`, and the server's PATH has none. The path depends on Rex's install layout | The server exposing its own binary path ("Rex does not export path to its binary" is **active**) |
| `agent_command`: `fish -ic 'status job-control full; cc $argv; exec fish'` | The pane should stay open after the agent exits. Job control is needed so `cc` is the pane's foreground process, otherwise Rex doesn't recognise the agent or name the tab | Per-session startup command or an exit-behaviour setting that makes this unneeded |

## Around the config

- `scripts/rex-sessionizer` and the `sessionizer` action: Rex version of `tmux-sessionizer` (`--detach`, `--prompt`). The `session` and `session-remove` skills branch on Rex vs tmux. Drop when Rex has a built-in project picker.
- `nvim/plugin/rex-navigator.lua`: ctrl-hjkl hands over from Neovim splits to Rex via `rex focus`. Drop together with the `ctrl+h/j/k/l` binding when Rex handles pass-through to programs natively.
- `scripts/rex.ts` `runsInRex()` and the early return in the Claude, Codex, OpenCode and Pi notify hooks: Rex does its own agent notifications. Drop if Rex notifications become configurable or stop duplicating ours.
- Fish trial: Rex's Startup Command setting plus `exec fish` in `agent_command`. Not Rex-specific, ends with the shell trial. Until the server-restart bug above is fixed, panes that Rex reopens after an update start zsh; open a new tab to get fish.
- `rex-sessionizer` sets `FZF_DEFAULT_OPTS_FILE` because the popup doesn't load zshrc. Drop when popups run in the user's shell environment.
