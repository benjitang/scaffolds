# scaffolds
Quick-start templates for new projects. Currently supports: `fullstack-py-react`, `python-base`, `cpp-base`.

## Usage
```bash
./create-fullstack.sh <new-project-name> [destination-dir]
./create-python-base.sh <new-project-name> [destination-dir]
./create-cpp-base.sh <new-project-name> [destination-dir]
```

**Examples:**
```bash
./create-fullstack.sh my-cool-app ~/Code/projects
./create-python-base.sh my-tool ~/Code/projects
./create-cpp-base.sh my-cpp-tool ~/Code/projects
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

## What `create-cpp-base.sh` does
1. Copies `cpp-base/` to `<destination-dir>/<new-project-name>`
   (excludes `build`, `bin`, `.git`)
2. Replaces every `PROJECT_NAME_PLACEHOLDER` placeholder in the copied files with your project name
3. Makes `scripts/*.sh` executable
4. Configures the project: `cmake -S . -B build`
5. Runs `git init` in the new project

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

## Running the cpp-base project
From the project root:
```bash
./scripts/run.sh          # quiet incremental build + run
./scripts/run.sh --clean  # wipes build/, full reconfigure + build, then run
```
Or set up the `cpprun` alias in your shell config to run it from anywhere inside the project:
```bash
alias cpprun='./scripts/run.sh'
```

## Requirements
- [`uv`](https://astral.sh/uv) installed and on `$PATH`
- `npm` installed (for `fullstack-py-react`)
- `rsync`
- `tmux` (for `fullstack-py-react`'s `start.sh`/`stop.sh`)
- `cmake` and a C++ compiler supporting C++23 (for `cpp-base`)

## Adding the placeholder to new scaffold files
Any file that should carry the project's name needs the literal token: