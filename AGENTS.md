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
├── nvim/                 # Neovim config (Lua, lazy.nvim)
│   └── lua/
│       ├── config/       # Core: options, keymaps, lazy loader
│       └── plugins/      # One file per plugin/feature
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

Each plugin/feature has its own file in `nvim/lua/plugins/`:

- `lsp.lua` - LSP with Mason
- `completion.lua` - Blink.cmp
- `format.lua` - Conform.nvim
- `lint.lua` - nvim-lint
- `git.lua` - Gitsigns, Diffview

## Theme

Tokyo Night is used consistently across: Ghostty, Neovim, Tmux, OpenCode.
