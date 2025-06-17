#!/bin/bash

DOTFILES="$HOME/Developer/personal/dotfiles"
echo "Setting up symlinks from $DOTFILES"

# Config directory symlinks
# alacritty
rm "$HOME/.config/alacritty" 2>/dev/null || true
ln -sf "$DOTFILES/alacritty" "$HOME/.config/alacritty"

# btop
rm "$HOME/.config/btop" 2>/dev/null || true
ln -sf "$DOTFILES/btop" "$HOME/.config/btop"

# ghostty
rm "$HOME/.config/ghostty" 2>/dev/null || true
ln -sf "$DOTFILES/ghostty" "$HOME/.config/ghostty"

# lazygit
rm "$HOME/.config/lazygit" 2>/dev/null || true
ln -sf "$DOTFILES/lazygit" "$HOME/.config/lazygit"

# nvim
rm "$HOME/.config/nvim" 2>/dev/null || true
ln -sf "$DOTFILES/nvim" "$HOME/.config/nvim"

# Home directory symlinks
ln -sf "$DOTFILES/aider/.aider.conf.yml" "$HOME/.aider.conf.yml"
ln -sf "$DOTFILES/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
ln -sf "$DOTFILES/zsh/.env" "$HOME/.env"
ln -sf "$DOTFILES/mcp/mcpservers.json" "$HOME/.mcpservers.json"
ln -sf "$DOTFILES/powerlevel10k/p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$DOTFILES/ripgrep/.rgignore" "$HOME/.rgignore"
ln -sf "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
ln -sf "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"

# codex
ln -sf "$DOTFILES/codex/config.json" "$HOME/.codex/config.json"
ln -sf "$DOTFILES/codex/config.toml" "$HOME/.codex/config.toml"
ln -sf "$DOTFILES/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"

# Scripts
mkdir -p "$HOME/.local/bin"
ln -sf "$DOTFILES/scripts/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
chmod +x "$HOME/.local/bin/tmux-sessionizer"
ln -sf "$DOTFILES/scripts/tmux-open-repo" "$HOME/.local/bin/tmux-open-repo"
chmod +x "$HOME/.local/bin/tmux-open-repo"
ln -sf "$DOTFILES/scripts/ai-commit" "$HOME/.local/bin/ai-commit"
chmod +x "$HOME/.local/bin/ai-commit"

echo "Symlinks created successfully!"
