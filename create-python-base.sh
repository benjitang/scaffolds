#!/usr/bin/env bash
set -euo pipefail

# Usage: ./create-python-base.sh <new-project-name> [destination-dir]
#
# Example:
#   ./create-python-base.sh my-tool ~/Code/projects
#
# Convention: inside the scaffold folder, any file that should carry the
# project's name must contain the literal placeholder token: PROJECT_NAME_PLACEHOLDER
# This script replaces every occurrence of that token with the new project name.

SCAFFOLDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLACEHOLDER="PROJECT_NAME_PLACEHOLDER"
SCAFFOLD_NAME="python-base"
SCAFFOLD_PATH="$SCAFFOLDS_DIR/$SCAFFOLD_NAME"

usage() {
  echo "Usage: $0 <new-project-name> [destination-dir]"
  echo "(scaffolds: $SCAFFOLD_NAME)"
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
  --exclude 'venv' \
  --exclude '.venv' \
  --exclude '__pycache__' \
  --exclude '.git' \
  --exclude 'uv.lock' \
  "$SCAFFOLD_PATH"/ "$TARGET_PATH"/

echo "==> Replacing '$PLACEHOLDER' with '$PROJECT_NAME' in text files"
grep -rIl "$PLACEHOLDER" "$TARGET_PATH" 2>/dev/null | while read -r file; do
  sed -i "s/$PLACEHOLDER/$PROJECT_NAME/g" "$file"
  echo "  updated: ${file#$TARGET_PATH/}"
done

cd "$TARGET_PATH"

echo "==> Installing dependencies (uv)"
if [ -f "pyproject.toml" ]; then
  if command -v uv >/dev/null; then
    uv sync
  else
    echo "  uv not found on PATH - skipping install"
  fi
else
  echo "  no pyproject.toml found - skipping"
fi

echo "==> Git init"
git init -q
echo "$PROJECT_NAME" > .project-name

echo ""
echo "Done. New project ready at: $TARGET_PATH"