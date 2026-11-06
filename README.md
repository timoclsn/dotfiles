# dotfiles

My macOS development environment, themed with Tokyo Night.

## Install

Install [Homebrew](https://brew.sh) first, clone to `~/Developer/personal/dotfiles` (`setup.sh` expects that path) and run:

```sh
./setup.sh
```

It symlinks the configs into `~/.config/` and `~/`, links the scripts into `~/.local/bin/`, and installs the missing Homebrew packages from `homebrew/Brewfile` (skipped when `brew` isn't installed). Run it again after adding a config.

## What's in here

- **Terminal:** [Rex](rex/), Ghostty and tmux, with fish as the interactive shell and zsh as the login shell for scripts and agents
- **Editor:** Neovim, with plugins managed by `vim.pack`
- **AI tools:** Claude Code, Codex, OpenCode and Pi, all sharing the instructions in `ai/AGENTS.md`
- **Everything else:** lazygit, fzf, starship, bat, btop, ripgrep, and `scripts/` with the project sessionizers and small utilities

Instructions for AI agents working in this repo are in [AGENTS.md](AGENTS.md).
