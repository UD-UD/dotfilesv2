#!/bin/bash
# Creates timestamped backup of all config files before modernization

set -e

BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles/dotfilesv2}"

# Also check if we're running from the repo directly
if [[ -f "./home/.zshrc.sh" ]]; then
  DOTFILES_DIR="$(pwd)"
fi

echo "Creating backup at: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Backup dotfiles repo files
echo "Backing up dotfiles repo..."
cp -r "$DOTFILES_DIR/home" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$DOTFILES_DIR/terminal" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$DOTFILES_DIR/install" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$DOTFILES_DIR/etc" "$BACKUP_DIR/" 2>/dev/null || true
cp "$DOTFILES_DIR/bootstrap.sh" "$BACKUP_DIR/" 2>/dev/null || true

# Backup actual home directory dotfiles (the symlinked ones)
echo "Backing up home directory dotfiles..."
cp "$HOME/.zshrc" "$BACKUP_DIR/home_zshrc" 2>/dev/null || true
cp "$HOME/.zshenv" "$BACKUP_DIR/home_zshenv" 2>/dev/null || true
cp "$HOME/.zlogin" "$BACKUP_DIR/home_zlogin" 2>/dev/null || true
cp "$HOME/.zprofile" "$BACKUP_DIR/home_zprofile" 2>/dev/null || true
mkdir -p "$BACKUP_DIR/config"
cp "$HOME/.config/starship.toml" "$BACKUP_DIR/config/" 2>/dev/null || true

# Store the dotfiles directory path for revert
echo "$DOTFILES_DIR" > "$BACKUP_DIR/.dotfiles_path"

echo ""
echo "Backup complete!"
echo "Location: $BACKUP_DIR"
echo ""
echo "To revert later, run:"
echo "  $DOTFILES_DIR/etc/revert.sh $BACKUP_DIR"
