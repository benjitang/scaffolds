#!/usr/bin/env bash
set -euo pipefail
# Usage: ./start.sh [android|ios|web]
#
# For Android: set ADB_PATH if adb isn't on your PATH, e.g.
#   export ADB_PATH="/mnt/d/path/to/Sdk/platform-tools/adb.exe"

PROJECT_NAME="$(basename "$(pwd)")"
SESSION="${PROJECT_NAME}-dev"
PLATFORM="${1:-}"  # optional: android, ios, or web
ADB="${ADB_PATH:-adb}"

if ! command -v tmux >/dev/null; then
  echo "tmux not found. Install it with: sudo apt install tmux"
  exit 1
fi

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' is already running."
  echo "Attach with: tmux attach -t $SESSION"
  exit 0
fi

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

EXPO_PORT=8081
FRONTEND_CMD="npx expo start --offline --port $EXPO_PORT"
if [ "$PLATFORM" == "android" ]; then
  FRONTEND_CMD="REACT_NATIVE_PACKAGER_HOSTNAME=10.0.2.2 $FRONTEND_CMD --android"

  echo "==> Setting up adb reverse for Android"
  if command -v "$ADB" >/dev/null; then
    if "$ADB" get-state >/dev/null 2>&1; then
      "$ADB" reverse tcp:$EXPO_PORT tcp:$EXPO_PORT
      echo "  adb reverse tcp:$EXPO_PORT tcp:$EXPO_PORT done"
    else
      echo "  no device/emulator detected - skipping adb reverse (start your emulator first if this fails)"
    fi
  else
    echo "  adb not found (set ADB_PATH if it's not on your PATH) - skipping adb reverse"
  fi
elif [ -n "$PLATFORM" ]; then
  FRONTEND_CMD="$FRONTEND_CMD --$PLATFORM"
fi

tmux new-session -d -s "$SESSION" -n dev
tmux send-keys -t "$SESSION:dev" "cd backend && uv run uvicorn app.main:app --reload" C-m
tmux split-window -h -t "$SESSION:dev"
tmux send-keys -t "$SESSION:dev.1" "cd frontend && $FRONTEND_CMD" C-m

echo "Started '$SESSION' - backend (left) + frontend/Expo (right)"

if [ -n "${TMUX:-}" ]; then
  tmux switch-client -t "$SESSION"
else
  tmux attach -t "$SESSION"
fi