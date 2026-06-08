#!/bin/bash
# Template for a pull script. Copy it to pull-<source>.sh and fill in the TODO.
# A pull script fetches NEW data from one source and writes it into raw/<source>/.
# It tracks a timestamp so re-runs only fetch what changed (incremental).
set -euo pipefail

KB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="example"                          # name your source: drive, gmail, github...
RAW_DIR="$KB_ROOT/raw/$SOURCE"
STATE_FILE="$KB_ROOT/scripts/.last-pull-$SOURCE"
mkdir -p "$RAW_DIR"

# Resume from the last run, or from a clean start
if [[ -f "$STATE_FILE" ]]; then
    SINCE="$(cat "$STATE_FILE")"
else
    SINCE="2020-01-01"
fi
echo "Pulling $SOURCE since $SINCE..."

# TODO: fetch from your tool and write markdown files into $RAW_DIR.
# Use whatever you have: an official CLI, an API, or the gh CLI for GitHub.
# Keep secrets OUT of this file. Read tokens from a git-ignored .env or a
# password manager (the 1Password CLI works well). Never hardcode a key.
#
# Example shape:
#   my-tool export --since "$SINCE" --out "$RAW_DIR"

# Record this run so next time is incremental
date +%Y-%m-%d > "$STATE_FILE"
echo "Done. Files are in $RAW_DIR"
