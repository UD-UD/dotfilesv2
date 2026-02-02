#!/usr/bin/env bash
#
# git-summary - Show commit statistics by author
#
# Usage: git summary         (in a git repo)
#        git-summary.sh      (direct execution)
#

set -e

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Error: Not a git repository"
  exit 1
fi

# Colors
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Git Repository Summary${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Repository info
repo_name=$(basename "$(git rev-parse --show-toplevel)")
branch=$(git branch --show-current)
total_commits=$(git rev-list --count HEAD 2>/dev/null || echo "0")
first_commit=$(git log --reverse --format="%ar" | head -1)

echo -e "  Repository:  ${GREEN}$repo_name${NC}"
echo -e "  Branch:      ${GREEN}$branch${NC}"
echo -e "  Total:       ${GREEN}$total_commits${NC} commits"
echo -e "  Started:     $first_commit"
echo ""

echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
echo -e "${CYAN}  Commits by Author${NC}"
echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
echo ""

# Get commit counts by author (excluding merges)
git shortlog -sne --no-merges HEAD | while read -r count name_email; do
  # Extract name and email
  name=$(echo "$name_email" | sed 's/ <.*>//')
  email=$(echo "$name_email" | grep -o '<.*>' | tr -d '<>')

  # Calculate percentage
  if [[ $total_commits -gt 0 ]]; then
    pct=$((count * 100 / total_commits))
  else
    pct=0
  fi

  # Print with color
  printf "  ${RED}%5d${NC} (%2d%%)  ${BLUE}%-20s${NC} %s\n" "$count" "$pct" "$name" "$email"
done

echo ""
echo -e "${CYAN}───────────────────────────────────────────────────────────────${NC}"
echo ""

# Recent activity (last 7 days)
recent=$(git rev-list --count --since="7 days ago" HEAD 2>/dev/null || echo "0")
echo -e "  Last 7 days: ${GREEN}$recent${NC} commits"

# Files changed
files=$(git ls-files | wc -l | tr -d ' ')
echo -e "  Tracked files: ${GREEN}$files${NC}"
echo ""
