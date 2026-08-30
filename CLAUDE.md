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
│   ├── .gitconfig.template # Git config template (committed, no PII)
│   ├── .gitconfig          # Generated from template (gitignored)
│   ├── .gitignore          # Global gitignore (→ ~/.gitignore)
│   ├── .hushlogin          # Suppress "Last login" message (→ ~/.hushlogin)
│   └── .config/
│       └── starship.toml   # Prompt config (→ ~/.config/starship.toml)
├── terminal/               # Shell modules (sourced by .zshrc.sh)
│   ├── start.sh            # Core options, history, aliases, h() help
│   ├── completion.sh       # Zsh completion system
│   ├── git-alias.sh        # Git shortcuts and functions
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
├── setup.sh                # Remote curl installer (clones + bootstraps)
├── bootstrap.sh            # Full setup for new machines
└── upgrade.sh              # Update packages, plugins, and repo
```

## Key Files

### home/.zshrc.sh
Main entry point. **Load order is critical** for proper initialization:

1. **~/.zshrc.local** (loaded FIRST) - Your custom overrides, Homebrew paths
2. **~/.secrets** (loaded EARLY) - API keys, tokens (chmod 600)
3. **Homebrew detection** - Only if not already available
4. **Dotfiles path detection**
5. `terminal/start.sh` (options, history, aliases)
6. `terminal/completion.sh` (compinit)
7. Syntax highlighting (before autosuggestions)
8. Autosuggestions
9. Git aliases
10. fzf, fnm (skipped if nvm is configured), zoxide
11. Starship prompt (must be last)

**Important:** Local overrides load FIRST to ensure custom configurations (like Homebrew paths) take precedence over dotfiles defaults.

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

## Migration & Custom Configuration Preservation

### First-Time Installation

When installing these dotfiles on a machine with existing configurations, the bootstrap process automatically preserves your custom settings:

**1. Migration Script Runs First**
```bash
./etc/migrate_custom_configs.sh
```
- Extracts custom aliases, functions, exports, and PATH additions
- Identifies API keys and secrets
- Detects installed system tools (Homebrew, nvm, pyenv, etc.)
- Creates `~/dotfiles_migration_YYYYMMDD_HHMMSS.sh` for review

**2. You Review and Decide**
- Open the migration file to see what was found
- Copy wanted configs to `~/.zshrc.local` or `~/.secrets`
- System-level tools (Homebrew) are auto-detected - no action needed

**3. Bootstrap Continues**
- Backs up existing dotfiles to `~/dotfiles_backup_YYYYMMDD_HHMMSS/`
- Symlinks new dotfiles
- Your custom configs in `~/.zshrc.local` take precedence

### Custom Homebrew Installations

**Automatic Detection**: The dotfiles auto-detect custom Homebrew locations.

If you have Homebrew in a non-standard location (e.g., `~/.homebrew`, `/custom/brew`):

**IMPORTANT:** Custom Homebrew MUST be in `~/.zshenv.local` (NOT `.zshrc.local`)

1. Create `~/.zshenv.local` BEFORE installing dotfiles:
   ```bash
   # Custom Homebrew location
   if [[ -f "$HOME/.homebrew/bin/brew" ]]; then
     eval "$($HOME/.homebrew/bin/brew shellenv)"
   fi
   ```

2. Or let the migration script extract it for you

**Why `.zshenv.local`?**
- `.zshenv` loads in ALL shells (interactive and non-interactive)
- `.zshrc` only loads in interactive shells
- Homebrew paths needed everywhere
- `.zshenv.local` loads FIRST before dotfiles

**How it works:**
- `.zshenv.local` loads FIRST in all shells
- Sets your custom Homebrew path and `$HOMEBREW_PREFIX`
- Then `.zshenv` checks if `brew` exists
- Sees it's already available → skips initialization
- Your custom installation preserved ✓

**Supported scenarios:**
- ✓ Standard Apple Silicon: `/opt/homebrew`
- ✓ Standard Intel: `/usr/local`
- ✓ Custom location: `~/homebrew`, `~/.homebrew`, `/anywhere/brew`
- ✓ Multiple Homebrew installations (via `~/.zshrc.local`)

### Local Overrides Pattern

The dotfiles support three local override files (none are version controlled):

**~/.zshenv.local** (system-level, loaded FIRST in ALL shells)
```bash
# Custom Homebrew location (MUST be here, not in .zshrc.local)
if [[ -f "$HOME/.homebrew/bin/brew" ]]; then
  eval "$($HOME/.homebrew/bin/brew shellenv)"
fi

# Other system-level environment variables needed in all shells
export JAVA_HOME="/custom/java"
export PATH="/custom/bin:$PATH"
```

**When to use:** System paths, package managers, essential env vars needed by **all** shells (interactive and non-interactive)

**~/.zshrc.local** (interactive shells only)
```bash
# Custom aliases (override dotfiles defaults)
alias gs='git status -sb'  # Overrides dotfiles gs alias

# Custom functions
myfunction() {
  echo "Custom function"
}

# Interactive shell variables
export MY_CUSTOM_VAR="value"

# Node version manager (if using nvm instead of fnm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
```

**When to use:** Aliases, functions, interactive shell configs

**~/.secrets** (API keys, chmod 600, loaded early)
```bash
# API Keys
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export GITHUB_TOKEN="ghp_..."

# Keep this file secure
# chmod 600 ~/.secrets
```

**When to use:** Sensitive credentials, API keys, tokens

**Helpers:**
- Run `aa` to edit `~/.zshrc.local` (creates template if missing)
- Run `aev` to edit `~/.secrets` (creates template with chmod 600)
- Manually create `~/.zshenv.local` for system-level configs

**Loading Order:**
```
1. ~/.zshenv.local    (your system paths - ALL shells)
2. ~/.zshenv          (dotfiles system config)
3. ~/.zshrc.local     (your aliases/functions - interactive only)
4. ~/.secrets         (your API keys - interactive only)
5. ~/.zshrc           (dotfiles interactive config)
```

### Migration Philosophy

**These dotfiles are opinionated** - they include specific tools and configurations:
- Starship prompt
- fnm for Node.js by default (nvm wins if configured locally)
- eza, bat, ripgrep, fd
- Specific git aliases and workflows

**When you install:**
1. **System-level things** (Homebrew paths, package managers) - **auto-preserved**
2. **Your custom configs** (aliases, functions, exports) - **extracted for review**
3. **You decide** what to migrate to `~/.zshrc.local`

**Why not auto-merge everything?**
- Prevents conflicts (different aliases with same names)
- Lets you adopt the opinionated defaults
- Cleaner setup - only keep what you need
- You're in control of what carries forward

## Conventions

### Adding New Shell Config
1. Create module in `terminal/newmodule.sh`
2. Source it in `home/.zshrc.sh` (order matters!)
3. Guard with `command -v` if it depends on optional tools

### Adding New Dotfile
1. Add file to `home/` directory
2. Use `.sh` extension for shell files (stripped during symlink)
3. Run `./etc/symlink_dotfiles.sh` to create links

### Files with PII
Files containing personal info (name, email) use a template pattern:
1. `.gitconfig.template` - committed, contains placeholders
2. `.gitconfig` - gitignored, generated during bootstrap with user's info

The `bootstrap.sh` script prompts for name, email, and GitHub username, then generates `.gitconfig` from the template.

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
1. Add package name to `packages` array
2. Add description to `descriptions` array (same index)

### Support new tool (like pyenv, rbenv)
Add to `home/.zshrc.sh` with guard:
```bash
if command -v newtool &>/dev/null; then
  eval "$(newtool init zsh)"
fi
```

### Manage Multiple Git Identities

If you have multiple GitHub accounts (personal, work, etc.), the bootstrap script can configure them all. On every `git clone`, you'll be prompted to select which identity to use.

**During bootstrap:**
- Answer "yes" to "Do you have multiple GitHub identities?"
- Enter each identity (alias, name, email)

**Managing identities later:**
```bash
gidentities      # List all configured identities
gidentity-add    # Add a new identity
```

**How it works:**
- Identities stored in `~/.git-identities`
- `git clone` automatically prompts for identity selection
- Selected identity is set in local repo config (not global)
- Your global `.gitconfig` uses the first identity you configured

## Environment

- **Shell**: Zsh (macOS default)
- **Prompt**: Starship
- **Package Manager**: Homebrew
- **Node Version Manager**: nvm if `$NVM_DIR` is set by `~/.zshrc.local`, otherwise fnm
- **Fuzzy Finder**: fzf
- **Directory Jumper**: zoxide

## Dotfiles Path Auto-Detection

The config auto-detects its location, checking in order:
1. `$DOTFILES` environment variable
2. `~/dotfiles/dotfilesv2`
3. `~/dotfilesv2`

Set `DOTFILES` in `~/.zshrc.local` to override.

## Terminal Appearance

### Suppress "Last login" message
The `.hushlogin` file in `home/` suppresses macOS's "Last login" message.

### Terminal: Ghostty
The primary terminal is **Ghostty**, configured at `home/.config/ghostty/config`.
It deploys automatically — `etc/symlink_dotfiles.sh` symlinks every entry in
`home/.config/` into `~/.config/`, so the whole `ghostty/` directory is linked
without any installer changes. Key points:
- **Font**: `SF Mono` primary + `Symbols Nerd Font Mono` fallback (repeated
  `font-family` lines). SF Mono has no icon glyphs; the fallback supplies the
  Nerd Font icons used by eza/starship/git. Install both fonts via
  `brew install --cask font-symbols-only-nerd-font font-commit-mono`
  (offered by `install/install.sh`).
- **Low-DPI font toggle (`gfont`)**: SF Mono is tuned for Retina and renders
  unevenly at ~109 PPI — macOS dropped subpixel antialiasing in Mojave and SF
  Mono carries almost no low-DPI hinting. `gfont` (in `terminal/ghostty.sh`)
  writes `font-override.conf` next to the config, swapping in CommitMono plus
  `font-thicken`; running it again removes the file. The main config ends with
  `config-file = ?font-override.conf` — `?` means "ignore if missing", and an
  included file loads *after* its includer, so the override wins. Because
  `font-family` is a repeatable key, the override must reset the list with a
  bare `font-family =` first, or it would only append. The override file is
  gitignored (machine-specific) and the change needs a config reload (`⌘⇧,`),
  which applies to every window — Ghostty has no per-session font mechanism.
  Note CommitMono does not show in `ghostty +list-fonts` (its PANOSE table
  omits the monospace flag) but resolves by name; check with `ghostty
  +show-face`.
- **Theme**: `vscode-dark-2026` from `home/.config/ghostty/themes/`. Built-in
  themes are selectable by their exact name from `ghostty +list-themes`; `gtheme`
  switches a live session without a reload (see `terminal/ghostty.sh`).
- **`macos-option-as-alt = true`**: required so the Option key sends Alt —
  otherwise fzf's `Alt+C` and the emacs Alt-word bindings in `terminal/start.sh`
  break (Option would insert composed characters like é/ç).
- **Shell integration is automatic**: Ghostty auto-injects zsh integration
  (OSC 7 cwd tracking, OSC 133 prompt marks, cursor shape). No `.zshrc` edits are
  needed, so we add none — manual sourcing would risk double-loading. The
  `Apple_Terminal`-gated OSC 7 hook in `terminal/start.sh` does not conflict.
- Validate after edits: `ghostty +validate-config`.

### Starship prompt settings
Key settings in `home/.config/starship.toml`:
- `add_newline = false` - No blank line before prompt
- Shows: directory, git branch/status, language versions, command duration
- Minimal format for fast rendering

### Colors
- **File listings**: Controlled by `LS_COLORS` in `terminal/start.sh`
- **Prompt colors**: Configured in `home/.config/starship.toml`
- **Git diff colors**: Configured in `home/.gitconfig` `[color "diff"]`
- **Syntax highlighting**: Provided by `zsh-syntax-highlighting` submodule

### 2026 themes across apps (VS Code parity)
VS Code's built-in **"2026 Light"** and **"2026 Dark"** themes are ported to
other apps so everything matches. All palettes derive from the same source:
`.../Visual Studio Code.app/.../extensions/theme-defaults/themes/2026-{light,dark}.json`
(editor/workbench colors + GitHub-derived `tokenColors` for syntax).

- **Ghostty**: `home/.config/ghostty/themes/vscode-{light,dark}-2026` (terminal
  palette + bg/fg). Deployed via the `.config` symlink loop.
- **Obsidian**: `obsidian/themes/{Light,Dark} 2026/` — each a `manifest.json` +
  `theme.css` mapping the VS Code colors onto Obsidian's CSS variables. Each is
  single-flavor (forces its palette under both `.theme-light`/`.theme-dark`, so
  the named theme always renders as expected regardless of Obsidian's toggle).
  `etc/symlink_dotfiles.sh` reads vault paths from Obsidian's own
  `~/Library/Application Support/obsidian/obsidian.json` and symlinks every
  theme into each vault's `.obsidian/themes/`. Select in Settings → Appearance.
- **Slack**: `slack/themes/{light,dark}-2026.txt` — Slack themes are NOT
  file-based (they live in Slack's internal store, so they can't be symlinked).
  These files hold the paste-ready comma-separated hex string + color mapping;
  apply via Slack → Preferences → Themes.

## Troubleshooting

### "brew: command not found" after installation

**Cause**: Homebrew shellenv not loaded in current session

**Fix**:
```bash
# Restart terminal, or:
exec zsh

# Or manually load if custom location:
eval "$(/your/custom/brew/path/bin/brew shellenv)"
```

### Custom Homebrew not being detected

**Symptoms**: `which brew` shows custom location, but `$HOMEBREW_PREFIX` still points to `/opt/homebrew` or `/usr/local`

**Root Cause**: Custom Homebrew in wrong file (`.zshrc.local` instead of `.zshenv.local`)

**Fix**: Create `~/.zshenv.local` (NOT `.zshrc.local`):
```bash
cat > ~/.zshenv.local << 'EOF'
# Custom Homebrew location - loaded FIRST in all shells
if [[ -f "$HOME/.homebrew/bin/brew" ]]; then
  eval "$($HOME/.homebrew/bin/brew shellenv)"
fi
EOF
```

Then reload:
```bash
exec zsh
```

**Verify BOTH match**:
```bash
which brew            # Should show: /Users/you/.homebrew/bin/brew
echo $HOMEBREW_PREFIX # Should show: /Users/you/.homebrew
```

**Why `.zshenv.local`?**
- `.zshenv` loads in ALL shells (before `.zshrc`)
- `.zshrc` only loads in interactive shells
- Custom Homebrew must load FIRST to set `$HOMEBREW_PREFIX` correctly

### Want to use nvm instead of fnm

The dotfiles use `fnm` by default, but `~/.zshrc.local` setting `NVM_DIR` is
enough to switch — `.zshrc` skips fnm entirely when that variable is set, so the
two never run together. No need to uninstall fnm:

**Option 1**: Add to `~/.zshrc.local`:
```bash
# Use nvm instead of fnm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
```

**Option 2**: Uninstall fnm:
```bash
brew uninstall fnm
# Then add nvm config to ~/.zshrc.local as above
```

### Migration file not created

**Run manually**:
```bash
~/dotfiles/dotfilesv2/etc/migrate_custom_configs.sh
```

**Review output**:
```bash
cat ~/dotfiles_migration_*.sh
```

### Want to undo dotfiles installation

**Revert to backup**:
```bash
~/dotfiles/dotfilesv2/etc/revert.sh ~/dotfiles_backup_YYYYMMDD_HHMMSS
```

**Manual cleanup**:
```bash
# Remove symlinks
rm ~/.zshrc ~/.zshenv ~/.zlogin ~/.gitconfig
rm -r ~/.config/starship.toml

# Restore from backup
cp ~/dotfiles_backup_YYYYMMDD_HHMMSS/.zshrc ~/.zshrc
# ... restore other files
```
