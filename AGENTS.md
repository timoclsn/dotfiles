# AGENTS.md

Personal macOS dotfiles. `setup.sh` symlinks each config from this repo to its place in `~/.config/`, `~/` and `~/.local/bin/`. Run it after adding a new config.

Tokyo Night is the theme everywhere (Ghostty, Neovim, Tmux, OpenCode).

## Formatting

After editing Lua files, format them with stylua (config in `.stylua.toml`). Mason installs it at `~/.local/share/nvim/mason/bin/stylua`; it is not on `PATH`.

## Shared AI config

`ai/AGENTS.md` is symlinked to `~/.claude/CLAUDE.md`, `~/.config/opencode/AGENTS.md`, `~/.codex/AGENTS.md` and `~/.pi/agent/AGENTS.md`. Editing it changes the instructions of every AI tool.

## Sessions

`scripts/tmux-sessionizer` and `scripts/rex-sessionizer` take the same arguments: a project directory (or none for the fzf picker), `--detach` and `--prompt <text>`. The `session` skill depends on this, so keep the two in sync. Switching the Rex app to the picked session from the popup needs Remote Control turned on in Rex's settings.

## Shells

zsh is the login shell and what agents and scripts use. fish is the interactive shell on trial. `zsh/zshrc` stays minimal so it starts in ~30ms: no Oh My Zsh, prompt, completion or fzf/zoxide.

- New PATH entries and env vars go into both shells.
- Aliases and functions go only into zsh if agents or scripts need them; everything else is fish only (`fish/config.fish`, one file per function in `fish/functions/`).
- Don't commit `fish/fish_variables`; fish writes it at runtime.

## Homebrew

`homebrew/Brewfile` lists only packages installed on purpose, grouped by topic with comments. Edit it by hand; never re-dump it. `scripts/update-tools` reports drift without changing anything.

- `brew bundle cleanup` and `dump` need `--tap --formula --cask`. Without them they also check Go and uv packages, which fails on mise shims that have no global version.
- Untrusted third-party taps make `check`, `cleanup` and `dump` silently skip packages or fail with "untrusted tap". Declare trust in the Brewfile (see its header), never via `brew trust`, and trust single packages rather than whole taps.

## Neovim

Plugins use `vim.pack` (Neovim 0.12). To add one:

- Add it to the single `vim.pack.add` call in `nvim/init.lua`. Plugins with a build step are handled by the `PackChanged` autocmd there.
- Configure it in its own file in `nvim/plugin/`, which Neovim sources at startup.
- Commit the updated `nvim/nvim-pack-lock.json`.

There is no lazy loading, so keep `plugin/` files cheap and defer heavy `require`s to the point of use.
