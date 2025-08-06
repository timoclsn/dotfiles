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

# opencode
ln -sf "$DOTFILES/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
ln -sf "$DOTFILES/agents/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
rm "$HOME/.config/opencode/agent" 2>/dev/null || true
ln -sf "$DOTFILES/opencode/agent" "$HOME/.config/opencode/agent"
rm "$HOME/.config/opencode/plugin" 2>/dev/null || true
ln -sf "$DOTFILES/opencode/plugin" "$HOME/.config/opencode/plugin"

# claude code
ln -sf "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
ln -sf "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
rm "$HOME/.config/claude/agents" 2>/dev/null || true
ln -sf "$DOTFILES/claude/agents" "$HOME/.claude/agents"
rm "$HOME/.config/claude/commands" 2>/dev/null || true
ln -sf "$DOTFILES/claude/commands" "$HOME/.claude/commands"

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
ln -sf "$DOTFILES/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sf "$DOTFILES/codex/notify.py" "$HOME/.codex/notify.py"


# Scripts
mkdir -p "$HOME/.local/bin"
ln -sf "$DOTFILES/scripts/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
chmod +x "$HOME/.local/bin/tmux-sessionizer"
ln -sf "$DOTFILES/scripts/tmux-open-repo" "$HOME/.local/bin/tmux-open-repo"
chmod +x "$HOME/.local/bin/tmux-open-repo"
ln -sf "$DOTFILES/scripts/ai-commit" "$HOME/.local/bin/ai-commit"
chmod +x "$HOME/.local/bin/ai-commit"
ln -sf "$DOTFILES/scripts/update-global-packages" "$HOME/.local/bin/update-global-packages"
chmod +x "$HOME/.local/bin/update-global-packages"

echo "Symlinks created successfully!"
