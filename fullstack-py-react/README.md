# PROJECT_NAME_PLACEHOLDER

Full-stack app: FastAPI backend + React (Vite) frontend.

## Prerequisites

- [`uv`](https://astral.sh/uv) — Python package/env manager
- `npm`
- `tmux` (for `start.sh`/`stop.sh`)

## Running the app

From the project root:

```bash
./start.sh
```

This opens a tmux session with two panes:
- **Left:** backend — `uv run uvicorn main:app --reload` → http://localhost:8000
- **Right:** frontend — `npm run dev` → http://localhost:5173 (Vite's default)

To stop both:

```bash
./stop.sh
```

### Re-attaching to a running session

If you close your terminal but the session is still running, get back into it with:

```bash
tmux attach -t PROJECT_NAME_PLACEHOLDER-dev
```

### Switching between panes

- `Ctrl+b` then arrow keys (default tmux)
- `Ctrl+h` / `Ctrl+l` if you use `vim-tmux-navigator`

## Running backend/frontend manually (without tmux)

**Backend:**
```bash
cd backend
uv run uvicorn main:app --reload
```

**Frontend** (separate terminal):
```bash
cd frontend
npm run dev
```

## Project structure

```
PROJECT_NAME_PLACEHOLDER/
├── start.sh          # start both dev servers
├── stop.sh            # stop both
├── backend/           # FastAPI app (managed with uv)
│   ├── main.py
│   └── pyproject.toml
└── frontend/           # React app (Vite)
    ├── src/
    └── package.json
```