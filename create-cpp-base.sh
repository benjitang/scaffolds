#!/usr/bin/env bash
set -euo pipefail
# Usage: ./create-cpp-base.sh <new-project-name> [destination-dir]
#
# Example:
#   ./create-cpp-base.sh my-cpp-tool ~/Code/projects
#
# Convention: inside the scaffold folder, any file that should carry the
# project's name must contain the literal placeholder token: PROJECT_NAME_PLACEHOLDER
# This script replaces every occurrence of that token with the new project name.

SCAFFOLDS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLACEHOLDER="PROJECT_NAME_PLACEHOLDER"
SCAFFOLD_NAME="cpp-base"
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
  --exclude 'build' \
  --exclude 'bin' \
  --exclude '.git' \
  "$SCAFFOLD_PATH"/ "$TARGET_PATH"/

echo "==> Replacing '$PLACEHOLDER' with '$PROJECT_NAME' in text files"
grep -rIl "$PLACEHOLDER" "$TARGET_PATH" 2>/dev/null | while read -r file; do
  sed -i "s/$PLACEHOLDER/$PROJECT_NAME/g" "$file"
  echo "  updated: ${file#$TARGET_PATH/}"
done

cd "$TARGET_PATH"

echo "==> Making scripts executable"
if [ -d "scripts" ]; then
  chmod +x scripts/*.sh 2>/dev/null || true
fi

echo "==> Configuring (cmake)"
if [ -f "CMakeLists.txt" ]; then
  if command -v cmake >/dev/null; then
    cmake -S . -B build > /dev/null
  else
    echo "  cmake not found on PATH - skipping configure"
  fi
else
  echo "  no CMakeLists.txt found - skipping"
fi

echo "==> Git init"
git init -q
echo "$PROJECT_NAME" > .project-name

echo ""
echo "Done. New project ready at: $TARGET_PATH"