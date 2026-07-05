#!/bin/sh
# Claude Code status line: model, cwd, git branch, context remaining

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  model=$(echo "$input" | jq -r '.model.display_name // empty')
  dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
  remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // (100 - (.context_window.used_percentage // 0))')
else
  model=""
  dir=""
  remaining=""
fi

[ -z "$dir" ] && dir="$PWD"
dir_display=$(basename "$dir" 2>/dev/null)
[ -z "$dir_display" ] && dir_display="$dir"

branch=""
if command -v git >/dev/null 2>&1; then
  branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
fi

if [ -n "$remaining" ]; then
  remaining_display=$(printf '%.0f' "$remaining" 2>/dev/null)
  [ -z "$remaining_display" ] && remaining_display="$remaining"
  context_display="${remaining_display}% left"
else
  context_display="n/a"
fi

[ -z "$model" ] && model="unknown"

out="\033[2m${model} | ${dir_display}"
[ -n "$branch" ] && out="${out} | ${branch}"
out="${out} | Context: ${context_display}\033[0m"

printf '%b' "$out"
