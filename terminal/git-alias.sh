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
