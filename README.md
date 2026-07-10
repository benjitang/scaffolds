# scaffolds

Quick-start templates for new projects. Currently supports: `fullstack-py-react`.

## Usage

```bash
./create-project.sh <new-project-name> [destination-dir]
```

**Example:**
```bash
./create-project.sh my-cool-app ~/Code/projects
```

Defaults to the current directory if `destination-dir` is omitted.

## What it does

1. Copies `fullstack-py-react/` to `<destination-dir>/<new-project-name>`
   (excludes `node_modules`, `.venv`, `__pycache__`, lockfiles, `.git`)
2. Replaces every `PROJECT_NAME_PLACEHOLDER` placeholder in the copied files with your project name
3. Installs backend deps: `uv sync` (in `backend/`)
4. Installs frontend deps: `npm install` (in `frontend/`)
5. Runs `git init` in the new project

## Running the dev servers

From the project root (the folder containing `backend/` and `frontend/`):

```bash
./start.sh   # opens a tmux session, backend (left pane) + frontend (right pane)
./stop.sh    # kills that session, stops both
```

`start.sh` runs `uv run uvicorn main:app --reload` in `backend/`, so `backend/main.py` needs a FastAPI instance named `app`. Re-attach anytime with `tmux attach -t <project-name>-dev`.

## Requirements

- [`uv`](https://astral.sh/uv) installed and on `$PATH`
- `npm` installed
- `rsync`
- `tmux` (for `start.sh`/`stop.sh`)

## Adding the placeholder to new scaffold files

Any file that should carry the project's name needs the literal token:

```
PROJECT_NAME_PLACEHOLDER
```

e.g. in `pyproject.toml`:
```toml
name = "PROJECT_NAME_PLACEHOLDER-backend"
```

Note: don't wrap the token in extra underscores (e.g. `__PROJECT_NAME__`) — package name
validators (uv, pip) reject names that start/end with `_`, so the file becomes unparseable.

## Notes

- Fails if the destination folder already exists — won't overwrite anything.
- Only `fullstack-py-react` is wired up right now. `cpp-cmake` and `python-cli` are not yet supported by this script.