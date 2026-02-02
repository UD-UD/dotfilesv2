#
# Git Aliases - Optimized for fast workflow
#

# ─── Core Commands ──────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'        # Short status with branch info
alias gst='git status'           # Full status

# ─── Staging & Commits ──────────────────────────────────────────────────────
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'      # Interactive staging
alias gc='git commit -v'
alias gca='git commit -v --amend'
alias gcm='git commit -m'
alias gcam='git commit -a -m'    # Add all and commit with message

# ─── Branches ───────────────────────────────────────────────────────────────
alias gb='git branch'
alias gba='git branch -a'        # All branches (local + remote)
alias gbl='git branch -vv'       # Verbose with upstream info
alias gbd='git branch -d'        # Delete (safe)
alias gbD='git branch -D'        # Delete (force)
alias gco='git checkout'
alias gcb='git checkout -b'      # Create and checkout branch
alias gsw='git switch'           # Modern branch switching
alias gswc='git switch -c'       # Create and switch to branch
alias gcom='git checkout main 2>/dev/null || git checkout master'  # Checkout main/master

# ─── Remote Operations ──────────────────────────────────────────────────────
alias gf='git fetch --all --prune'
alias gl='git pull --rebase'
alias gp='git push'
alias gpf='git push --force-with-lease'  # Safer force push
alias gpo='git push origin'
alias gpu='git push -u origin HEAD'      # Push and set upstream

# ─── Diff & Log ─────────────────────────────────────────────────────────────
alias gd='git diff'
alias gds='git diff --staged'
alias gdt='git difftool'
alias glog='git log --oneline --graph --decorate -20'
alias gloga='git log --oneline --graph --decorate --all'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset"'

# ─── Stash ──────────────────────────────────────────────────────────────────
alias gsta='git stash push'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstd='git stash drop'
alias gsts='git stash show --patch'

# ─── Merge & Rebase ─────────────────────────────────────────────────────────
alias gm='git merge'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'       # Interactive rebase

# ─── Reset & Clean ──────────────────────────────────────────────────────────
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias gclean='git clean -fd'     # Remove untracked files and directories
alias gdisc='git checkout -- .'  # Discard all changes (alias for git discard in .gitconfig)

# ─── Cherry-pick ────────────────────────────────────────────────────────────
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

# ─── Misc ───────────────────────────────────────────────────────────────────
alias gr='git remote -v'
alias gcount='git shortlog -sn'  # Commit count by author

# ─── Interactive with fzf (if available) ────────────────────────────────────
if command -v fzf &>/dev/null; then
  # Fuzzy checkout branch (using null-byte separation for safety)
  alias gcof='git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/origin/##" | sort -u | fzf --print0 | xargs -0 git checkout'

  # Fuzzy checkout recent branches (using null-byte separation for safety)
  alias gcor='git branch --sort=-committerdate | head -20 | fzf --print0 | xargs -0 git checkout'

  # Fuzzy add files (using null-byte separation for safety)
  alias gaf='git ls-files -m -o --exclude-standard -z | fzf -m --read0 --print0 | xargs -0 git add'

  # Fuzzy show commit (commits are hashes, safe without null-bytes)
  alias gshow='git log --oneline | fzf --preview "git show {1}" | awk "{print \$1}" | xargs git show'
fi

# ─── Helper Functions ───────────────────────────────────────────────────────
# Get current branch name
function current_branch() {
  git symbolic-ref --short HEAD 2>/dev/null
}

# Push current branch to origin
function ggpush() {
  git push origin "$(current_branch)" "$@"
}

# Pull current branch from origin with rebase
function ggpull() {
  git pull --rebase origin "$(current_branch)" "$@"
}

# Create a new branch from main/master and push
function gnew() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "Usage: gnew <branch-name>"
    return 1
  fi
  git checkout main 2>/dev/null || git checkout master
  git pull --rebase
  git checkout -b "$branch"
  git push -u origin "$branch"
}

# Show current git user
function gu() {
  local name=$(git config user.name)
  local email=$(git config user.email)
  local global_name=$(git config --global user.name)
  local global_email=$(git config --global user.email)

  print ""
  print "  \033[0;36mGit User Configuration\033[0m"
  print "  ─────────────────────────────────"
  print ""
  print "  \033[1;33mCurrent repo:\033[0m"
  print "    Name:  ${name:-\033[0;35m(using global)\033[0m}"
  print "    Email: ${email:-\033[0;35m(using global)\033[0m}"
  print ""
  print "  \033[1;33mGlobal:\033[0m"
  print "    Name:  ${global_name:-\033[0;31m(not set)\033[0m}"
  print "    Email: ${global_email:-\033[0;31m(not set)\033[0m}"
  print ""
}

# Reset local to match remote (interactive)
function gundo() {
  local branch=$(current_branch)
  local remote="${1:-origin}"

  if [[ -z "$branch" ]]; then
    print "\033[0;31mError: Not on a branch\033[0m"
    return 1
  fi

  print ""
  print "  \033[0;36mReset Local to Remote\033[0m"
  print "  ─────────────────────────────────"
  print ""
  print "  Branch: \033[1;33m$branch\033[0m"
  print "  Remote: \033[1;33m$remote/$branch\033[0m"
  print ""

  # Fetch latest
  git fetch "$remote" "$branch" 2>/dev/null

  # Show what will be lost
  print "  \033[0;31m━━━ Changes that will be DISCARDED ━━━\033[0m"
  print ""

  # Modified files
  local modified=$(git diff --name-only 2>/dev/null)
  if [[ -n "$modified" ]]; then
    print "  \033[1;33mModified files:\033[0m"
    echo "$modified" | sed 's/^/    /'
    print ""
  fi

  # Staged files
  local staged=$(git diff --staged --name-only 2>/dev/null)
  if [[ -n "$staged" ]]; then
    print "  \033[1;33mStaged files:\033[0m"
    echo "$staged" | sed 's/^/    /'
    print ""
  fi

  # Untracked files
  local untracked=$(git ls-files --others --exclude-standard 2>/dev/null)
  if [[ -n "$untracked" ]]; then
    print "  \033[1;33mUntracked files (will be DELETED):\033[0m"
    echo "$untracked" | sed 's/^/    /'
    print ""
  fi

  # Local commits not on remote
  local local_commits=$(git log "$remote/$branch..HEAD" --oneline 2>/dev/null)
  if [[ -n "$local_commits" ]]; then
    print "  \033[1;33mLocal commits (will be LOST):\033[0m"
    echo "$local_commits" | sed 's/^/    /'
    print ""
  fi

  if [[ -z "$modified" && -z "$staged" && -z "$untracked" && -z "$local_commits" ]]; then
    print "  \033[0;32mAlready in sync with remote!\033[0m"
    print ""
    return 0
  fi

  print "  \033[0;31m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  print ""
  print -n "  \033[0;31mThis is DESTRUCTIVE. Proceed? [y/N]: \033[0m"
  read response

  if [[ "$response" =~ ^[Yy]$ ]]; then
    git reset --hard "$remote/$branch"
    git clean -fd
    print ""
    print "  \033[0;32m✓ Reset complete. Local now matches $remote/$branch\033[0m"
    print ""
  else
    print ""
    print "  \033[0;33mAborted.\033[0m"
    print ""
  fi
}

# Delete last commit from remote (interactive)
function gundo-remote() {
  local branch=$(current_branch)
  local remote="${1:-origin}"
  local num_commits="${2:-1}"

  if [[ -z "$branch" ]]; then
    print "\033[0;31mError: Not on a branch\033[0m"
    return 1
  fi

  print ""
  print "  \033[0;36mUndo Last Remote Commit(s)\033[0m"
  print "  ─────────────────────────────────"
  print ""
  print "  Branch: \033[1;33m$branch\033[0m"
  print "  Remote: \033[1;33m$remote\033[0m"
  print "  Commits to remove: \033[1;33m$num_commits\033[0m"
  print ""

  # Show commits that will be removed
  print "  \033[0;31m━━━ Commit(s) that will be REMOVED from remote ━━━\033[0m"
  print ""
  git log -"$num_commits" --oneline | sed 's/^/    /'
  print ""
  print "  \033[0;31m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  print ""

  print "  \033[0;33mThis will:\033[0m"
  echo "    1. Reset local branch back $num_commits commit(s)"
  echo "    2. Force push to $remote (rewriting history)"
  print ""
  print "  \033[0;31m⚠️  WARNING: This rewrites remote history!\033[0m"
  print "  \033[0;31m⚠️  Others who pulled will have conflicts!\033[0m"
  print ""
  print -n "  \033[0;31mType 'yes' to confirm: \033[0m"
  read response

  if [[ "$response" == "yes" ]]; then
    git reset --hard "HEAD~$num_commits"
    git push "$remote" "$branch" --force-with-lease
    print ""
    print "  \033[0;32m✓ Removed $num_commits commit(s) from $remote/$branch\033[0m"
    print ""
  else
    print ""
    print "  \033[0;33mAborted.\033[0m"
    print ""
  fi
}

# ─── Multi-Identity Clone Wrapper ───────────────────────────────────────────
# Automatically prompt for git identity on clone if multiple identities configured

function _gclone_real() {
  # Check if identities file exists
  local identities_file="$HOME/.git-identities"

  if [[ ! -f "$identities_file" ]]; then
    # No identities configured, use normal git clone
    command git clone "$@"
    return $?
  fi

  # Read identities from file (skip comments and empty lines)
  local -a identities
  while IFS='|' read -r alias name email; do
    [[ "$alias" =~ ^[[:space:]]*# ]] && continue  # Skip comments
    [[ -z "$alias" ]] && continue  # Skip empty lines
    identities+=("$alias|$name|$email")
  done < "$identities_file"

  if [[ ${#identities[@]} -eq 0 ]]; then
    # No valid identities, use normal git clone
    command git clone "$@"
    return $?
  fi

  if [[ ${#identities[@]} -eq 1 ]]; then
    # Only one identity, use it automatically
    local identity=(${(s:|:)identities[1]})
    local selected_alias="${identity[1]}"
    local selected_name="${identity[2]}"
    local selected_email="${identity[3]}"
  else
    # Multiple identities, prompt user to select
    echo ""
    echo "  Select Git Identity for this clone:"
    echo "  ────────────────────────────────────"
    echo ""

    local i=1
    for id in $identities; do
      local parts=(${(s:|:)id})
      echo "  $i) ${parts[1]} - ${parts[2]} <${parts[3]}>"
      ((i++))
    done

    echo ""
    echo -n "  Select [1-${#identities[@]}]: "
    read selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#identities[@]} ]]; then
      echo "Invalid selection. Using default git clone."
      command git clone "$@"
      return $?
    fi

    local selected=(${(s:|:)identities[$selection]})
    local selected_alias="${selected[1]}"
    local selected_name="${selected[2]}"
    local selected_email="${selected[3]}"
  fi

  # Extract repository URL and destination from arguments
  local clone_url=""
  local clone_dest=""
  local -a git_args=()

  # Parse arguments (handle various git clone formats)
  for arg in "$@"; do
    if [[ "$arg" =~ ^(https?://|git://|ssh://|git@|[^@]+@[^:]+:) ]]; then
      clone_url="$arg"
    elif [[ "$arg" =~ ^- ]]; then
      git_args+=("$arg")
    elif [[ -n "$clone_url" ]] && [[ -z "$clone_dest" ]]; then
      clone_dest="$arg"
    else
      git_args+=("$arg")
    fi
  done

  # Execute git clone
  echo ""
  echo "Cloning with identity: $selected_alias"

  if [[ -n "$clone_dest" ]]; then
    command git clone "${git_args[@]}" "$clone_url" "$clone_dest"
  else
    command git clone "${git_args[@]}" "$clone_url"
  fi

  local clone_status=$?
  if [[ $clone_status -ne 0 ]]; then
    return $clone_status
  fi

  # Determine actual clone destination
  local repo_dir
  if [[ -n "$clone_dest" ]]; then
    repo_dir="$clone_dest"
  else
    # Extract repo name from URL
    repo_dir=$(basename "$clone_url" .git)
  fi

  # Set local git config in the cloned repository
  if [[ -d "$repo_dir" ]]; then
    (
      cd "$repo_dir" || return 1
      git config user.name "$selected_name"
      git config user.email "$selected_email"

      echo ""
      echo "  ✓ Git identity configured:"
      echo "    Name:  $selected_name"
      echo "    Email: $selected_email"
      echo ""
    )
  fi
}

# Identity-aware clone (use 'gclone' instead of 'git clone' when you want identity selection)
alias gclone='_gclone_real'

# ─── Identity Management Helpers ────────────────────────────────────────────

# List configured git identities
function gidentities() {
  local identities_file="$HOME/.git-identities"

  if [[ ! -f "$identities_file" ]]; then
    echo "No git identities configured."
    echo "Run bootstrap.sh to set up identities."
    return 1
  fi

  echo ""
  echo "  Configured Git Identities"
  echo "  ─────────────────────────────────"
  echo ""

  while IFS='|' read -r alias name email; do
    [[ "$alias" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$alias" ]] && continue
    echo "  • $alias - $name <$email>"
  done < "$identities_file"

  echo ""
}

# Add a new git identity
function gidentity-add() {
  local identities_file="$HOME/.git-identities"

  # Create file if it doesn't exist
  if [[ ! -f "$identities_file" ]]; then
    cat > "$identities_file" << 'EOF'
# Git Identities - Auto-generated by bootstrap.sh
# Format: ALIAS|Name|Email
# Example: PERSONAL|John Doe|john@personal.com
EOF
    chmod 600 "$identities_file"
  fi

  echo ""
  read "alias?  Identity alias (e.g., 'work', 'personal'): "
  read "name?  Your name for this identity: "
  read "email?  Your email for this identity: "

  echo "$alias|$name|$email" >> "$identities_file"
  echo ""
  echo "  ✓ Identity '$alias' added"
  echo ""
}
