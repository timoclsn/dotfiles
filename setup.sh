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

# fish
rm "$HOME/.config/fish" 2>/dev/null || true
ln -sf "$DOTFILES/fish" "$HOME/.config/fish"

# lazygit
rm "$HOME/.config/lazygit" 2>/dev/null || true
ln -sf "$DOTFILES/lazygit" "$HOME/.config/lazygit"

# fzf
rm "$HOME/.config/fzf" 2>/dev/null || true
ln -sf "$DOTFILES/fzf" "$HOME/.config/fzf"

# nvim
rm "$HOME/.config/nvim" 2>/dev/null || true
ln -sf "$DOTFILES/nvim" "$HOME/.config/nvim"

# rex
rm "$HOME/.config/rex" 2>/dev/null || true
ln -sf "$DOTFILES/rex" "$HOME/.config/rex"

# bat
rm "$HOME/.config/bat" 2>/dev/null || true
ln -sf "$DOTFILES/bat" "$HOME/.config/bat"

# opencode
ln -sf "$DOTFILES/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
ln -sf "$DOTFILES/ai/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
rm "$HOME/.config/opencode/agent" 2>/dev/null || true
ln -sf "$DOTFILES/opencode/agent" "$HOME/.config/opencode/agent"
rm "$HOME/.config/opencode/plugin" 2>/dev/null || true
ln -sf "$DOTFILES/opencode/plugin" "$HOME/.config/opencode/plugin"
rm "$HOME/.config/opencode/command" 2>/dev/null || true
ln -sf "$DOTFILES/opencode/command" "$HOME/.config/opencode/command"
rm "$HOME/.config/opencode/tool" 2>/dev/null || true
ln -sf "$DOTFILES/opencode/tool" "$HOME/.config/opencode/tool"
rm "$HOME/.config/opencode/skills" 2>/dev/null || true
ln -sf "$DOTFILES/ai/skills" "$HOME/.config/opencode/skills"

# claude code (work login in ~/.claude, personal login in ~/.claude-personal; same config)
for claude_dir in "$HOME/.claude" "$HOME/.claude-personal"; do
  mkdir -p "$claude_dir"
  ln -sf "$DOTFILES/claude/settings.json" "$claude_dir/settings.json"
  ln -sf "$DOTFILES/claude/keybindings.json" "$claude_dir/keybindings.json"
  ln -sf "$DOTFILES/ai/AGENTS.md" "$claude_dir/CLAUDE.md"
  rm "$claude_dir/agents" 2>/dev/null || true
  ln -sf "$DOTFILES/claude/agents" "$claude_dir/agents"
  rm "$claude_dir/commands" 2>/dev/null || true
  ln -sf "$DOTFILES/claude/commands" "$claude_dir/commands"
  rm "$claude_dir/hooks" 2>/dev/null || true
  ln -sf "$DOTFILES/claude/hooks" "$claude_dir/hooks"
  rm "$claude_dir/themes" 2>/dev/null || true
  ln -sf "$DOTFILES/claude/themes" "$claude_dir/themes"
  rm "$claude_dir/skills" 2>/dev/null || true
  ln -sf "$DOTFILES/ai/skills" "$claude_dir/skills"
done

# Home directory symlinks
ln -sf "$DOTFILES/aider/.aider.conf.yml" "$HOME/.aider.conf.yml"
ln -sf "$DOTFILES/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
ln -sf "$DOTFILES/zsh/.env" "$HOME/.env"
ln -sf "$DOTFILES/mcp/mcpservers.json" "$HOME/.mcpservers.json"
ln -sf "$DOTFILES/powerlevel10k/p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$DOTFILES/ripgrep/.rgignore" "$HOME/.rgignore"
ln -sf "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
ln -sf "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
# Stops macOS `login` from printing "Last login: ..." in every new terminal
touch "$HOME/.hushlogin"

# codex
ln -sf "$DOTFILES/codex/config.toml" "$HOME/.codex/config.toml"
ln -sf "$DOTFILES/ai/AGENTS.md" "$HOME/.codex/AGENTS.md"
rm "$HOME/.codex/prompts" 2>/dev/null || true
ln -sf "$DOTFILES/codex/prompts" "$HOME/.codex/prompts"
rm "$HOME/.codex/hooks" 2>/dev/null || true
ln -sf "$DOTFILES/codex/hooks" "$HOME/.codex/hooks"
rm "$HOME/.codex/skills" 2>/dev/null || true
ln -sf "$DOTFILES/ai/skills" "$HOME/.codex/skills"

# agents / pi
mkdir -p "$HOME/.agents"
rm -rf "$HOME/.agents/skills" 2>/dev/null || true
ln -sf "$DOTFILES/ai/skills" "$HOME/.agents/skills"
mkdir -p "$HOME/.pi/agent"
ln -sf "$HOME/.agents/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
rm -rf "$HOME/.pi/agent/extensions" 2>/dev/null || true
ln -sf "$DOTFILES/pi/extensions" "$HOME/.pi/agent/extensions"


# docker
mkdir -p "$HOME/.docker"
ln -sf "$DOTFILES/docker/config.json" "$HOME/.docker/config.json"

# colima
mkdir -p "$HOME/.config/colima/default"
ln -sf "$DOTFILES/colima/colima.yaml" "$HOME/.config/colima/default/colima.yaml"

# tmux-powerkit only loads plugins from its own folder (installed by TPM, so re-run after the first TPM install)
POWERKIT_PLUGINS="$HOME/.tmux/plugins/tmux-powerkit/src/plugins"
if [ -d "$POWERKIT_PLUGINS" ]; then
  for plugin in "$DOTFILES"/tmux/powerkit/*.sh; do
    ln -sf "$plugin" "$POWERKIT_PLUGINS/$(basename "$plugin")"
  done
fi

# Scripts
mkdir -p "$HOME/.local/bin"
ln -sf "$DOTFILES/scripts/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
chmod +x "$HOME/.local/bin/tmux-sessionizer"
ln -sf "$DOTFILES/scripts/rex-sessionizer" "$HOME/.local/bin/rex-sessionizer"
chmod +x "$HOME/.local/bin/rex-sessionizer"
ln -sf "$DOTFILES/scripts/tmux-open-repo" "$HOME/.local/bin/tmux-open-repo"
chmod +x "$HOME/.local/bin/tmux-open-repo"
ln -sf "$DOTFILES/scripts/ai-commit" "$HOME/.local/bin/ai-commit"
chmod +x "$HOME/.local/bin/ai-commit"
ln -sf "$DOTFILES/scripts/update-global-packages" "$HOME/.local/bin/update-global-packages"
chmod +x "$HOME/.local/bin/update-global-packages"
ln -sf "$DOTFILES/scripts/claude-budget.ts" "$HOME/.local/bin/claude-budget"
chmod +x "$HOME/.local/bin/claude-budget"
ln -sf "$DOTFILES/scripts/claude-config-dir" "$HOME/.local/bin/claude-config-dir"
chmod +x "$HOME/.local/bin/claude-config-dir"
echo "Symlinks created successfully!"
