# CLAUDE.md

This file provides guidance to an AI coding agent when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managing development environment configurations on macOS. Configurations are symlinked from this repo to their target locations via `setup.sh`.

## Setup & Installation

```bash
# Run setup script to create all symlinks
./setup.sh
```

The script symlinks configs to `~/.config/` and `~/` as appropriate. Scripts are installed to `~/.local/bin/`.

## Repository Structure

```
dotfiles/
├── ai/AGENTS.md          # Shared coding instructions (symlinked to Claude, OpenCode, Codex)
├── nvim/                 # Neovim config (Lua, vim.pack)
│   ├── init.lua          # Options/keymaps entry point + vim.pack plugin list
│   ├── plugin/           # One file per plugin, auto-sourced at startup
│   ├── ftplugin/         # Per-filetype settings
│   ├── lua/              # options, keymaps, commands + shared helpers
│   └── snippets/         # VSCode-format snippets, loaded by blink.cmp
├── tmux/tmux.conf        # Tmux config (prefix: Ctrl+Space)
├── rex/                  # Rex config (Lua), incl. a project sessionizer
├── ghostty/config        # Terminal emulator
├── zsh/zshrc             # Shell config (login shell, used by scripts and agents)
├── fish/                 # Interactive shell config (on trial next to zsh)
├── claude/               # Claude Code settings, hooks, commands
├── opencode/             # OpenCode IDE config
├── codex/                # Codex CLI config
├── pi/                   # Pi coding agent extensions
├── cursor/rules/         # Cursor IDE rules (14 TypeScript patterns)
├── scripts/              # Utility scripts (tmux-/rex-sessionizer, ai-commit, etc.)
└── setup.sh              # Symlink installer
```

## Key Commands

**Tmux prefix**: `Ctrl+Space`

| Binding       | Action                                    |
| ------------- | ----------------------------------------- |
| `prefix + f`  | Fuzzy project selector (tmux-sessionizer) |
| `prefix + '`  | Jump to dotfiles                          |
| `prefix + A`  | Jump to most recently created session     |
| `prefix + \|` | Split pane horizontally                   |
| `prefix + -`  | Split pane vertically                     |
| `prefix + r`  | Reload tmux config                        |
| `prefix + Z`  | Cycle pane width (1/3, 1/2, 2/3)          |

**Neovim leader**: `Space`

## Architecture Notes

### Configuration Sharing

- `ai/AGENTS.md` contains shared coding style guidelines
- Symlinked to `~/.claude/CLAUDE.md`, `~/.config/opencode/AGENTS.md`, `~/.codex/AGENTS.md`, and `~/.pi/agent/AGENTS.md`
- Changes to this file affect all AI tools

### Tmux Session Setup (tmux-sessionizer)

When creating a new project session, 4 windows are created:

1. **code** - Neovim
2. **source** - Lazygit
3. **agents** - Split pane with AI agent (left) + terminal (right)
4. **cmd** - General terminal

Called with no argument it opens an fzf project picker; with a directory it
targets that project directly. `--detach` sets the session up without attaching
or switching the client to it, leaves a freshly created session on the `agents`
window, and prints the session name. `--prompt <text>` starts the agent in a
newly created session with that text as its first message. Together they're how
the `worktree` skill prepares a session for a new worktree and hands it the task
without pulling the user out of their current one.

### Rex Session Setup (rex-sessionizer)

`rex/init.lua` ports the tmux setup to Rex: the same `ctrl+space` prefix and
key bindings (written for a German keyboard layout), and a `sessionizer` action
on `prefix + f` that opens `scripts/rex-sessionizer` (the fzf picker) in a
floating popup.

A new project session has a single window running the AI agent, and
sessions are kept sorted alphabetically in the sidebar. `rex-sessionizer` takes
the same arguments as tmux-sessionizer (a directory, `--detach`, `--prompt`);
the `worktree` skill uses rex-sessionizer instead of tmux-sessionizer when it
runs in a Rex terminal outside tmux. Switching the app to the picked session from the popup needs
Remote Control turned on in Rex's settings.

Rex has no focus history, so `rex/init.lua` keeps its own for `prefix + l` (last
tab of the session) and `prefix + L` (last session). Every action there that
switches tabs or sessions records where you came from, and `track_switch` wraps
built-in ones (`s`, `w`, `(`, `)`, `c`, `!`) to do the same. The history lives in
memory and in `~/.local/state/rex-history`. A switch made another way, like
clicking, is noticed the next time one of those keys runs.

### Shells (zsh and fish side by side)

fish is on trial as the interactive shell. Ghostty (`command`), tmux
(`default-command`), Rex (Startup Command in its Terminal settings) and the
Rex agent pane once `cc` exits (`exec fish` in `rex/init.lua`) start fish,
while zsh stays the login shell. So `zsh -ic`, the agents and scripts
keep using zsh, and `zsh/zshrc` stays complete. Removing
those settings switches back.

`fish/config.fish` mirrors `zsh/zshrc`, and each zsh helper function is a file
in `fish/functions/`. New aliases, PATH entries or functions go into both until
the trial ends. Don't commit `fish/fish_variables`; fish writes it at runtime.

### Claude Code Hooks

Located in `claude/hooks/`:

- `statusline.ts` - Custom status line showing model, tokens, cost
- `notify.ts` - macOS notifications on completion

### Neovim Plugin Organization

Plugins are installed with `vim.pack`, Neovim's built-in manager (requires 0.12).
The whole list lives in one `vim.pack.add` call in `nvim/init.lua`, and pinned
revisions are committed in `nvim/nvim-pack-lock.json`. Plugins that need a build
step (nvim-treesitter, fff.nvim) are handled by the `PackChanged` autocmd there.

Each plugin is then configured in its own file in `nvim/plugin/`, which Neovim
sources automatically at startup - there is no plugin-manager spec and no lazy
loading, so keep these files cheap and defer heavy `require`s to the point of
use. Examples:

- `lsp.lua` - Native LSP config, servers installed via Mason
- `blink-cmp.lua` - Completion
- `conform.lua` - Formatting
- `nvim-lint.lua` - Linting
- `gitsigns.lua` / `codediff.lua` - Git signs and diff review
- `fff.lua` / `telescope.lua` - File picker and everything-else picker

Useful commands: `:U`/`:Update` updates plugins, `:R`/`:Restart` restarts Neovim
and restores the session.

## Theme

Tokyo Night is used consistently across: Ghostty, Neovim, Tmux, OpenCode.
