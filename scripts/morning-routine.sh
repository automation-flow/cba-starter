#!/bin/bash
# Morning routine: pull latest from git, then refresh all raw data.
# Schedule: Sun-Thu 8am via ~/Library/LaunchAgents/com.businessbrain.kb-morning.plist
#
# Note: stdout/stderr are captured by launchd to /tmp/kb-morning-routine.log.
# When run manually, output goes to your terminal, use shell redirection to log:
#   ./scripts/morning-routine.sh 2>&1 | tee -a /tmp/kb-morning-routine.log
set -uo pipefail  # No -e so partial failures don't kill the whole routine

KB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KB_ROOT"

echo "===== Morning Routine: $(date) ====="

echo ""
echo "[1/2] git pull..."
git pull --rebase --autostash 2>&1 || echo "  (git pull failed, continuing)"

echo ""
echo "[2/2] Refreshing raw data from all sources..."
"$KB_ROOT/scripts/pull-all.sh"

echo ""
echo "===== Morning routine complete: $(date) ====="
echo ""
