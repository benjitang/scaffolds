# scaffolds

Quick-start templates for new projects. Currently supports: `fullstack-py-react`, `python-base`.

## Usage

```bash
./create-fullstack.sh <new-project-name> [destination-dir]
./create-python-base.sh <new-project-name> [destination-dir]
```

**Examples:**
```bash
./create-fullstack.sh my-cool-app ~/Code/projects
./create-python-base.sh my-tool ~/Code/projects
```

Defaults to the current directory if `destination-dir` is omitted.

## What `create-fullstack.sh` does

1. Copies `fullstack-py-react/` to `<destination-dir>/<new-project-name>`
   (excludes `node_modules`, `.venv`, `__pycache__`, lockfiles, `.git`)
2. Replaces every `PROJECT_NAME_PLACEHOLDER` placeholder in the copied files with your project name
3. Installs backend deps: `uv sync` (in `backend/`)
4. Installs frontend deps: `npm install` (in `frontend/`)
5. Runs `git init` in the new project

## What `create-python-base.sh` does

1. Copies `python-base/` to `<destination-dir>/<new-project-name>`
   (excludes `.venv`, `__pycache__`, lockfile, `.git`)
2. Replaces every `PROJECT_NAME_PLACEHOLDER` placeholder in the copied files with your project name
3. Installs deps: `uv sync` (at project root)
4. Runs `git init` in the new project

## Running the fullstack dev servers

From the project root (the folder containing `backend/` and `frontend/`):

```bash
./start.sh   # opens a tmux session, backend (left pane) + frontend (right pane)
./stop.sh    # kills that session, stops both
```

`start.sh` runs `uv run uvicorn app.main:app --reload` in `backend/`, so `backend/app/main.py` needs a FastAPI instance named `app`. Re-attach anytime with `tmux attach -t <project-name>-dev`.

`python-base` has no server, so there's no `start.sh`/`stop.sh` — run it directly:
```bash
uv run python -m app.main
```

## Requirements

- [`uv`](https://astral.sh/uv) installed and on `$PATH`
- `npm` installed (for `fullstack-py-react`)
- `rsync`
- `tmux` (for `fullstack-py-react`'s `start.sh`/`stop.sh`)

## Adding the placeholder to new scaffold files

Any file that should carry the project's name needs the literal token:

```
PROJECT_NAME_PLACEHOLDER
```

e.g. in `fullstack-py-react/backend/pyproject.toml`:
```toml
name = "PROJECT_NAME_PLACEHOLDER-backend"
```

e.g. in `python-base/pyproject.toml` (single package, no suffix needed):
```toml
name = "PROJECT_NAME_PLACEHOLDER"
```

Note: don't wrap the token in extra underscores (e.g. `__PROJECT_NAME__`) — package name
validators (uv, pip) reject names that start/end with `_`, so the file becomes unparseable.

## Notes

- Both scripts fail if the destination folder already exists — won't overwrite anything.
- `cpp-cmake` is not yet wired up to a create script.