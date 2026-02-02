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
alias gcm='git checkout main 2>/dev/null || git checkout master'  # Checkout main/master

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
  # Fuzzy checkout branch
  alias gcof='git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/origin/##" | sort -u | fzf | xargs git checkout'

  # Fuzzy checkout recent branches
  alias gcor='git branch --sort=-committerdate | head -20 | fzf | xargs git checkout'

  # Fuzzy add files
  alias gaf='git ls-files -m -o --exclude-standard | fzf -m | xargs git add'

  # Fuzzy show commit
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
