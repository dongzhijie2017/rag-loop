#!/usr/bin/env bash
# Initialize a new project with Gitea (origin) + GitHub (github) dual remotes.
# Usage: init-dual-remote.sh <gitea-user> <repo-name> [github-user]

set -euo pipefail

GITEA_HOST="${GITEA_HOST:-http://192.168.0.120:3000}"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <gitea-user> <repo-name> [github-user]" >&2
  exit 1
fi

GITEA_USER="$1"
REPO_NAME="$2"
GITHUB_USER="${3:-$GITEA_USER}"

GITEA_URL="${GITEA_HOST}/${GITEA_USER}/${REPO_NAME}.git"
GITHUB_URL="git@github.com:${GITHUB_USER}/${REPO_NAME}.git"

if [[ ! -d .git ]]; then
  git init
  git branch -M main 2>/dev/null || true
fi

if git remote get-url origin &>/dev/null; then
  CURRENT=$(git remote get-url origin)
  if [[ "$CURRENT" != *"192.168.0.120"* ]]; then
    echo "Warning: origin already exists ($CURRENT). Rename to github first if migrating." >&2
    exit 1
  fi
else
  git remote add origin "$GITEA_URL"
  echo "Added origin → $GITEA_URL"
fi

if git remote get-url github &>/dev/null; then
  echo "Remote 'github' already exists, skipping."
else
  git remote add github "$GITHUB_URL"
  echo "Added github → $GITHUB_URL"
fi

if [[ ! -f .gitignore ]]; then
  cat > .gitignore << 'EOF'
# Secrets — never sync to GitHub
.env
.env.*
*.pem
*.key
credentials.json
secrets/

# Runtime / generated data — Gitea only if needed
fund_data/
data/
logs/
.cache/
*.sqlite
*.db

# Dependencies & build
node_modules/
__pycache__/
.venv/
dist/
build/
EOF
  echo "Created default .gitignore (code-only GitHub sync)."
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "Next steps:"
echo "  1. Create empty repo at ${GITEA_HOST}/${GITEA_USER}/${REPO_NAME}"
echo "  2. Create empty repo at https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo "  3. git add . && git commit -m 'chore: initial commit'"
echo "  4. git push -u origin main"
echo "  5. ${SCRIPT_DIR}/push-code-only.sh main"
