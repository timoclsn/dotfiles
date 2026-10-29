# Fish counterpart of zsh/zshrc. Both are kept side by side while fish is on
# trial: terminals start fish, but zsh stays the login shell, so scripts and
# agents (which run `zsh -ic`) keep working unchanged.

set -g fish_greeting

# =============================================================================
# Environment Variables
# =============================================================================
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx EDITOR nvim
set -gx GOPRIVATE 'github.com/steuerbot/*,github.com/taxfix/*'
set -gx ANDROID_SDK_ROOT $HOME/Library/Android/sdk
set -gx PNPM_HOME $HOME/Library/pnpm
set -gx BUN_INSTALL $HOME/.bun
set -gx PYENV_ROOT $HOME/.pyenv
# fzf tokyonight theme and default options, shared with zsh and scripts.
# No comments in that file: fish's fzf integration joins it into one line.
set -gx FZF_DEFAULT_OPTS_FILE $HOME/.config/fzf/fzfrc

# Its lines are `export KEY=value`, which fish understands too
test -f $HOME/.env; and source $HOME/.env

# -P edits PATH directly instead of the persisted fish_user_paths variable,
# so this file stays the only place PATH is defined
fish_add_path -P $HOME/.cargo/bin

# What `brew shellenv` prints, written out to skip running brew on every start
set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_CELLAR $HOMEBREW_PREFIX/Cellar
set -gx HOMEBREW_REPOSITORY $HOMEBREW_PREFIX
contains -- $HOMEBREW_PREFIX/share/info $INFOPATH
or set -gx INFOPATH $HOMEBREW_PREFIX/share/info $INFOPATH
fish_add_path -P --move $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin

# Tools managed by mise, ahead of Homebrew's versions
fish_add_path -P $HOME/.local/share/mise/shims

# First-wins order, the reverse of the prepends in zsh/zshrc
fish_add_path -P \
    $HOME/.opencode/bin \
    # Shims instead of `rbenv init`/`pyenv init` (~130ms per start); this only
    # loses `rbenv shell`, `pyenv shell` and pyenv's completions
    $HOME/.rbenv/shims \
    $PYENV_ROOT/shims \
    $PYENV_ROOT/bin \
    $HOME/.turso \
    $BUN_INSTALL/bin \
    $HOME/.npm-global/bin \
    $PNPM_HOME/bin \
    $HOMEBREW_PREFIX/opt/ruby/bin \
    $HOME/.local/bin
fish_add_path -P --append \
    $ANDROID_SDK_ROOT/emulator \
    $ANDROID_SDK_ROOT/platform-tools \
    $HOME/.lmstudio/bin \
    /Applications/Obsidian.app/Contents/MacOS

fnm env --shell fish | source

if not status is-interactive
    return
end

# =============================================================================
# Abbreviations (expand as you type, so history keeps the full command)
# =============================================================================
# Shell
abbr -a s 'source ~/.config/fish/config.fish'
abbr -a e exit

# Navigation (fish cds into a bare directory path like `..` on its own)
abbr -a -- ... ../..
abbr -a -- .... ../../..
abbr -a -- ..... ../../../..
abbr -a h 'cd ~'
abbr -a b 'cd -'
abbr -a d 'cd ~/Developer'
abbr -a sbf 'cd ~/Developer/steuerbot/frontend'
abbr -a sbw 'cd ~/Developer/steuerbot/website'

# File Operations
abbr -a l 'eza -l --icons'
abbr -a la 'eza -la --icons'
abbr -a lt 'eza --tree --icons'
abbr -a lf 'eza | fzf --icons'
abbr -a link 'ln -sf'

# Applications
abbr -a vim nvim
abbr -a v nvim
abbr -a lg lazygit
abbr -a g git
abbr -a t tmux
abbr -a ta 'tmux attach'
abbr -a tk 'tmux kill-server'
abbr -a cx 'codex --dangerously-bypass-approvals-and-sandbox'
abbr -a ca cursor-agent
abbr -a ts tailscale
abbr -a tsti 'tailscale switch timonet'
abbr -a tsta 'tailscale switch taxfix.de'
abbr -a ai oc
abbr -a ad agents-dashboard
abbr -a u update-global-packages
abbr -a i fastfetch
abbr -a cv 'git diff | comview'

# =============================================================================
# Aliases (for shortcuts that scripts type into a pane, like `cc` from the
# sessionizers, or that point at a function in functions/)
# =============================================================================
alias cc 'claude --model claude-opus-5-5 --effort medium'
alias ccw 'cc --worktree'
alias ccs 'cc --model claude-sonnet-5-5 --effort medium'
alias ccsw 'ccs --worktree'
alias cch 'cc --model claude-haiku-5-5 --effort medium'
alias cchw 'cch --worktree'
alias r run_npm_script
alias m run_nx_target
alias n manage_node_version
alias o manage_ollama
alias x manage_xcode_version
alias y yazy-shell

# =============================================================================
# Key Bindings
# =============================================================================
fzf --fish | source
bind ctrl-f 'tmux-sessionizer; commandline -f repaint'
bind ctrl-g fzf-cd-widget

# =============================================================================
# Additional Tools
# =============================================================================
zoxide init fish | source

starship init fish | source
