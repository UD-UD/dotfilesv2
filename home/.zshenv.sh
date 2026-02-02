#
# .zshenv - Sourced for ALL zsh sessions (interactive and non-interactive)
#
# Keep this minimal - only essential environment variables
# Heavy initialization goes in .zshrc
#

# Rust/Cargo
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Ensure Homebrew is in PATH for non-interactive shells (scripts, etc.)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
