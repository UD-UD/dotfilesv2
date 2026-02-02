#!/bin/bash
#
# Remote Installer for dotfilesv2
# Usage: curl -fsSL https://raw.githubusercontent.com/UD-UD/dotfilesv2/main/setup.sh | bash
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              dotfilesv2 - Remote Installer                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ─── Check Requirements ────────────────────────────────────────────────────
echo -e "${CYAN}Checking requirements...${NC}"

if ! command -v git &>/dev/null; then
  echo -e "${RED}✗ Git is not installed${NC}"
  echo ""
  echo "  Please install Git first:"
  echo "    • macOS: xcode-select --install"
  echo "    • or: brew install git"
  exit 1
fi
echo -e "${GREEN}✓${NC} Git is installed"

if [[ "${SHELL##*/}" != "zsh" ]]; then
  echo -e "${YELLOW}!${NC} Your default shell is ${SHELL##*/}, not zsh"
  echo "  Run: chsh -s /bin/zsh"
fi

# ─── Determine Install Location ────────────────────────────────────────────
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfilesv2}"

echo ""
echo -e "${CYAN}Installation directory:${NC} $DOTFILES_DIR"

if [[ -d "$DOTFILES_DIR" ]]; then
  echo -e "${YELLOW}!${NC} Directory already exists"
  echo ""
  read -p "  Remove and reinstall? [y/N] " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "  ${CYAN}→${NC} Removing existing directory..."
    rm -rf "$DOTFILES_DIR"
  else
    echo ""
    echo "  To update instead, run:"
    echo -e "    ${YELLOW}cd $DOTFILES_DIR && git pull${NC}"
    echo ""
    echo "  Or set a different location:"
    echo -e "    ${YELLOW}DOTFILES_DIR=~/my-dotfiles curl -fsSL ... | bash${NC}"
    exit 0
  fi
fi

# ─── Clone Repository ──────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}Cloning repository...${NC}"
git clone https://github.com/UD-UD/dotfilesv2.git "$DOTFILES_DIR"
echo -e "${GREEN}✓${NC} Repository cloned"

# ─── Run Bootstrap ─────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}Running bootstrap...${NC}"
echo ""

cd "$DOTFILES_DIR"
./bootstrap.sh

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "  Restart your terminal or run:"
echo -e "    ${YELLOW}exec zsh${NC}"
echo ""
