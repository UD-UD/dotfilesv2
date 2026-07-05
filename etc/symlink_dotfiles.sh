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

  # Warn if overwriting a real file (not a symlink)
  if [[ -f "$to" ]] && [[ ! -L "$to" ]]; then
    echo ""
    echo "  Warning: '$to' exists and is not a symlink."
    echo "  This is a real file that will be overwritten!"
    read -p "  Replace with symlink? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "  Skipping: $to"
      return
    fi
  fi

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
echo "=== Linking git hooks ==="

# Link git hooks directory for core.hooksPath
link "$dotfiles/git/hooks" "$HOME/.git-hooks"

echo ""
echo "=== Linking Claude Code files ==="

# Link individual Claude Code files (the ~/.claude dir itself stays untracked —
# it holds machine-specific state; only portable files are symlinked in).
link "$dotfiles/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

echo ""
echo "=== Linking VS Code settings ==="

# Link the user/global VS Code settings (macOS path under Library, NOT ~/.config).
# This is distinct from the repo's own workspace-level .vscode/ folder. VS Code
# writes through the symlink, so settings changed via the UI flow back into the repo.
link "$dotfiles/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"

echo ""
echo "=== Symlinks created successfully ==="
echo ""
echo "Restart your terminal or run: exec zsh"
