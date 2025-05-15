# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository for configuring a developer environment on macOS, focusing on terminal-based tools. The main components include:

- Shell: zsh with Oh-My-Zsh and Powerlevel10k theme
- Terminal multiplexer: tmux with custom keybindings
- Text editor: Neovim with extensive plugin configuration
- Terminal emulators: WezTerm, Ghostty, Alacritty
- Git tools: lazygit
- File management: Yazi
- System monitoring: btop
- Package management: Homebrew (with a comprehensive Brewfile)

The configuration provides a cohesive terminal-focused development environment with a focus on efficiency, keyboard-driven workflows, and consistent theming (Tokyo Night).

## Setup Process

The setup process uses symlinks to connect the dotfiles in this repository to their expected locations:

```bash
# Run the setup script to create all symlinks
./setup.sh
```

This script:
1. Links directories to `~/.config/` for tools that use XDG config locations (neovim, alacritty, etc.)
2. Links individual files to the home directory for others (like `.zshrc`, `.tmux.conf`, etc.)
3. Installs scripts to `~/.local/bin/`

## Key Components

### tmux-sessionizer

The `tmux-sessionizer` script (`scripts/tmux-sessionizer`) provides a powerful session management system:

- Can be triggered with `Ctrl+F` from anywhere
- Creates project-specific sessions with standardized window layouts:
  - A 'code' window with neovim
  - A 'git' window with lazygit
  - A 'term' window for general terminal usage

### Terminal Environment

The zsh configuration (`zsh/zshrc`) includes several productivity-focused functions:

- `r`: Interactive npm script runner using fzf
- `n`: Node.js version manager using fnm
- `o`: Ollama model manager
- Homebrew package management: `bip`, `bup`, `bcp`
- Directory navigation with zoxide (aliased from `cd` to `z`)

### File Navigation

The dotfiles setup emphasizes fast file navigation:
- Uses zoxide for smart directory jumping
- Uses fzf for fuzzy finding with custom Tokyo Night theming
- Uses Yazi for terminal file management

## Common Commands

### Package Management

```bash
# Install brew packages interactively
bip

# Update brew packages interactively
bup

# Remove brew packages interactively
bcp

# Manage Node.js versions interactively
n

# Manage Ollama models interactively
o
```

### Session Management

```bash
# Launch tmux-sessionizer
tmux-sessionizer

# Within tmux, press Ctrl+F to launch tmux-sessionizer
# Within tmux, press Ctrl+Space as the prefix key (instead of Ctrl+B)
```

### Shell Commands

```bash
# Quick npm script execution
r

# Navigation aliases
z           # Smart cd using zoxide
..          # Go up one directory
...         # Go up two directories
d           # Go to ~/Developer
```

### Tmux Key Bindings

- `Ctrl+Space` is the prefix key (instead of the default `Ctrl+B`)
- `prefix |` to split window horizontally
- `prefix -` to split window vertically
- `prefix r` to reload tmux config
- Vim-style navigation with `prefix h/j/k/l` to resize panes
- `prefix ^` to switch to the last window
- `prefix <` and `prefix >` to reorder windows