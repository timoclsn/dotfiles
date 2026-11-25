# Rex workarounds

Things we built or bent to get tmux behaviour in Rex. Check this list against the
Rex release notes now and then (the `superlogical` MCP has `list_changelog` /
`search_changelog`, and `search_feedback` shows what the team accepted). When a
release covers one, delete the workaround and its note here.

Last checked: 2026-11-24 against Mac preview.34 (embedded server preview.23) and Server & CLI preview.23. Dropped: `last_tab`/`last_session` history and `track_switch` (now `focus_history.reverse`), and `restore-focus.lua` (tested, focus returns after a popup closes).
`REX_SESSION` is no longer set in new terminals (Server & CLI preview.23); use `REX_BLOCK`, which `-s` accepts as a block ID. Our scripts are switched.
Server preview.22 adds a focus history (`focus_history.reverse`, filterable by session or window); `last_tab` and `last_session` use it, and the server also returns focus after closing a popup, tab or pane. Mac preview.34 builds Navigate Back / Forward on it (no default shortcut, replaces Go to Recent). Feedback "Focus last pane", "Equivalent of Tmux's last-pane/last-window/last-session", "Go to previously active tab" and "Focus moves to the wrong pane when a floating pane's program exits" are **completed**.
Other preview.34 items: Mark as Unread (`client.tab.unread`, ⌥⌘U), multi-select tabs, ⌘N is now New Session (prompts once about old shortcuts; our own binds stay), Server Version section in Settings, sub-agents no longer notify (helps our duplicate-notification story only if Rex's own agent notifications become configurable; they stay as they are). Server preview.23: `rex do`/`rex send` take larger arguments (1 MiB, `@FILE` or `-`), IPv6/space paths for ssh:// hosts, the Rex skill documents `rex -S ssh://HOST`.
Near misses: "Per-session startup command" and the startup-command-after-restart bugs are still **active** (no mention in preview.22/23/34). No notice/toast, clipboard write, popup API, conditional keybinding, session metadata or sidebar sort. `[IntlBackslash]` etc. unchanged.
Previously on 2026-11-19 (preview.33, embedded server preview.21; Server & CLI preview.21): nothing droppable.
preview.33 has nothing on our list: tabs along the bottom, New Session on Host…, a confirm before closing a tab with unseen output, file link and Quick Look fixes, per-terminal input source, the tab-switch focus/zoom fix, no cursor in exited panes.
Near misses: ⌃J/⌃K/⌃N/⌃P now move through rows of the command palette, session picker and Activity popup even when bound (our `ctrl+h/j/k/l` binding no longer gets in the way of `rex.ui.pick` lists); that is popup-only, not a conditional keybinding option, so the binding and `rex-navigator.lua` stay.  New Session on Host does not touch `session.select` on remote hosts.
Previously on 2026-11-19 (preview.32): `rex.ui.input` / `rex.ui.pick` are now in Preview (preview.32), so the project picker no longer needs the Bleeding Edge channel. Nothing else on our list is droppable.
Near misses: copy mode (⇧⌘C, `copy/` bindings in init.lua) is a terminal scrollback feature, not a copy-to-clipboard action, so `copy_path` and `copy_session_id` still need `pbcopy` and show no notice. Mute Tab is bindable (`client.tab.mute`), no workaround of ours. Server & CLI preview.21 adds `[IntlBackslash]`, `[IntlRo]` and `[IntlYen]` key names for ISO and JIS keyboards, but our German layout keys (`[Backquote]`, `[Backslash]`, `alt+7`) are not on that list. The preview.32 click-to-focus change and faster tab switches do not touch `track_switch`.
Previously on 2026-11-18 (preview.31, Server & CLI preview.21): `rex.ui` was on Bleeding Edge only; the project picker moved to it, which removed the sessionizer's fzf popup, the `REX_CLIENT` workaround (prompts go to every connected app) and `FZF_DEFAULT_OPTS_FILE`. `rex.ui` shows prompts, not notices, so it does not cover `update_rex`, `copy_path` or `copy_session_id`. It has no geometry control (feedback "rex.ui geometry", **active**), no custom keys, and no live filtering callback. The `popup()` helper stays for lazygit.
Earlier on 2026-11-16 (preview.31 and Server & CLI preview.20): nothing droppable.
preview.31 has nothing on our list: remote port forwarding via ⌘-click, `client.setting.*` actions for nearly every setting,
minimized floating window corners, Activity sidebar rows, font fallback for ⌘ ⌥ ⌃, shortcuts.json live reload. Server & CLI
preview.20 adds `ports` / `ports_changed` on terminal blocks, `rex forward open <block>`, modifyOtherKeys fixes for Option
characters, and restore-after-sleep fixes; nothing on Lua actions, startup commands or popups.
Near misses: `client.setting.*` actions (bindable via `rex.bind`/`rex do`) are settings toggles, not a conditional-keybinding
option, a notice call or a startup-command fix. They could replace shell-outs only if we ever toggle a setting from a key.
`ports` on blocks is new, but we have no port-related workaround. "Restored terminals get a second try with their saved state"
(preview.20) is about sleeping laptops, not the startup command bug. Shortcuts live reload does not touch `init.lua` keymaps.
Previously (2026-11-14, preview.30 and Server & CLI preview.19): nothing on our list (SSH agent picker, cursor shaders out of experimental, Quick Look always on, cursor
blinks only when the program asks for it, pane takeover fix). Server & CLI preview.19 adds `rex forward` (TCP port forwarding),
installer fixes and server shutdown/save fixes; nothing on Lua or startup commands.
Near misses: preview.19 makes a new server wait for the old one to finish saving (helps restarts, not the startup command bug);
`REX_SERVER` now behaves exactly like `--server`, which does not touch the `REX_CLIENT` targeting in `sessionizer`;
Previously (2026-11-12, preview.29 and Server & CLI preview.15 to 18): remote Quick Look and file opening, ssh question prompts
in the command palette, ⌘-drag to move panes, ssh reconnect fixes, ssh sharing, Linux cgroups and Windows groundwork.
Near misses then: `rex server start --env NAME[=VALUE]` (preview.17) only helps when we start the server ourselves, not when the
app does it, so the `PATH` rebuild stays. Preview.16 says server restarts will be very rare, which hides the startup command
bug but does not fix it. Settings => Integrations (preview.17, agent integrations and automatic session naming) might let
us configure Rex's own agent notifications, not checked in the app yet. Jump to Previous/Next Prompt (preview.16) can be bound by us.
Changelog gotcha: `read_changelog` with `0.1.0-preview.15` to `.18` returns the old Mac posts of the same number as well as the new
Server & CLI posts, because the Server & CLI numbering now overlaps the Mac one. Pick by platform and date.
Previously (2026-11-10, preview.28): toolbar/pane header hiding, Quick Look, AppleScript, Finder services,
floating window edge drag, settings reorganisation, tiling-WM fixes. AppleScript can run actions and
create sessions, but that is another outside-in control path, not a Lua API or a selection API.
Its fix for tabs and panes keeping titles while a session reconnects does not touch the startup command bug.
Previously (2026-11-06, preview.27 and CLI 01d6c4f):
preview.26 added `--interactive` for `rex run/split/new` (reads ~/.zshrc), but that is a CLI flag;
our `PATH` rebuild is for `rex.exec` in Lua, which it doesn't cover.
preview.27 has nothing on our list (remote uploads, Handoff, sidebar text size, `client.update.*`
actions, pane rename, crash fixes). Its server crash fix on restoring many terminals needs one
server restart. `client.update.*` is another Remote Control action, not a selection API.
The `superlogical` MCP's search only matches single keywords. `read_changelog` takes a
version only when it is the full string (`0.1.0-preview.27-1853-379536d`); the short
`0.1.0-preview.27` finds nothing. The message id from `list_changelog` also works.

## Status of upstream requests (as of 2026-11-24, after preview.34)

| Workaround | Feedback status |
| --- | --- |
| `ctrl+h/j/k/l` and `rex-navigator.lua` | "Seamless ctrl-hjkl navigation (vim-tmux-navigator equivalent)" is **deferred** |
| `popup()` | "add tmux-style popups" is **accepted**. Not shipped. Related and **active**: a floating layer that closes on program exit doesn't return focus; "Lua API to show a native picker with custom items" (shipped as `rex.ui.pick` in Preview 32, still listed as active). **Accepted**: focus moves to the wrong pane when a floating pane's program exits. The wrong-focus-after-popup-exit bugs are **completed**, so no focus workaround remains. Also **active**: "Focused floating layer clears pane zoom, and closing it doesn't restore it". New and **active** (2026-11-16): "Floating layers: support for maximum size", "Command Palette Customization". Also **deferred**: "Keep zoom when a floating layer takes focus" (lazygit over a zoomed pane), "When closing a floating pane, the focus doesn't return to the previously focused docked pane". **Active**: "rex.ui.pick: palette is slow to close after pressing Return" (affects the project picker) |
| Key names and a tmux-style prefix | "Keybindings for tmux/herdr folk" is **active**. The team says they're working toward a tmux default and have a key-sequences docs page |
| Session metadata, selected session | "session metadata and selected-session visibility for tools built on Rex" is **active**; "Add key-value metadata to blocks, sessions and windows" is **deferred** |
| `session.select` through `rex.client.queue` | Bug "`session.select` errors with remote hosts" is **active**. Check it if we ever use remote hosts. "Queued session.select for a window created in the same action is dropped" is **active** too |
| Startup Command ignored after a server restart (fish trial) | Bug "Rex doesn't use configured startup command on server restart" is **active**. Updates restart the server, so the panes Rex reopens start zsh; new tabs start fish. More reports of the same, all still open: "Shell startup command not called after Rex Server restart" (**active**), "Terminals start default shell after upgrade" (**deferred**), "First session launches with login shell instead of selected shell" (**deferred**). New report "When Rex restarts, it doesn't honor Startup command" (**deferred**). Related: "Per-session startup command for new tabs" and "shell arg for client.tab.new" are **active**. New and **active** (2026-11-14): "Server restart drops the Terminal startup command and opens zsh", "`rex split` opens user's login shell, not the configured startup shell" |
| `PATH` rebuilt in `run()` | "Rex does not export path to its binary" and "Rex cli not present in PATH" are **deferred**, and they are about the `rex` binary, not the server's PATH. Also **active**: "It would be nice to have rex cli available in the path outside rex terminals", "ssh:// host tunnel doesn't get the login PATH" |
| `copy_path`, `copy_session_id` give no confirmation; `update_rex` (`prefix+U`) says nothing when Rex is already up to date | "Let custom actions show a success notice" is **active**; new and **deferred**: "Feature request: public API for the in-app notice toast"; "Lua/API: write to the client clipboard (OSC 52 path)" is **active** and would cover the copy half (asks for a `rex.client.notice{ ... }` call or a notice in `run`'s return value). New and **active** (2026-11-16): "Let programs post Rex toasts". Also **active**: "Let remote processes read/write the client's clipboard". Not shipped. Searching for `toast` finds the existing notices; they only exist for errors and built-in actions |

Nothing on tabs per session, sidebar sort, `grid`, `cycle_width`, the server PATH, or the pane cwd in `ctx` was found, in either the changelog or the feedback. Search again with other words before concluding they don't exist.


## Keymaps (`rex/init.lua`)

| Workaround | Why | Drop when Rex has |
| --- | --- | --- |
| `tab_goto` action (`prefix+1-9`) | Built-in tab actions count tabs across all sessions, tmux counts per session | Per-session tab actions, or a setting for it |
| `update_rex` action (`prefix+U`) silently does nothing when Rex is up to date | Custom actions can't show a notice, and raising an error would show "Action failed". Replace the silent return with a "Rex is up to date" toast | A notice or toast call for custom actions |
| `newest_session` (`prefix+n`) | No "most recently created session" action; relies on session IDs starting with the creation time | Such an action |
| `sort_sessions` + sorting on `create_session` (attach and `session.move` each one) | No alphabetical sidebar order, only manual moves | A sidebar sort setting |
| `expand_sessions` action (`prefix+E`) | Rex has Expand Session for one session only, no expand-all | An expand-all sessions action |
| `close_pane` action (`prefix+x`) | Built-in `pane.close` does nothing on the only pane of a tab, tmux's kill-pane closes the window | `pane.close` closing the tab (or a setting for it) |
| `grid` action (`prefix++`) | No 2x2 split. Queues five pane actions | A grid / layout action |
| `equalize` action (`prefix+=`) | No even-sizes layout. Walks the layout tree and calls `resize_pane` per split | A pane size preset or equalize action |
| `cycle_width` action (`prefix+Z`) | No 1/3, 1/2, 2/3 cycle. Walks the layout tree and calls `resize_pane` | A pane size preset or cycle action |
| German layout key names: `alt+7` for `\|`, `shift+8` for `(`, `[Backquote]`, `[Backslash]` … | Keys without a Rex name need physical key codes or the modifier combo | Layout-aware key names |
| `ctrl+h/j/k/l` binding that checks `foreground(ctx)` and returns `false` for nvim/vim/view/fzf | Replaces vim-tmux-navigator: pass the key through to some programs | A per-program or conditional keybinding option |
| `diff` and `pr_diff` actions (`prefix+d`, `prefix+D`) shell out to `rex split` through `rex_command` | Found no Lua call that splits a pane with a command and a working directory; the `pane.split.right` action takes neither | A split action or Lua call that takes a command and cwd |
| `popup()` helper using `new_layer` with `exit.on_completion` | No tmux `display-popup` equivalent for lazygit (the project picker moved to `rex.ui.pick`). The lazygit action also toggles the layer with `set_layer_state` (minimize/restore) | A first-class popup/command-palette API |
| `rex.client.queue("session.select", …)` to switch tabs and sessions | The app tracks the visible tab itself, so the server-side API can't switch it. Needs Remote Control on in Rex settings | Server-side session/tab selection that works without Remote Control |
| `open_repo`, `copy_path` use `foreground(ctx).cwd` | No `#{pane_current_path}` for key bindings | A pane cwd in the action context (`ctx`) |
| `copy_path` (`prefix+ctrl+y`) and `copy_session_id` (`prefix+shift+y`) copy with `pbcopy` and show no notice; built-in `pane.copy_id` (`prefix+y`) does | No Lua call posts a notice, only `error(…, 0)` does, and no client action copies an arbitrary string | A notice call for custom actions, or a copy-to-clipboard client action. Then add the notice to both actions |
| `PATH` rebuilt in `run()` | Rex server starts with a minimal PATH | The server inheriting the user's shell PATH |
| `rex_command`, the absolute path to the `rex` binary inside the Rex app | `diff`/`pr_diff` and the pane capture need `rex`, and the server's PATH has none. The path depends on Rex's install layout | The server exposing its own binary path ("Rex does not export path to its binary" is **active**) |
| `agent_command`: `fish -ic 'status job-control full; cc $argv; exec fish'` | The pane should stay open after the agent exits. Job control is needed so `cc` is the pane's foreground process, otherwise Rex doesn't recognise the agent or name the tab | Per-session startup command or an exit-behaviour setting that makes this unneeded |

## Around the config

- `scripts/rex-sessionizer` and the `sessionizer` action: Rex version of `tmux-sessionizer` (`--detach`, `--prompt`). The `session` and `session-remove` skills branch on Rex vs tmux. The picker is `rex.ui.pick` (in Preview since preview.32). The script only passes arguments on. Drop when Rex has a built-in project picker.
- `copy_project_path` (`prefix+F`): replaces the `ctrl-y` copy of the old fzf picker, since `rex.ui.pick` has no custom keys.
- `nvim/plugin/rex-navigator.lua`: ctrl-hjkl hands over from Neovim splits to Rex via `rex focus`. Drop together with the `ctrl+h/j/k/l` binding when Rex handles pass-through to programs natively.
- `scripts/rex.ts` `runsInRex()` and the early return in the Claude, Codex, OpenCode and Pi notify hooks: Rex does its own agent notifications. Drop if Rex notifications become configurable or stop duplicating ours.
- Fish trial: Rex's Startup Command setting plus `exec fish` in `agent_command`. Not Rex-specific, ends with the shell trial. Until the server-restart bug above is fixed, panes that Rex reopens after an update start zsh; open a new tab to get fish.
