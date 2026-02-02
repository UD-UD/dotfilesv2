#!/usr/bin/env bash
#
# git-setup - Initialize a new git repository with standard files
#
# Usage: git setup <repo-name>           (creates local repo)
#        git setup <repo-name> --github  (creates and pushes to GitHub)
#
# Examples:
#   git setup my-project
#   git setup my-project --github
#   git setup ud-ud/my-project --github
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_step() { echo -e "${CYAN}→${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# Parse arguments
REPO_NAME="$1"
CREATE_GITHUB=false

if [[ "$2" == "--github" ]] || [[ "$2" == "-g" ]]; then
  CREATE_GITHUB=true
fi

# Show usage
if [[ -z "$REPO_NAME" ]]; then
  echo ""
  echo "Usage: git setup <repo-name> [--github]"
  echo ""
  echo "Examples:"
  echo "  git setup my-project           # Local repo only"
  echo "  git setup my-project --github  # Create on GitHub too"
  echo ""
  exit 1
fi

# Extract just the repo name if user/repo format provided
if [[ "$REPO_NAME" == */* ]]; then
  REPO_NAME="${REPO_NAME#*/}"
fi

# Check if directory already exists
if [[ -d "$REPO_NAME" ]]; then
  print_error "Directory '$REPO_NAME' already exists"
  exit 1
fi

echo ""
echo -e "${CYAN}Creating new repository: ${GREEN}$REPO_NAME${NC}"
echo ""

# Create directory and initialize
print_step "Creating directory..."
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

print_step "Initializing git repository..."
git init -b main --quiet

# Create standard files
print_step "Creating standard files..."

cat > README.md << EOF
# $REPO_NAME

## Description

TODO: Add project description

## Installation

\`\`\`bash
# TODO: Add installation instructions
\`\`\`

## Usage

\`\`\`bash
# TODO: Add usage examples
\`\`\`

## License

MIT
EOF

cat > .gitignore << 'EOF'
# OS
.DS_Store
Thumbs.db

# Editors
.idea/
.vscode/
*.swp
*.swo
*~

# Dependencies
node_modules/
vendor/
__pycache__/
*.pyc

# Build
dist/
build/
*.egg-info/

# Environment
.env
.env.local
*.log
EOF

cat > CHANGELOG.md << EOF
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Initial project setup
EOF

# Initial commit
print_step "Creating initial commit..."
git add .
git commit -m "Initial commit" --quiet

print_success "Local repository created!"

# Create on GitHub if requested
if [[ "$CREATE_GITHUB" == true ]]; then
  echo ""

  if ! command -v gh &>/dev/null; then
    print_error "GitHub CLI (gh) not installed. Install with: brew install gh"
    echo ""
    echo "To manually push to GitHub:"
    echo "  1. Create repo on github.com"
    echo "  2. git remote add origin git@github.com:YOUR_USER/$REPO_NAME.git"
    echo "  3. git push -u origin main"
    exit 1
  fi

  # Check if authenticated
  if ! gh auth status &>/dev/null; then
    print_error "Not logged in to GitHub. Run: gh auth login"
    exit 1
  fi

  print_step "Creating GitHub repository..."
  if gh repo create "$REPO_NAME" --private --source=. --push; then
    print_success "Pushed to GitHub!"
    echo ""
    echo -e "  ${CYAN}Repository URL:${NC} $(gh repo view --json url -q .url)"
  else
    print_error "Failed to create GitHub repository"
    exit 1
  fi
fi

echo ""
echo -e "${GREEN}Done!${NC} Your new repository is ready at: ${CYAN}$(pwd)${NC}"
echo ""
echo "Next steps:"
echo "  cd $REPO_NAME"
echo "  # Start coding!"
echo ""
