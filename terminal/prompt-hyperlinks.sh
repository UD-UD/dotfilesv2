#!/bin/sh
# Prompt hyperlink generator for Starship custom modules
# Outputs OSC 8 clickable hyperlinks for GitHub repos
#
# Usage: prompt-hyperlinks.sh dir-open    # OSC 8 open tag for repo URL
#        prompt-hyperlinks.sh branch      # Hyperlinked branch name

# Convert git remote URL to GitHub HTTPS URL
# Returns empty string (and fails) for non-GitHub remotes
_gh_url() {
  remote_url=$(git remote get-url origin 2>/dev/null) || return 1
  case "$remote_url" in
    git@github.com:*)
      url="https://github.com/${remote_url#git@github.com:}"
      printf '%s' "${url%.git}" ;;
    https://github.com/*)
      printf '%s' "${remote_url%.git}" ;;
    *)
      return 1 ;;
  esac
}

_dir_open() {
  gh_url=$(_gh_url) || return
  printf '\033]8;;%s\033\\' "$gh_url"
}

_branch() {
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  gh_url=$(_gh_url)
  if [ -n "$gh_url" ]; then
    printf '\033]8;;%s/tree/%s\033\\' "$gh_url" "$branch"
    printf '\033[1;35m%s\033[0m' "$branch"
    printf '\033]8;;\033\\ '
  else
    printf '\033[1;35m%s\033[0m ' "$branch"
  fi
}

case "$1" in
  dir-open) _dir_open ;;
  branch)   _branch ;;
esac
