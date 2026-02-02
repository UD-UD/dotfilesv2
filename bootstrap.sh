#!/bin/bash
#
# Bootstrap Script for Dotfiles
# Interactive setup for a new Mac
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

# ─── Welcome ────────────────────────────────────────────────────────────────
clear
print_header "Dotfiles Bootstrap"

echo ""
echo "  Welcome to the dotfiles setup!"
echo ""
echo "  This script will:"
echo "    1. Check your shell (zsh required)"
echo "    2. Backup existing dotfiles"
echo "    3. Clone or update the dotfiles repository"
echo "    4. Initialize git submodules (zsh plugins)"
echo "    5. Create symlinks"
echo "    6. Install packages (optional)"
echo ""

if ! confirm "Ready to begin?"; then
  echo "Setup cancelled."
  exit 0
fi

# ─── Shell Check ────────────────────────────────────────────────────────────
print_header "Shell Check"

CURRENT_SHELL="${SHELL##*/}"
if [[ "$CURRENT_SHELL" != "zsh" ]]; then
  print_warning "Your default shell is: $CURRENT_SHELL"
  echo ""
  echo "  This setup requires zsh. macOS comes with zsh pre-installed."
  echo ""
  echo "  To change your default shell, run:"
  echo -e "    ${YELLOW}chsh -s /bin/zsh${NC}"
  echo ""
  if ! confirm "Continue anyway?"; then
    exit 0
  fi
else
  print_success "Shell is zsh"
fi

# ─── Setup Paths ────────────────────────────────────────────────────────────
print_header "Setup Location"

# Auto-detect if running from within the repo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/home/.zshrc.sh" ]]; then
  DOTFILES_DIR="$SCRIPT_DIR"
  print_success "Running from dotfiles directory: $DOTFILES_DIR"
  CLONE_NEEDED=false
else
  # Default installation paths
  DEV_DIR="$HOME/dotfiles"
  DOTFILES_DIR="$DEV_DIR/dotfilesv2"
  CLONE_NEEDED=true

  echo "  Dotfiles will be installed to: $DOTFILES_DIR"
  echo ""

  if [[ -d "$DOTFILES_DIR" ]]; then
    print_warning "Directory already exists: $DOTFILES_DIR"
    if confirm "Update existing installation?"; then
      CLONE_NEEDED=false
    else
      echo "Please remove or rename the existing directory and try again."
      exit 1
    fi
  fi
fi

# ─── Backup ─────────────────────────────────────────────────────────────────
print_header "Backup Existing Dotfiles"

BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Check what exists
existing_files=()
for file in ~/.zshrc ~/.zshenv ~/.zlogin ~/.gitconfig ~/.config/starship.toml; do
  if [[ -e "$file" ]] && [[ ! -L "$file" ]]; then
    existing_files+=("$file")
  fi
done

if [[ ${#existing_files[@]} -gt 0 ]]; then
  echo "  Found existing files (not symlinks):"
  for f in "${existing_files[@]}"; do
    echo "    • $f"
  done
  echo ""

  if confirm "Backup these files to $BACKUP_DIR?"; then
    mkdir -p "$BACKUP_DIR"
    for f in "${existing_files[@]}"; do
      if [[ -e "$f" ]]; then
        cp -r "$f" "$BACKUP_DIR/" 2>/dev/null || true
        print_step "Backed up: $f"
      fi
    done
    print_success "Backup created at: $BACKUP_DIR"
  fi
else
  print_success "No existing dotfiles to backup"
fi

# ─── Clone Repository ───────────────────────────────────────────────────────
if [[ "$CLONE_NEEDED" == true ]]; then
  print_header "Clone Repository"

  mkdir -p "$DEV_DIR"
  cd "$DEV_DIR"

  if confirm "Clone dotfiles repository?"; then
    print_step "Cloning repository..."
    git clone https://github.com/UD-UD/dotfilesv2.git
    print_success "Repository cloned"
  else
    print_error "Repository is required. Exiting."
    exit 1
  fi
fi

cd "$DOTFILES_DIR"

# ─── Git Submodules ─────────────────────────────────────────────────────────
print_header "Git Submodules (Zsh Plugins)"

echo "  The following plugins will be initialized:"
echo "    • zsh-syntax-highlighting"
echo "    • zsh-autosuggestions"
echo "    • zsh-completions"
echo ""

if confirm "Initialize git submodules?"; then
  print_step "Initializing submodules..."
  git submodule update --init --recursive
  print_success "Submodules initialized"
fi

# ─── Git Configuration ─────────────────────────────────────────────────────
print_header "Git Configuration"

GITCONFIG_FILE="$DOTFILES_DIR/home/.gitconfig"
GITCONFIG_TEMPLATE="$DOTFILES_DIR/home/.gitconfig.template"

if [[ -f "$GITCONFIG_FILE" ]]; then
  print_success "Git config already exists at: $GITCONFIG_FILE"
  if confirm "Reconfigure git user info?"; then
    CONFIGURE_GIT=true
  else
    CONFIGURE_GIT=false
  fi
else
  echo "  Let's set up your git identity."
  echo ""
  CONFIGURE_GIT=true
fi

if [[ "$CONFIGURE_GIT" == true ]]; then
  echo ""
  read -p "  Your name (for git commits): " GIT_NAME
  read -p "  Your email (for git commits): " GIT_EMAIL
  read -p "  Your GitHub username: " GIT_USER
  echo ""

  # Create .gitconfig from template with user info
  if [[ -f "$GITCONFIG_TEMPLATE" ]]; then
    print_step "Creating git config from template..."
    sed -e "s/Your Name/$GIT_NAME/" \
        -e "s/your.email@example.com/$GIT_EMAIL/" \
        -e "s/your-github-username/$GIT_USER/" \
        "$GITCONFIG_TEMPLATE" > "$GITCONFIG_FILE"
    print_success "Git config created with your info"
  else
    print_error "Template not found: $GITCONFIG_TEMPLATE"
  fi
fi

# ─── Symlinks ───────────────────────────────────────────────────────────────
print_header "Create Symlinks"

echo "  The following symlinks will be created:"
echo "    • ~/.zshrc -> dotfiles/home/.zshrc.sh"
echo "    • ~/.zshenv -> dotfiles/home/.zshenv.sh"
echo "    • ~/.zlogin -> dotfiles/home/.zlogin.sh"
echo "    • ~/.gitconfig -> dotfiles/home/.gitconfig"
echo "    • ~/.config/starship.toml -> dotfiles/home/.config/starship.toml"
echo ""

if confirm "Create symlinks?"; then
  "$DOTFILES_DIR/etc/symlink_dotfiles.sh"
  print_success "Symlinks created"
fi

# ─── Install Packages ───────────────────────────────────────────────────────
print_header "Install Packages"

echo "  The install script will install:"
echo "    • starship (prompt)"
echo "    • zoxide (smart cd)"
echo "    • fzf (fuzzy finder)"
echo "    • eza, bat, ripgrep, fd (modern CLI tools)"
echo "    • git, gh, neovim, fnm, python3, gnupg"
echo ""

if confirm "Run the install script now?"; then
  "$DOTFILES_DIR/install/install.sh"
else
  print_warning "Skipped package installation"
  echo ""
  echo "  You can run it later with:"
  echo -e "    ${YELLOW}$DOTFILES_DIR/install/install.sh${NC}"
fi

# ─── GPG Setup ──────────────────────────────────────────────────────────────
print_header "GPG Configuration (Optional)"

echo "  GPG allows you to sign your git commits for verification."
echo ""

if confirm "Configure GPG for signed commits?" "n"; then
  echo ""
  echo "  To enable signed commits, you'll need to:"
  echo ""
  echo "  1. Generate a GPG key (if you don't have one):"
  echo -e "     ${YELLOW}gpg --full-generate-key${NC}"
  echo ""
  echo "  2. List your keys to find your key ID:"
  echo -e "     ${YELLOW}gpg --list-secret-keys --keyid-format=long${NC}"
  echo ""
  echo "  3. Configure git to use your key:"
  echo -e "     ${YELLOW}git config --global user.signingkey YOUR_KEY_ID${NC}"
  echo -e "     ${YELLOW}git config --global commit.gpgsign true${NC}"
  echo ""
fi

# ─── Complete ───────────────────────────────────────────────────────────────
print_header "Setup Complete!"

echo ""
echo -e "  ${GREEN}Your dotfiles are now configured!${NC}"
echo ""
echo -e "  ${CYAN}Next steps:${NC}"
echo -e "    1. Restart your terminal or run: ${YELLOW}exec zsh${NC}"
echo -e "    2. If you installed fnm, run: ${YELLOW}fnm install --lts${NC}"
echo ""
echo -e "  ${CYAN}Useful commands:${NC}"
echo -e "    • ${YELLOW}z <path>${NC}   - Smart directory jump (after visiting once)"
echo -e "    • ${YELLOW}Ctrl+R${NC}     - Fuzzy search command history"
echo -e "    • ${YELLOW}gs${NC}         - Git status"
echo -e "    • ${YELLOW}ll${NC}         - List files"
echo ""
echo -e "  ${CYAN}To revert changes:${NC}"
echo -e "    ${YELLOW}$DOTFILES_DIR/etc/revert.sh $BACKUP_DIR${NC}"
echo ""
