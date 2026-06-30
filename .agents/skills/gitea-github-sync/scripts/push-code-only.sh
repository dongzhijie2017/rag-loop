#!/usr/bin/env bash
# Push to Gitea (origin) first, then mirror code branches to GitHub.
# Usage: push-code-only.sh [branch]   (default: current branch)

set -euo pipefail

GITEA_HOST="${GITEA_HOST:-192.168.0.120}"

BRANCH="${1:-$(git rev-parse --abbrev-ref HEAD)}"

is_data_branch() {
  local b="$1"
  [[ "$b" == data/* ]] || [[ "$b" == bot/* ]]
}

if ! git remote get-url origin &>/dev/null; then
  echo "Error: no 'origin' remote. Run init-dual-remote.sh first." >&2
  exit 1
fi

ORIGIN_URL=$(git remote get-url origin)
if [[ "$ORIGIN_URL" != *"$GITEA_HOST"* ]]; then
  echo "Warning: origin does not point to Gitea ($ORIGIN_URL)." >&2
  echo "Expected host: $GITEA_HOST — continue anyway? (y/N)" >&2
  read -r ans
  [[ "${ans:-n}" == [yY] ]] || exit 1
fi

echo "→ Pushing to Gitea (origin): $BRANCH"
git push origin "$BRANCH"

if is_data_branch "$BRANCH"; then
  echo "Branch '$BRANCH' is data-only — skipping GitHub mirror."
  exit 0
fi

if ! git remote get-url github &>/dev/null; then
  echo "No 'github' remote configured — Gitea push complete."
  exit 0
fi

echo "→ Mirroring code to GitHub: $BRANCH"
git push github "$BRANCH"

echo "Done: origin (Gitea) + github (code mirror)."
