# Dotfiles Project - Claude Code Context

## Overview

This is a modern Zsh dotfiles configuration for macOS (Apple Silicon & Intel). The setup prioritizes **fast startup time (<100ms)** while providing a feature-rich terminal experience.

## Directory Structure

```
dotfilesv2/
├── home/                    # Files symlinked to $HOME
│   ├── .zshrc.sh           # Main shell config (→ ~/.zshrc)
│   ├── .zshenv.sh          # Environment vars (→ ~/.zshenv)
│   ├── .zlogin.sh          # Login shell config (→ ~/.zlogin)
│   ├── .gitconfig          # Git configuration (→ ~/.gitconfig)
│   ├── .gitignore          # Global gitignore (→ ~/.gitignore)
│   └── .config/
│       └── starship.toml   # Prompt config (→ ~/.config/starship.toml)
├── terminal/               # Shell modules (sourced by .zshrc.sh)
│   ├── start.sh            # Core options, history, aliases
│   ├── completion.sh       # Zsh completion system
│   ├── git-alias.sh        # Git shortcuts and functions
│   ├── highlight.sh        # Syntax highlighting loader
│   ├── prompt_ujjal_setup  # Legacy prompt (unused, kept for reference)
│   ├── zsh-syntax-highlighting/   # Git submodule
│   ├── zsh-autosuggestion/        # Git submodule
│   └── zsh-completions/           # Git submodule
├── install/
│   └── install.sh          # Interactive Homebrew package installer
├── etc/
│   ├── symlink_dotfiles.sh # Creates symlinks from home/ to ~/
│   ├── backup.sh           # Backup before changes
│   └── revert.sh           # Revert to backup
├── git/
│   ├── git-setup.sh        # Initialize new repos
│   └── git-summary.sh      # Commit statistics
└── bootstrap.sh            # Full setup for new machines
```

## Key Files

### home/.zshrc.sh
Main entry point. Load order matters:
1. Homebrew (must be first for PATH)
2. `terminal/start.sh` (options, history)
3. `terminal/completion.sh` (compinit)
4. Syntax highlighting (before autosuggestions)
5. Autosuggestions
6. Git aliases
7. zoxide, fzf
8. Starship prompt (must be last)
9. Local overrides (~/.zshrc.local)

### terminal/start.sh
Core shell configuration:
- Directory navigation options (AUTO_CD, PUSHD_*)
- History settings (50k lines, dedup, share)
- LS_COLORS and aliases
- Modern tool aliases (eza, bat) if installed

### terminal/completion.sh
Completion system with:
- Daily compinit regeneration (performance)
- Fuzzy matching
- Case-insensitive completion
- SSH host completion from known_hosts

### terminal/git-alias.sh
Git workflow shortcuts:
- `gs` = status, `ga` = add, `gc` = commit
- `gco` = checkout, `gsw` = switch
- `glog` = pretty log graph
- fzf integration: `gcof` (fuzzy checkout)

### install/install.sh
Interactive package installer:
- Detects Apple Silicon vs Intel
- Shows package status (installed/outdated/missing)
- Asks for confirmation before each action
- Packages: starship, zoxide, fzf, eza, bat, ripgrep, fd, git-delta, gh, fnm, neovim

## Conventions

### Adding New Shell Config
1. Create module in `terminal/newmodule.sh`
2. Source it in `home/.zshrc.sh` (order matters!)
3. Guard with `command -v` if it depends on optional tools

### Adding New Dotfile
1. Add file to `home/` directory
2. Use `.sh` extension for shell files (stripped during symlink)
3. Run `./etc/symlink_dotfiles.sh` to create links

### Performance Guidelines
- Use `command -v` instead of `which` (faster)
- Guard optional tools: `if command -v tool &>/dev/null; then`
- Avoid subshells in prompt/precmd hooks
- Use `compinit -C` for cached completion loading

## Testing Changes

### Startup Time
```bash
time zsh -i -c exit    # Target: <100ms
```

### Profile Startup
Uncomment in `.zshrc.sh`:
```bash
zmodload zsh/zprof    # Top of file
zprof                  # Bottom of file
```

### Test Without Breaking Current Shell
```bash
zsh -f                 # Start zsh without any config
source ~/.zshrc        # Load config manually
```

## Git Submodules

Plugins are git submodules. To update:
```bash
git submodule update --remote --merge
```

To initialize (after fresh clone):
```bash
git submodule update --init --recursive
```

## Backup & Revert

Before major changes:
```bash
./etc/backup.sh
# Creates: ~/dotfiles_backup_YYYYMMDD_HHMMSS/
```

To revert:
```bash
./etc/revert.sh ~/dotfiles_backup_YYYYMMDD_HHMMSS
```

## Common Tasks

### Show help / quick reference
```bash
h         # Full terminal quick reference
h git     # List all git aliases
h fzf     # Show fzf configuration
```

### Add a new alias
Edit `terminal/start.sh` or `terminal/git-alias.sh`

### Change prompt appearance
Edit `home/.config/starship.toml`

### Add new Homebrew package to installer
Edit `install/install.sh`:
1. Add to `packages` associative array with description
2. Add to `package_order` array

### Support new tool (like pyenv, rbenv)
Add to `home/.zshrc.sh` with guard:
```bash
if command -v newtool &>/dev/null; then
  eval "$(newtool init zsh)"
fi
```

## Environment

- **Shell**: Zsh (macOS default)
- **Prompt**: Starship
- **Package Manager**: Homebrew
- **Node Version Manager**: fnm
- **Fuzzy Finder**: fzf
- **Directory Jumper**: zoxide

## Dotfiles Path Auto-Detection

The config auto-detects its location, checking in order:
1. `$DOTFILES` environment variable
2. `~/dotfiles/dotfilesv2`
3. `~/dotfilesv2`

Set `DOTFILES` in `~/.zshrc.local` to override.
