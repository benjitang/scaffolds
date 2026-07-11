#!/usr/bin/env bash
set -euo pipefail

# Usage: ./create-mobile.sh <new-project-name> [destination-dir]
#
# Example:
#   ./create-mobile.sh my-cool-app ~/Code/projects
#
# NOTE: hardcoded to only scaffold "mobile-py-reactnative".
#
# Convention: inside the scaffold folder, any file that should carry the
# project's name must contain the literal placeholder token:
# PROJECT_NAME_PLACEHOLDER
# This script replaces every occurrence of that token with the new project name.

SCAFFOLDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLACEHOLDER="PROJECT_NAME_PLACEHOLDER"
SCAFFOLD_NAME="mobile-py-reactnative"
SCAFFOLD_PATH="$SCAFFOLDS_DIR/$SCAFFOLD_NAME"

usage() {
  echo "Usage: $0 <new-project-name> [destination-dir]"
  echo "(currently only scaffolds: $SCAFFOLD_NAME)"
  exit 1
}

[ $# -lt 1 ] && usage

PROJECT_NAME="$1"
DEST_DIR="${2:-$PWD}"
TARGET_PATH="$DEST_DIR/$PROJECT_NAME"

if [ ! -d "$SCAFFOLD_PATH" ]; then
  echo "Error: scaffold not found at $SCAFFOLD_PATH"
  exit 1
fi

if [ -d "$TARGET_PATH" ]; then
  echo "Error: $TARGET_PATH already exists"
  exit 1
fi

echo "==> Copying $SCAFFOLD_NAME -> $TARGET_PATH"
mkdir -p "$DEST_DIR"
rsync -a \
  --exclude 'node_modules' \
  --exclude 'venv' \
  --exclude '.venv' \
  --exclude '__pycache__' \
  --exclude '.git' \
  --exclude 'build' \
  --exclude 'dist' \
  --exclude 'uv.lock' \
  --exclude 'package-lock.json' \
  --exclude 'yarn.lock' \
  --exclude '.expo' \
  --exclude '.expo-shared' \
  --exclude 'ios/Pods' \
  --exclude 'ios/build' \
  --exclude 'android/.gradle' \
  --exclude 'android/build' \
  --exclude 'android/app/build' \
  "$SCAFFOLD_PATH"/ "$TARGET_PATH"/

echo "==> Replacing '$PLACEHOLDER' with '$PROJECT_NAME' in text files"
grep -rIl "$PLACEHOLDER" "$TARGET_PATH" 2>/dev/null | while read -r file; do
  sed -i "s/$PLACEHOLDER/$PROJECT_NAME/g" "$file"
  echo "  updated: ${file#$TARGET_PATH/}"
done

cd "$TARGET_PATH"

echo "==> Installing backend (uv)"
if [ -f "backend/pyproject.toml" ]; then
  if command -v uv >/dev/null; then
    (cd backend && uv sync)
  else
    echo "  uv not found on PATH - skipping backend install"
  fi
else
  echo "  no backend/pyproject.toml found - skipping"
fi

echo "==> Installing frontend (npm)"
if [ -f "frontend/package.json" ]; then
  (cd frontend && npm install)
else
  echo "  no frontend/package.json found - skipping"
fi

echo "==> Installing iOS pods (if applicable)"
if [ -f "frontend/ios/Podfile" ]; then
  if command -v pod >/dev/null; then
    (cd frontend/ios && pod install)
  else
    echo "  pod not found on PATH - skipping (only needed on macOS)"
  fi
else
  echo "  no frontend/ios/Podfile found - skipping"
fi

echo "==> Git init"
git init -q
echo "$PROJECT_NAME" > .project-name

echo ""
echo "Done. New project ready at: $TARGET_PATH"