#!/usr/bin/env bash
set -euo pipefail
# Usage: ./start.sh [android|ios|web]

PROJECT_NAME="$(basename "$(pwd)")"
SESSION="${PROJECT_NAME}-dev"
PLATFORM="${1:-}"  # optional: android, ios, or web

if ! command -v tmux >/dev/null; then
  echo "tmux not found. Install it with: sudo apt install tmux"
  exit 1
fi

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' is already running."
  echo "Attach with: tmux attach -t $SESSION"
  exit 0
fi

FRONTEND_CMD="npx expo start"
if [ "$PLATFORM" == "android" ]; then
  FRONTEND_CMD="REACT_NATIVE_PACKAGER_HOSTNAME=10.0.2.2 npx expo start --android --offline"
elif [ -n "$PLATFORM" ]; then
  FRONTEND_CMD="npx expo start --$PLATFORM"
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