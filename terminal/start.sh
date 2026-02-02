#
# Core Zsh Configuration
# Optimized for fast startup on macOS
#


# ─── Directory Navigation ───────────────────────────────────────────────────
setopt AUTO_CD              # Auto changes to a directory without typing cd.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given.
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt AUTO_NAME_DIRS       # Auto add variable-stored paths to ~ list.

# ─── File Operations ────────────────────────────────────────────────────────
setopt MULTIOS              # Write to multiple descriptors.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
unsetopt CLOBBER            # Do not overwrite existing files with > and >>.
                            # Use >! and >>! to bypass.

# ─── General ────────────────────────────────────────────────────────────────
setopt BRACE_CCL            # Allow brace character class list expansion.
setopt COMBINING_CHARS      # Combine zero-length punctuation characters (accents)
                            # with the base character.
setopt RC_QUOTES            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
unsetopt MAIL_WARNING       # Don't print a warning message if a mail file has been accessed.

# ─── Jobs ───────────────────────────────────────────────────────────────────
setopt LONG_LIST_JOBS       # List jobs in the long format by default.
setopt AUTO_RESUME          # Attempt to resume existing job before creating a new process.

# ─── History ────────────────────────────────────────────────────────────────
HISTFILE="${ZDOTDIR:-$HOME}/.zhistory"
HISTSIZE=50000              # Increased for modern systems
SAVEHIST=50000

# Ensure history file has secure permissions (may contain sensitive commands)
if [[ -f "$HISTFILE" ]]; then
  chmod 600 "$HISTFILE"
fi

setopt BANG_HIST            # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY     # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY   # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY        # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST  # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS     # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS    # Do not display a previously found event.
setopt HIST_IGNORE_SPACE    # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS    # Do not write a duplicate event to the history file.
setopt HIST_VERIFY          # Do not execute immediately upon history expansion.

# ─── Terminal.app Integration (macOS) ───────────────────────────────────────
# Sets the Terminal.app proxy icon to current directory
function _terminal-set-proxy-icon {
  printf '\e]7;%s\a' "file://$HOST${${1:-$PWD}// /%20}"
}

autoload -Uz add-zsh-hook

if [[ "$TERM_PROGRAM" == 'Apple_Terminal' ]] && [[ -z "$TMUX" ]]; then
  add-zsh-hook precmd _terminal-set-proxy-icon
fi

# ─── Colors for ls ──────────────────────────────────────────────────────────
# BSD ls (macOS default)
export LSCOLORS='exfxcxdxbxGxDxabagacad'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

# ─── Useful Aliases ─────────────────────────────────────────────────────────
# ls aliases (will be overridden if eza is installed)
alias ls='ls -G'             # Color output on macOS
alias l='ls -1A'             # Lists in one column, hidden files.
alias ll='ls -lh'            # Lists human readable sizes.
alias la='ll -A'             # Lists human readable sizes, hidden files.
alias sl='ls'                # Common typo fix

# grep with color (replaces deprecated GREP_OPTIONS)
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Modern replacements (if installed)
if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first'
  alias l='eza -1a'
  alias ll='eza -lh --git'
  alias la='eza -lah --git'
  alias tree='eza --tree'
fi

if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias catp='bat'  # bat with paging
fi

# ─── Utility Functions ──────────────────────────────────────────────────────
# Check if a name is a command, function, or alias
function is-callable {
  (( $+commands[$1] )) || (( $+functions[$1] )) || (( $+aliases[$1] ))
}

# Reload a function
function freload {
  while (( $# )); do
    unfunction $1
    autoload -U $1
    shift
  done
}

# ─── Help / Quick Reference ─────────────────────────────────────────────────
function h() {
  local CYAN='\033[0;36m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[1;33m'
  local MAGENTA='\033[0;35m'
  local BLUE='\033[0;34m'
  local NC='\033[0m'

  # Use print to interpret escape sequences (zsh builtin)
  print "$(cat << EOF

${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗
║                        TERMINAL QUICK REFERENCE                                ║
╚══════════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}━━━ KEYBOARD SHORTCUTS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${GREEN}Ctrl+R${NC}      Fuzzy search command history (fzf)
  ${GREEN}Ctrl+T${NC}      Fuzzy search files in current directory
  ${GREEN}Alt+C${NC}       Fuzzy cd into subdirectory
  ${GREEN}Tab${NC}         Autocomplete (press twice for menu)
  ${GREEN}→ or End${NC}    Accept autosuggestion
  ${GREEN}Ctrl+A${NC}      Move cursor to beginning of line
  ${GREEN}Ctrl+E${NC}      Move cursor to end of line
  ${GREEN}Ctrl+W${NC}      Delete word before cursor
  ${GREEN}Ctrl+U${NC}      Delete entire line
  ${GREEN}Ctrl+L${NC}      Clear screen
  ${GREEN}Ctrl+Z${NC}      Suspend process (use 'fg' to resume)

${CYAN}━━━ NAVIGATION ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${YELLOW}z ${MAGENTA}<partial>${NC}    Jump to directory (zoxide learns your habits)
  ${YELLOW}zi${NC}              Interactive directory picker
  ${YELLOW}..${NC}              Go up one directory
  ${YELLOW}...${NC}             Go up two directories
  ${YELLOW}....${NC}            Go up three directories
  ${YELLOW}d${NC}               List recent directories (if enabled)
  ${YELLOW}1-9${NC}             Jump to directory in stack

${CYAN}━━━ FILE LISTING (eza) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${YELLOW}ls${NC}              List files with colors
  ${YELLOW}l${NC}               List in one column, hidden files
  ${YELLOW}ll${NC}              List with details + git status
  ${YELLOW}la${NC}              List all with details
  ${YELLOW}tree${NC}            Tree view of directories

${CYAN}━━━ GIT SHORTCUTS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${YELLOW}gs${NC}              git status -sb (short)
  ${YELLOW}gu${NC}              Show git user (name & email)
  ${YELLOW}ga ${MAGENTA}<file>${NC}       git add
  ${YELLOW}gaa${NC}             git add --all
  ${YELLOW}gc${NC}              git commit -v
  ${YELLOW}gcm ${MAGENTA}"msg"${NC}       git commit -m "message"
  ${YELLOW}gco ${MAGENTA}<branch>${NC}    git checkout
  ${YELLOW}gcof${NC}            Fuzzy checkout branch (fzf)
  ${YELLOW}gsw ${MAGENTA}<branch>${NC}    git switch (modern checkout)
  ${YELLOW}gb${NC}              git branch
  ${YELLOW}gp${NC}              git push
  ${YELLOW}gl${NC}              git pull --rebase
  ${YELLOW}gf${NC}              git fetch --all --prune
  ${YELLOW}gd${NC}              git diff
  ${YELLOW}gds${NC}             git diff --staged
  ${YELLOW}glog${NC}            Pretty git log graph
  ${YELLOW}gsta${NC}            git stash push
  ${YELLOW}gstp${NC}            git stash pop
  ${YELLOW}gundo${NC}           Reset local to match remote (interactive)
  ${YELLOW}gundo-remote${NC}    Undo last commit from remote (interactive)

${CYAN}━━━ GIT IDENTITY MANAGEMENT (Multi-Account Support) ━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${GREEN}For multiple GitHub accounts (personal, work, client, etc.)${NC}

  ${YELLOW}git clone${NC} ${MAGENTA}<url>${NC}  Prompts for identity selection on every clone
  ${YELLOW}gidentities${NC}     List all configured identities
  ${YELLOW}gidentity-add${NC}   Add a new identity (alias, name, email)

  ${GREEN}How it works:${NC}
    • Configure during bootstrap or use ${YELLOW}gidentity-add${NC}
    • Identities stored in ${MAGENTA}~/.git-identities${NC}
    • Each clone prompts: "Which identity?" (personal, work, etc.)
    • Selected identity set in ${GREEN}local${NC} repo config (not global)
    • Example: Clone work repo → select "work" → commits use work email

  ${GREEN}Setup:${NC}
    • Run ${YELLOW}./bootstrap.sh${NC} → Answer "yes" to multiple identities
    • Or add later with ${YELLOW}gidentity-add${NC}
    • View configured identities: ${YELLOW}gidentities${NC}

${CYAN}━━━ USEFUL COMMANDS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${YELLOW}cat ${MAGENTA}<file>${NC}      View file with syntax highlighting (bat)
  ${YELLOW}grep ${MAGENTA}<pat>${NC}      Search with colors (or use 'rg' for ripgrep)
  ${YELLOW}fd ${MAGENTA}<pattern>${NC}    Fast find files
  ${YELLOW}c${NC}               Clear screen
  ${YELLOW}h${NC}               Show this help

${CYAN}━━━ SHELL MANAGEMENT ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${YELLOW}zshrc${NC}           Edit ~/.zshrc
  ${YELLOW}zshreload${NC}       Reload shell config
  ${YELLOW}zc${NC}              Clear completion cache & reload

${CYAN}━━━ PIPE SHORTCUTS (Global Aliases) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${YELLOW}cmd ${MAGENTA}H${NC}           Pipe to head (first 10 lines)
  ${YELLOW}cmd ${MAGENTA}T${NC}           Pipe to tail (last 10 lines)
  ${YELLOW}cmd ${MAGENTA}G${NC}           Pipe to grep
  ${YELLOW}cmd ${MAGENTA}L${NC}           Pipe to less
  ${YELLOW}cmd ${MAGENTA}CNT${NC}         Count lines (wc -l)

${CYAN}━━━ HISTORY TRICKS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  ${YELLOW}!!${NC}              Repeat last command
  ${YELLOW}!$${NC}              Last argument of previous command
  ${YELLOW}!*${NC}              All arguments of previous command
  ${YELLOW}!abc${NC}            Run last command starting with 'abc'
  ${YELLOW}^old^new${NC}        Replace 'old' with 'new' in last command
  ${GREEN}Space prefix${NC}    Command won't be saved to history

${CYAN}━━━ COMPLETION TIPS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

  • Completions are ${GREEN}case-insensitive${NC}
  • Partial paths work: ${YELLOW}cd /u/lo/b${NC} → /usr/local/bin
  • Fuzzy matching: typos are corrected automatically
  • Use ${GREEN}Tab${NC} twice to enter menu selection (arrow keys to navigate)

${BLUE}──────────────────────────────────────────────────────────────────────────────${NC}
  Dotfiles: ${YELLOW}\$DOTFILES${NC} (${DOTFILES:-~/dotfilesv2})
  Config:   ${YELLOW}h git${NC} for git aliases, ${YELLOW}h fzf${NC} for fzf shortcuts
${BLUE}──────────────────────────────────────────────────────────────────────────────${NC}

EOF
)"

  # Show section-specific help if argument provided
  case "$1" in
    git)
      print "${CYAN}Full git aliases:${NC}"
      alias | grep "^g" | sort
      ;;
    fzf)
      print "${CYAN}fzf environment:${NC}"
      echo "  FZF_DEFAULT_OPTS: $FZF_DEFAULT_OPTS"
      echo ""
      print "${CYAN}Key bindings:${NC}"
      echo "  Ctrl+R  - History search"
      echo "  Ctrl+T  - File search"
      echo "  Alt+C   - Directory search"
      ;;
  esac
}
