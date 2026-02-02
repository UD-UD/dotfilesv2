#!/bin/bash
#
# Upgrade Script for dotfilesv2
# Updates Homebrew packages, git submodules, and dotfiles repo
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
}

print_step() { echo -e "${CYAN}→${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

confirm() {
  local prompt="$1"
  local default="${2:-y}"
  if [[ "$default" == "y" ]]; then
    read -p "$prompt [Y/n] " response
    response="${response:-y}"
  else
    read -p "$prompt [y/N] " response
    response="${response:-n}"
  fi
  [[ "$response" =~ ^[Yy]$ ]]
}

# ─── Detect Dotfiles Location ──────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/home/.zshrc.sh" ]]; then
  DOTFILES_DIR="$SCRIPT_DIR"
elif [[ -n "$DOTFILES" ]]; then
  DOTFILES_DIR="$DOTFILES"
elif [[ -d "$HOME/dotfiles/dotfilesv2" ]]; then
  DOTFILES_DIR="$HOME/dotfiles/dotfilesv2"
elif [[ -d "$HOME/dotfilesv2" ]]; then
  DOTFILES_DIR="$HOME/dotfilesv2"
else
  echo -e "${RED}Error: Cannot find dotfiles directory${NC}"
  exit 1
fi

# ─── Welcome ───────────────────────────────────────────────────────────────
clear
print_header "Dotfiles Upgrade"

echo ""
echo "  This script will upgrade:"
echo "    • Homebrew packages (starship, zoxide, fzf, etc.)"
echo "    • Zsh plugins (syntax highlighting, autosuggestions)"
echo "    • Dotfiles repository (git pull)"
echo ""
echo "  Dotfiles location: $DOTFILES_DIR"
echo ""

if ! confirm "Ready to upgrade?"; then
  echo "Upgrade cancelled."
  exit 0
fi

# ─── Update Dotfiles Repo ──────────────────────────────────────────────────
print_header "Update Dotfiles Repository"

cd "$DOTFILES_DIR"

# Check for uncommitted changes
if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  print_warning "You have uncommitted changes in dotfiles"
  echo ""
  git status --short
  echo ""
  if confirm "Stash changes and continue?" "n"; then
    git stash push -m "Auto-stash before upgrade $(date +%Y%m%d_%H%M%S)"
    print_success "Changes stashed"
    STASHED=true
  else
    print_warning "Skipping repo update"
    SKIP_REPO=true
  fi
fi

if [[ "$SKIP_REPO" != true ]]; then
  print_step "Pulling latest changes..."
  if git pull --rebase; then
    print_success "Dotfiles updated"
  else
    print_error "Failed to update dotfiles"
    if [[ "$STASHED" == true ]]; then
      git stash pop
    fi
  fi
fi

# ─── Update Git Submodules ─────────────────────────────────────────────────
print_header "Update Zsh Plugins (Git Submodules)"

echo "  Plugins:"
echo "    • zsh-syntax-highlighting"
echo "    • zsh-autosuggestions"
echo "    • zsh-completions"
echo ""

if confirm "Update plugins to latest versions?"; then
  print_step "Verifying submodule URLs..."

  # Verify submodule URLs match expected sources (security check)
  expected_urls=(
    "https://github.com/zsh-users/zsh-syntax-highlighting"
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-completions"
  )

  if [[ -f ".gitmodules" ]]; then
    for expected_url in "${expected_urls[@]}"; do
      if ! grep -q "$expected_url" .gitmodules; then
        print_error "Security: Unexpected submodule URL detected in .gitmodules"
        print_error "Expected URLs: ${expected_urls[*]}"
        echo ""
        echo "Current .gitmodules content:"
        cat .gitmodules
        exit 1
      fi
    done
    print_success "Submodule URLs verified"
  fi

  print_step "Updating submodules..."
  git submodule update --init --recursive
  git submodule update --remote --merge
  print_success "Plugins updated"
fi

# ─── Update Homebrew ───────────────────────────────────────────────────────
print_header "Update Homebrew Packages"

if ! command -v brew &>/dev/null; then
  print_warning "Homebrew not installed, skipping package updates"
else
  # List of packages we manage
  PACKAGES=(
    "starship"
    "zoxide"
    "fzf"
    "eza"
    "bat"
    "ripgrep"
    "fd"
    "git"
    "git-delta"
    "gh"
    "neovim"
    "fnm"
  )

  print_step "Updating Homebrew..."
  brew update

  echo ""
  echo "  Checking for outdated packages..."
  echo ""

  # Get list of outdated packages
  OUTDATED=$(brew outdated --formula 2>/dev/null || echo "")

  # Check which of our packages are outdated
  UPGRADES=()
  for pkg in "${PACKAGES[@]}"; do
    if echo "$OUTDATED" | grep -q "^$pkg\$"; then
      UPGRADES+=("$pkg")
    fi
  done

  if [[ ${#UPGRADES[@]} -eq 0 ]]; then
    print_success "All packages are up to date!"
  else
    echo "  The following packages have updates available:"
    echo ""
    for pkg in "${UPGRADES[@]}"; do
      current=$(brew list --versions "$pkg" 2>/dev/null | awk '{print $2}')
      latest=$(brew info "$pkg" 2>/dev/null | head -1 | awk '{print $3}')
      echo -e "    ${YELLOW}$pkg${NC}: $current → $latest"
    done
    echo ""

    if confirm "Upgrade these packages?"; then
      for pkg in "${UPGRADES[@]}"; do
        print_step "Upgrading $pkg..."
        brew upgrade "$pkg" 2>/dev/null || true
      done
      print_success "Packages upgraded"
    fi
  fi

  # Cleanup
  echo ""
  if confirm "Run brew cleanup to remove old versions?"; then
    print_step "Cleaning up..."
    brew cleanup
    print_success "Cleanup complete"
  fi
fi

# ─── Pop Stashed Changes ───────────────────────────────────────────────────
if [[ "$STASHED" == true ]]; then
  print_header "Restore Stashed Changes"
  if confirm "Restore your stashed changes?"; then
    git stash pop
    print_success "Changes restored"
  else
    print_warning "Changes remain stashed. Run 'git stash pop' to restore."
  fi
fi

# ─── Summary ───────────────────────────────────────────────────────────────
print_header "Upgrade Complete!"

echo ""
echo -e "  ${GREEN}All components have been upgraded.${NC}"
echo ""
echo -e "  ${CYAN}What was updated:${NC}"
echo "    • Dotfiles repository"
echo "    • Zsh plugins (submodules)"
echo "    • Homebrew packages"
echo ""
echo -e "  ${CYAN}To apply changes:${NC}"
echo -e "    ${YELLOW}exec zsh${NC}  (restart shell)"
echo ""
echo -e "  ${CYAN}To check versions:${NC}"
echo -e "    ${YELLOW}starship --version${NC}"
echo -e "    ${YELLOW}zoxide --version${NC}"
echo -e "    ${YELLOW}fzf --version${NC}"
echo ""
