#!/bin/bash
# Auto-commit + push any working-tree changes to keep the vault synced.
# Schedule: every 5 min via ~/Library/LaunchAgents/com.businessbrain.kb-autocommit.plist
# Pairs with the Obsidian git plugin (which fires only while Obsidian is open).
#
# Logs to /tmp/kb-autocommit.log (rotated by macOS).
set -uo pipefail

KB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KB_ROOT"

ts() { date "+%Y-%m-%d %H:%M:%S"; }

# Skip if nothing to do (cheap fast-path)
if [[ -z "$(git status --porcelain)" ]]; then
    exit 0
fi

echo "[$(ts)] changes detected, syncing..."

# Pull latest first to minimise rebase pain
git pull --rebase --autostash 2>&1 || {
    echo "[$(ts)] pull failed, leaving working tree alone"
    exit 1
}

# Re-check after pull/autostash; nothing left to commit means pull resolved it
if [[ -z "$(git status --porcelain)" ]]; then
    echo "[$(ts)] working tree clean after pull"
    exit 0
fi

# Stage everything trackable (.gitignore protects raw/, secrets, etc.)
git add . 2>&1 || true

# If staging produced no diff (e.g. only ignored files moved), bail
if git diff --cached --quiet; then
    echo "[$(ts)] nothing staged, done"
    exit 0
fi

HOSTNAME_SHORT="$(hostname -s)"
git commit -m "vault sync: $(date '+%Y-%m-%d %H:%M') ${HOSTNAME_SHORT}" 2>&1 || {
    echo "[$(ts)] commit failed"
    exit 1
}

git push 2>&1 || {
    echo "[$(ts)] push failed, commit kept locally, will retry next interval"
    exit 1
}

echo "[$(ts)] committed + pushed"
