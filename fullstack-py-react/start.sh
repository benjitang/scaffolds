#!/usr/bin/env bash
set -euo pipefail

# Starts backend + frontend dev servers side-by-side in a tmux session.
# Run from the project root (the folder containing backend/ and frontend/).

PROJECT_NAME="$(basename "$(pwd)")"
SESSION="${PROJECT_NAME}-dev"

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

tmux new-session -d -s "$SESSION" -n dev

# Left pane: backend
tmux send-keys -t "$SESSION:dev" "cd backend && uv run uvicorn app.main:app --reload" C-m

# Right pane: frontend
tmux split-window -h -t "$SESSION:dev"
tmux send-keys -t "$SESSION:dev.1" "cd frontend && npm run dev" C-m

echo "Started '$SESSION' - backend (left) + frontend (right)"

if [ -n "${TMUX:-}" ]; then
  tmux switch-client -t "$SESSION"
else
  tmux attach -t "$SESSION"
fi