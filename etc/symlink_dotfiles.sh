#!/bin/bash
#
# Creates symlinks from dotfiles repo to home directory
#

set -e

# Auto-detect dotfiles location
if [[ -d "$HOME/dotfiles/dotfilesv2" ]]; then
  dotfiles="$HOME/dotfiles/dotfilesv2"
elif [[ -d "$HOME/dotfilesv2" ]]; then
  dotfiles="$HOME/dotfilesv2"
else
  # Fallback: use script's parent directory
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  dotfiles="$(dirname "$script_dir")"
fi

echo ""
if [[ -d "$dotfiles/home" ]]; then
  echo "Symlinking dotfiles from $dotfiles"
else
  echo "Error: Cannot find dotfiles directory"
  echo "Checked: ~/dotfiles/dotfilesv2, ~/dotfilesv2, and script directory"
  exit 1
fi

link() {
  local from="$1"
  local to="$2"
  echo "  Linking: $to -> $from"

  # Create parent directory if needed
  mkdir -p "$(dirname "$to")"

  # Remove existing file/link
  rm -f "$to"

  # Create symlink
  ln -s "$from" "$to"
}

echo ""
echo "=== Linking shell dotfiles ==="

# Link shell dotfiles (strip .sh extension)
for location in "$dotfiles"/home/.*; do
  [[ -f "$location" ]] || continue  # Skip if not a file

  file="$(basename "$location")"

  # Skip . and ..
  [[ "$file" == "." || "$file" == ".." ]] && continue

  # Strip .sh extension for the target
  target="${file%.sh}"

  link "$location" "$HOME/$target"
done

echo ""
echo "=== Linking config directories ==="

# Link .config subdirectories/files
if [[ -d "$dotfiles/home/.config" ]]; then
  mkdir -p "$HOME/.config"

  for item in "$dotfiles/home/.config"/*; do
    [[ -e "$item" ]] || continue
    name="$(basename "$item")"
    link "$item" "$HOME/.config/$name"
  done
fi

echo ""
echo "=== Symlinks created successfully ==="
echo ""
echo "Restart your terminal or run: exec zsh"
