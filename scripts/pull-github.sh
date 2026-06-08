#!/bin/bash
# Capture step: pull recent GitHub activity (commits, issues) into raw/github/.
# Uses the public `gh` CLI, so it works for anyone. Run `gh auth login` once first.
#
# Which repos? Set GITHUB_REPOS to a space-separated list of owner/repo, e.g.
#   GITHUB_REPOS="acme/site acme/api" ./scripts/pull-github.sh
# With nothing set, it falls back to your 20 most-recently-updated repos.
#
# Tracks a timestamp so re-runs only fetch what's new. This is the one working
# pull script the starter ships. For Drive, Gmail and Calendar, connect an MCP
# server instead (run /connect, or see SETUP.md) — those live behind your own
# Google login, not a script.
set -euo pipefail

KB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RAW_DIR="$KB_ROOT/raw/github"
STATE_FILE="$KB_ROOT/scripts/.last-pull-github"
mkdir -p "$RAW_DIR"

if ! command -v gh >/dev/null 2>&1; then
    echo "gh CLI not found. Install it (https://cli.github.com), then run 'gh auth login'." >&2
    exit 1
fi

# Cutoff date: --since flag, else last run, else a clean start.
if [[ "${1:-}" == "--since" && -n "${2:-}" ]]; then
    SINCE="$2"
elif [[ -f "$STATE_FILE" ]]; then
    SINCE="$(cat "$STATE_FILE")"
else
    SINCE="2024-01-01"
fi
echo "Pulling GitHub activity since $SINCE..."

# Repo list: your env override, else your most-recently-updated repos.
if [[ -n "${GITHUB_REPOS:-}" ]]; then
    REPOS="$GITHUB_REPOS"
else
    REPOS="$(gh repo list --limit 20 --json nameWithOwner --jq '.[].nameWithOwner' 2>/dev/null || true)"
fi

if [[ -z "${REPOS// /}" ]]; then
    echo "No repos found. Set GITHUB_REPOS=\"owner/repo ...\" and re-run." >&2
    exit 0
fi

for REPO in $REPOS; do
    echo "Processing $REPO..."
    REPO_DIR="$RAW_DIR/${REPO//\//_}"
    mkdir -p "$REPO_DIR"

    # Recent commits
    gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z&per_page=50" \
        --jq '.[] | "- [\(.sha[:7])] \(.commit.message | split("\n")[0]) (\(.commit.author.date[:10]))"' \
        2>/dev/null > "$REPO_DIR/commits.md" || true
    if [[ -s "$REPO_DIR/commits.md" ]]; then
        TEMP="$(mktemp)"
        printf -- '---\nsource: github\nrepo: %s\ntype: commits\npulled: %s\n---\n\n# Recent commits: %s\n\n' \
            "$REPO" "$(date -u +%Y-%m-%d)" "$REPO" > "$TEMP"
        cat "$REPO_DIR/commits.md" >> "$TEMP"
        mv "$TEMP" "$REPO_DIR/commits.md"
        echo "  saved commits"
    else
        rm -f "$REPO_DIR/commits.md"
    fi

    # Open issues (skip pull requests)
    gh api "repos/$REPO/issues?state=open&per_page=50" \
        --jq '.[] | select(.pull_request == null) | "## #\(.number): \(.title)\n\(.body // "No description")\n"' \
        2>/dev/null > "$REPO_DIR/issues.md" || true
    if [[ -s "$REPO_DIR/issues.md" ]]; then
        TEMP="$(mktemp)"
        printf -- '---\nsource: github\nrepo: %s\ntype: issues\npulled: %s\n---\n\n# Open issues: %s\n\n' \
            "$REPO" "$(date -u +%Y-%m-%d)" "$REPO" > "$TEMP"
        cat "$REPO_DIR/issues.md" >> "$TEMP"
        mv "$TEMP" "$REPO_DIR/issues.md"
        echo "  saved issues"
    else
        rm -f "$REPO_DIR/issues.md"
    fi

    # Drop the repo dir if nothing landed
    rmdir "$REPO_DIR" 2>/dev/null || true
done

date -u +%Y-%m-%d > "$STATE_FILE"
echo "Done. Files are in $RAW_DIR"
