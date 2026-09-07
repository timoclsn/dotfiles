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
├── ghostty/config        # Terminal emulator
├── zsh/zshrc             # Shell config
├── claude/               # Claude Code settings, hooks, commands
├── opencode/             # OpenCode IDE config
├── codex/                # Codex CLI config
├── cursor/rules/         # Cursor IDE rules (14 TypeScript patterns)
├── scripts/              # Utility scripts (tmux-sessionizer, ai-commit, etc.)
└── setup.sh              # Symlink installer
```

## Key Commands

**Tmux prefix**: `Ctrl+Space`

| Binding       | Action                                    |
| ------------- | ----------------------------------------- |
| `prefix + f`  | Fuzzy project selector (tmux-sessionizer) |
| `prefix + '`  | Jump to dotfiles                          |
| `prefix + \|` | Split pane horizontally                   |
| `prefix + -`  | Split pane vertically                     |
| `prefix + r`  | Reload tmux config                        |
| `prefix + Z`  | Cycle pane width (1/3, 1/2, 2/3)          |

**Neovim leader**: `Space`

## Architecture Notes

### Configuration Sharing

- `ai/AGENTS.md` contains shared coding style guidelines
- Symlinked to `~/.claude/CLAUDE.md`, `~/.config/opencode/AGENTS.md`, and `~/.codex/AGENTS.md`
- Changes to this file affect all AI tools

### Tmux Session Setup (tmux-sessionizer)

When creating a new project session, 4 windows are created:

1. **code** - Neovim
2. **git** - Lazygit
3. **agent** - Split pane with AI agent (left) + terminal (right)
4. **term** - General terminal

### Claude Code Hooks

Located in `claude/hooks/`:

- `statusline.ts` - Custom status line showing model, tokens, changes
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
