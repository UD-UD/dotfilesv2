#!/usr/bin/env zsh
#
# Zsh Configuration - Optimized for macOS (Apple Silicon)
# Target startup time: <100ms
#
# Profile startup: uncomment zmodload line below and zprof at bottom
# zmodload zsh/zprof

# ─── Homebrew ───────────────────────────────────────────────────────────────
# Detect and initialize Homebrew (Apple Silicon or Intel)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -f "$HOME/homebrew/bin/brew" ]]; then
  eval "$($HOME/homebrew/bin/brew shellenv)"
fi

# ─── Dotfiles Path ──────────────────────────────────────────────────────────
# Auto-detect dotfiles location
if [[ -n "$DOTFILES" ]]; then
  : # Use existing DOTFILES env var
elif [[ -d "$HOME/dotfiles/dotfilesv2" ]]; then
  DOTFILES="$HOME/dotfiles/dotfilesv2"
elif [[ -d "$HOME/dotfilesv2" ]]; then
  DOTFILES="$HOME/dotfilesv2"
else
  DOTFILES="$HOME/dotfiles/dotfilesv2"  # Fallback
fi
export DOTFILES

# ─── Core Configuration ─────────────────────────────────────────────────────
source "$DOTFILES/terminal/start.sh"

# ─── Completions ────────────────────────────────────────────────────────────
# Add zsh-completions to fpath before compinit
fpath=("$DOTFILES/terminal/zsh-completions/src" $fpath)
source "$DOTFILES/terminal/completion.sh"

# ─── Syntax Highlighting ────────────────────────────────────────────────────
# Must be sourced before zsh-autosuggestions for proper interaction
if [[ -f "$DOTFILES/terminal/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$DOTFILES/terminal/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ─── Autosuggestions ────────────────────────────────────────────────────────
if [[ -f "$DOTFILES/terminal/zsh-autosuggestion/zsh-autosuggestions.zsh" ]]; then
  source "$DOTFILES/terminal/zsh-autosuggestion/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

# ─── Git Aliases ────────────────────────────────────────────────────────────
source "$DOTFILES/terminal/git-alias.sh"

# ─── Smart Navigation (zoxide) ──────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'      # Replace cd with zoxide
  alias cdi='zi'    # Interactive directory selection
fi

# ─── Fuzzy Finder (fzf) ─────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
  # fzf 0.48+ uses this method
  if [[ -f "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh" ]]; then
    source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
    source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  else
    # Fallback for newer fzf versions
    source <(fzf --zsh 2>/dev/null) || true
  fi

  # fzf configuration - use fd for speed and to exclude sensitive directories
  FZF_EXCLUDES="--exclude .git --exclude .ssh --exclude .gnupg --exclude node_modules --exclude .env --exclude Library --exclude .cache"

  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow $FZF_EXCLUDES"
    export FZF_CTRL_T_COMMAND="fd --type f --hidden --follow $FZF_EXCLUDES"
    export FZF_ALT_C_COMMAND="fd --type d --hidden --follow $FZF_EXCLUDES"
  fi

  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
  export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}"'
  export FZF_ALT_C_OPTS='--preview "eza --tree --color=always {} 2>/dev/null || ls -la {}"'
fi

# ─── Node.js (fnm) ──────────────────────────────────────────────────────────
if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd)"
fi

# ─── Starship Prompt (must be last before local) ────────────────────────────
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# ─── Environment Variables ──────────────────────────────────────────────────
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export GPG_TTY=$(tty)

# ─── Useful Aliases ─────────────────────────────────────────────────────────
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Pipe shortcuts
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L='| less'
alias -g CNT='| wc -l'

# Quick edit configs
alias zshrc='${EDITOR:-nvim} ~/.zshrc'
alias zshreload='exec zsh'
alias zc='rm -f ~/.zcompdump*; exec zsh'  # Clear completion cache

# Diff function using git's diff
function diff() {
  git --no-pager diff --color=auto --no-ext-diff --no-index "$@"
}

# Terminal settings
stty icrnl  # Fixes <Return> key issues with some keyboards

# ─── Local Overrides ────────────────────────────────────────────────────────
# Source local customizations (not tracked in git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ─── Profiling (uncomment to debug slow startup) ────────────────────────────
# zprof
