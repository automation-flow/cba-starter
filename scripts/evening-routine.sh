#!/bin/bash
# Evening routine: pull latest from git, refresh raw data, ingest it into the wiki,
# run lint, push any changes. This is the full Capture -> Brain -> Act loop, nightly.
# Schedule: Sun-Thu 9pm via ~/Library/LaunchAgents/com.businessbrain.kb-evening.plist
#
# Note: stdout/stderr are captured by launchd to /tmp/kb-evening-routine.log.
# When run manually, output goes to your terminal, use shell redirection to log:
#   ./scripts/evening-routine.sh 2>&1 | tee -a /tmp/kb-evening-routine.log
set -uo pipefail

KB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KB_ROOT"

echo "===== Evening Routine: $(date) ====="

echo ""
echo "[1/5] git pull..."
git pull --rebase --autostash 2>&1 || echo "  (git pull failed, continuing)"

echo ""
echo "[2/5] Refreshing raw data from all sources..."
"$KB_ROOT/scripts/pull-all.sh"

echo ""
echo "[3/5] Ingesting new data into the wiki (headless Claude/Codex)..."
"$KB_ROOT/scripts/auto-ingest.sh" || echo "  (auto-ingest skipped/failed, see message above)"

echo ""
echo "[4/5] Running wiki lint (cleanup)..."
"$KB_ROOT/scripts/lint-wiki.sh" || echo "  (lint reported broken links, see wiki/_health.md)"

echo ""
echo "[5/5] Committing and pushing wiki changes..."
if [[ -n "$(git status --porcelain wiki/)" ]]; then
    git add wiki/ 2>&1 || true

    # Block the push if the staged wiki changes look like they contain a secret.
    # Prefer gitleaks if installed; otherwise a high-signal prefix scan. This is a
    # backstop — the real protections are a PRIVATE repo and a gitignored raw/.
    # We never echo the matched text, so the secret isn't copied into the log.
    secret_found=""
    if command -v gitleaks >/dev/null 2>&1; then
        gitleaks protect --staged --no-banner >/dev/null 2>&1 || secret_found="gitleaks flagged staged changes"
    else
        SECRET_COUNT="$(git diff --cached -- wiki/ | grep -cE 'BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9A-Za-z-]{10,}|gh[opsur]_[0-9A-Za-z]{20,}|sk-ant-[0-9A-Za-z_-]{20,}|sk-[A-Za-z0-9]{32,}|(sk|rk)_live_[0-9A-Za-z]{16,}|AIza[0-9A-Za-z_-]{35}|eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]+' || true)"
        [[ "${SECRET_COUNT:-0}" -gt 0 ]] && secret_found="$SECRET_COUNT suspicious line(s)"
    fi

    if [[ -n "$secret_found" ]]; then
        echo "  SECURITY: staged wiki changes look like they hold a secret ($secret_found) — NOT committing/pushing."
        echo "  Inspect with: git diff --cached -- wiki/   then clean it and re-run."
        git reset -- wiki/ >/dev/null 2>&1 || true
    else
        # Commit with an explicit wiki/ pathspec so a bare 'git commit' can't sweep
        # in any unrelated content that happened to be staged elsewhere.
        git commit -m "chore: evening routine, health report $(date +%Y-%m-%d)" -- wiki/ 2>&1 || true
        git push 2>&1 || echo "  (git push failed)"
    fi
else
    echo "  No wiki changes to commit."
fi

echo ""
echo "===== Evening routine complete: $(date) ====="
echo ""
