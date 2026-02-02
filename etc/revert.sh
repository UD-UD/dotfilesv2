#!/bin/bash
# Reverts dotfiles to a previous backup

set -e

BACKUP_DIR="$1"

# Show usage if no argument
if [[ -z "$BACKUP_DIR" ]]; then
  echo "Usage: ./revert.sh <backup_directory>"
  echo ""
  echo "Available backups:"
  ls -dt ~/dotfiles_backup_* 2>/dev/null | head -10 || echo "  No backups found"
  exit 1
fi

# Validate backup directory
if [[ ! -d "$BACKUP_DIR" ]]; then
  echo "Error: Backup directory not found: $BACKUP_DIR"
  exit 1
fi

# Get the original dotfiles path
if [[ -f "$BACKUP_DIR/.dotfiles_path" ]]; then
  DOTFILES_DIR="$(cat "$BACKUP_DIR/.dotfiles_path")"
else
  DOTFILES_DIR="$HOME/dotfiles/dotfilesv2"
fi

echo "Reverting from: $BACKUP_DIR"
echo "To dotfiles at: $DOTFILES_DIR"
echo ""
read -p "Are you sure you want to revert? (y/N) " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""
echo "Restoring dotfiles repo..."

# Restore dotfiles repo files
if [[ -d "$BACKUP_DIR/home" ]]; then
  rm -rf "$DOTFILES_DIR/home"
  cp -r "$BACKUP_DIR/home" "$DOTFILES_DIR/"
fi

if [[ -d "$BACKUP_DIR/terminal" ]]; then
  rm -rf "$DOTFILES_DIR/terminal"
  cp -r "$BACKUP_DIR/terminal" "$DOTFILES_DIR/"
fi

if [[ -d "$BACKUP_DIR/install" ]]; then
  rm -rf "$DOTFILES_DIR/install"
  cp -r "$BACKUP_DIR/install" "$DOTFILES_DIR/"
fi

if [[ -d "$BACKUP_DIR/etc" ]]; then
  # Don't overwrite backup/revert scripts
  cp "$BACKUP_DIR/etc/"*.sh "$DOTFILES_DIR/etc/" 2>/dev/null || true
fi

if [[ -f "$BACKUP_DIR/bootstrap.sh" ]]; then
  cp "$BACKUP_DIR/bootstrap.sh" "$DOTFILES_DIR/"
fi

echo "Restoring home directory dotfiles..."

# Restore home directory files
[[ -f "$BACKUP_DIR/home_zshrc" ]] && cp "$BACKUP_DIR/home_zshrc" "$HOME/.zshrc"
[[ -f "$BACKUP_DIR/home_zshenv" ]] && cp "$BACKUP_DIR/home_zshenv" "$HOME/.zshenv"
[[ -f "$BACKUP_DIR/home_zlogin" ]] && cp "$BACKUP_DIR/home_zlogin" "$HOME/.zlogin"
[[ -f "$BACKUP_DIR/home_zprofile" ]] && cp "$BACKUP_DIR/home_zprofile" "$HOME/.zprofile"

# Remove new files that didn't exist before
if [[ ! -f "$BACKUP_DIR/config/starship.toml" ]]; then
  echo "Removing starship.toml (didn't exist before)..."
  rm -f "$HOME/.config/starship.toml"
fi

echo ""
echo "Revert complete!"
echo ""
echo "Restart your terminal or run: exec zsh"
