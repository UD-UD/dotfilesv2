#!/usr/bin/env bash
#
# Interactive Installation Script for Dotfiles
# Installs Homebrew and essential packages with user confirmation
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
  echo ""
  echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
}

print_step() {
  echo -e "${CYAN}→${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}!${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

# Ask for confirmation
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

# Detect architecture
if [[ "$(uname -m)" == "arm64" ]]; then
  HOMEBREW_PREFIX="/opt/homebrew"
  ARCH="Apple Silicon"
else
  HOMEBREW_PREFIX="/usr/local"
  ARCH="Intel"
fi

# ─── Welcome ────────────────────────────────────────────────────────────────
clear
print_header "Dotfiles Installation"
echo ""
echo "  This script will install the following:"
echo ""
echo -e "  ${CYAN}Shell Tools:${NC}"
echo "    • starship   - Fast, customizable prompt"
echo "    • zoxide     - Smart directory jumping"
echo "    • fzf        - Fuzzy finder (Ctrl+R, Ctrl+T)"
echo ""
echo -e "  ${CYAN}Modern CLI Tools:${NC}"
echo "    • eza        - Modern ls replacement"
echo "    • bat        - Better cat with syntax highlighting"
echo "    • ripgrep    - Fast grep (rg)"
echo "    • fd         - Fast find"
echo ""
echo -e "  ${CYAN}Development:${NC}"
echo "    • git        - Version control"
echo "    • git-delta  - Better diff viewer"
echo "    • gh         - GitHub CLI"
echo "    • neovim     - Modern vim"
echo "    • fnm        - Fast Node.js version manager"
echo "    • python3    - Python"
echo "    • gnupg      - GPG for signed commits"
echo ""
echo -e "  ${CYAN}Optional:${NC}"
echo "    • Rust       - Via rustup"
echo ""
echo -e "  Detected: ${GREEN}$ARCH Mac${NC}"
echo ""

if ! confirm "Do you want to proceed with installation?"; then
  echo "Installation cancelled."
  exit 0
fi

# ─── Homebrew ───────────────────────────────────────────────────────────────
print_header "Homebrew"

if command -v brew &>/dev/null; then
  print_success "Homebrew is already installed"
  BREW_VERSION=$(brew --version | head -1)
  echo "  Version: $BREW_VERSION"
else
  print_warning "Homebrew is not installed"
  echo ""
  echo -e "  ${YELLOW}⚠️  About to download and execute Homebrew installer from GitHub${NC}"
  echo "     You can review it at: https://github.com/Homebrew/install/blob/HEAD/install.sh"
  echo ""
  if confirm "Continue with Homebrew installation?"; then
    print_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
    print_success "Homebrew installed"
  else
    print_error "Homebrew is required. Exiting."
    exit 1
  fi
fi

# Add brew to PATH for this session
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)" 2>/dev/null || true

if confirm "Update Homebrew and upgrade existing packages?"; then
  print_step "Updating Homebrew..."
  brew update
  print_step "Upgrading packages..."
  brew upgrade
  print_success "Homebrew updated"
fi

# ─── Package Installation ───────────────────────────────────────────────────
print_header "Checking Packages"

# Define packages (parallel arrays for bash 3.x compatibility)
packages=(
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
  "python3"
  "gnupg"
)

descriptions=(
  "Cross-shell prompt showing git status, language versions, cmd duration"
  "Smarter cd - remembers directories you visit, jump with 'z partial-name'"
  "Fuzzy finder - Ctrl+R for history, Ctrl+T for files, Alt+C for dirs"
  "Modern ls replacement with colors, git status, tree view"
  "cat with syntax highlighting, line numbers, git integration"
  "Blazing fast grep (rg) - searches code 10x faster than grep"
  "Fast find alternative - simpler syntax, respects .gitignore"
  "Version control system"
  "Beautiful git diffs with syntax highlighting and line numbers"
  "GitHub CLI - create PRs, issues, manage repos from terminal"
  "Modern vim with better defaults and plugin ecosystem"
  "Fast Node.js version manager - switch versions instantly"
  "Python interpreter"
  "GPG encryption for signing git commits"
)

# Helper to get description by package name
get_desc() {
  local pkg="$1"
  local i
  for i in "${!packages[@]}"; do
    if [[ "${packages[$i]}" == "$pkg" ]]; then
      echo "${descriptions[$i]}"
      return
    fi
  done
}

# Check package status
print_step "Checking installed packages..."
outdated_list=$(brew outdated --formula 2>/dev/null | awk '{print $1}' || echo "")

to_install=()
to_upgrade=()
installed_count=0

echo ""
echo "Package Status:"
echo ""

for i in "${!packages[@]}"; do
  pkg="${packages[$i]}"
  desc="${descriptions[$i]}"

  if brew list "$pkg" &>/dev/null; then
    if echo "$outdated_list" | grep -q "^$pkg$"; then
      # Outdated
      current_ver=$(brew list --versions "$pkg" 2>/dev/null | awk '{print $2}')
      echo -e "  ${YELLOW}↑${NC} ${CYAN}$pkg${NC} ${YELLOW}(v$current_ver → update available)${NC}"
      echo -e "      $desc"
      to_upgrade+=("$pkg")
    else
      # Up to date
      echo -e "  ${GREEN}✓${NC} ${CYAN}$pkg${NC} ${GREEN}(up to date)${NC}"
      echo -e "      $desc"
      installed_count=$((installed_count + 1))
    fi
  else
    # Missing
    echo -e "  ${RED}○${NC} ${CYAN}$pkg${NC} ${RED}(not installed)${NC}"
    echo -e "      $desc"
    to_install+=("$pkg")
  fi
  echo ""
done

# Summary counts
total=${#packages[@]}
echo -e "  ${CYAN}Summary:${NC} $total packages"
echo -e "    ${GREEN}✓${NC} Up to date:  $installed_count"
echo -e "    ${YELLOW}↑${NC} To upgrade:  ${#to_upgrade[@]}"
echo -e "    ${RED}○${NC} To install:  ${#to_install[@]}"

# Install missing packages
if [[ ${#to_install[@]} -gt 0 ]]; then
  echo ""
  echo "Packages to install:"
  for pkg in "${to_install[@]}"; do
    echo "  • $pkg - $(get_desc "$pkg")"
  done
  echo ""

  if confirm "Install ${#to_install[@]} missing package(s)?"; then
    for pkg in "${to_install[@]}"; do
      print_step "Installing $pkg..."
      if brew install "$pkg"; then
        print_success "$pkg installed"
      else
        print_warning "Failed to install $pkg (continuing...)"
      fi
    done
  fi
else
  print_success "All packages are already installed"
fi

# Upgrade outdated packages
if [[ ${#to_upgrade[@]} -gt 0 ]]; then
  echo ""
  echo "Packages with updates available:"
  for pkg in "${to_upgrade[@]}"; do
    current_ver=$(brew list --versions "$pkg" 2>/dev/null | awk '{print $2}')
    echo "  • $pkg (current: $current_ver)"
  done
  echo ""

  if confirm "Upgrade ${#to_upgrade[@]} outdated package(s)?"; then
    for pkg in "${to_upgrade[@]}"; do
      print_step "Upgrading $pkg..."
      if brew upgrade "$pkg"; then
        print_success "$pkg upgraded"
      else
        print_warning "Failed to upgrade $pkg (continuing...)"
      fi
    done
  fi
fi

# ─── fzf Key Bindings ───────────────────────────────────────────────────────
print_header "fzf Configuration"

if command -v fzf &>/dev/null; then
  echo "fzf provides powerful keybindings:"
  echo "  • Ctrl+R - Fuzzy search command history"
  echo "  • Ctrl+T - Fuzzy search files"
  echo "  • Alt+C  - Fuzzy cd into subdirectory"
  echo ""

  if [[ -f "$HOMEBREW_PREFIX/opt/fzf/install" ]]; then
    if confirm "Setup fzf keybindings?"; then
      print_step "Setting up fzf..."
      "$HOMEBREW_PREFIX/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
      print_success "fzf keybindings configured"
    fi
  fi
else
  print_warning "fzf not installed, skipping keybinding setup"
fi

# ─── Rust ───────────────────────────────────────────────────────────────────
print_header "Rust (Optional)"

if command -v rustup &>/dev/null; then
  print_success "Rust is already installed"
  RUST_VERSION=$(rustc --version 2>/dev/null || echo "unknown")
  echo "  Version: $RUST_VERSION"

  if confirm "Update Rust?"; then
    print_step "Updating Rust..."
    rustup update
    print_success "Rust updated"
  fi
else
  echo "Rust is a systems programming language. Recommended for development."
  echo ""
  if confirm "Install Rust via rustup?" "n"; then
    print_step "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    print_success "Rust installed"
  else
    print_warning "Skipping Rust installation"
  fi
fi

# ─── Summary ────────────────────────────────────────────────────────────────
print_header "Installation Complete!"

echo ""
echo -e "  ${GREEN}Installed tools:${NC}"

for tool in starship zoxide fzf eza bat; do
  if command -v "$tool" &>/dev/null; then
    echo -e "    ${GREEN}✓${NC} $tool"
  fi
done

echo ""
echo -e "  ${CYAN}Next steps:${NC}"
echo -e "    1. Restart your terminal or run: ${YELLOW}exec zsh${NC}"
echo -e "    2. Install Node.js: ${YELLOW}fnm install --lts${NC}"
echo ""
echo -e "  ${CYAN}Quick commands to try:${NC}"
echo -e "    • ${YELLOW}z <partial-path>${NC}  - Jump to directory"
echo -e "    • ${YELLOW}Ctrl+R${NC}            - Fuzzy search history"
echo -e "    • ${YELLOW}gs${NC}                - Git status"
echo -e "    • ${YELLOW}ll${NC}                - List files"
echo ""
