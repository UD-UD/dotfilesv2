#
# .zshenv - Sourced for ALL zsh sessions (interactive and non-interactive)
#
# Keep this minimal - only essential environment variables
# Heavy initialization goes in .zshrc
#

# ─── Early Local Overrides ─────────────────────────────────────────────────
# Load local config FIRST to allow custom Homebrew paths and system tools
# This ensures your custom configurations take precedence
[[ -f "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"

# Rust/Cargo
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Ensure Homebrew is in PATH for non-interactive shells (scripts, etc.)
# IMPORTANT: Only initialize if brew is not already available
# This preserves custom Homebrew installations (e.g., ~/.homebrew, /custom/brew)
if ! command -v brew &>/dev/null && [[ -z "$HOMEBREW_PREFIX" ]]; then
  # Try common Homebrew locations only if brew not found
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
  elif [[ -f "$HOME/homebrew/bin/brew" ]]; then
    eval "$($HOME/homebrew/bin/brew shellenv)" 2>/dev/null || true
  fi
fi
