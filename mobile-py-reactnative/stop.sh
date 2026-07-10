#!/usr/bin/env bash
set -euo pipefail

# Stops the backend + frontend dev session started by start.sh.
# Run from the project root (same place you ran start.sh).

PROJECT_NAME="$(basename "$(pwd)")"
SESSION="${PROJECT_NAME}-dev"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux kill-session -t "$SESSION"
  echo "Stopped '$SESSION'"
else
  echo "No running session named '$SESSION'"
fi