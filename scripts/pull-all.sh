#!/bin/bash
# Pull data from all sources into raw/. Each pull-<source>.sh writes into raw/<source>/.
# Add your own pull scripts (copy pull-example.sh) and they get picked up here.
# Missing scripts are skipped, so this works from day one.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Pulling from all sources ==="
echo ""

FAILED=()

run_source() {
    local label="$1"; shift
    local script="$1"; shift
    if [[ ! -x "$script" ]]; then
        echo "--- $label: no pull script yet, skipping ---"
        echo ""
        return
    fi
    echo "--- $label ---"
    if ! "$script" "$@"; then
        echo "$label pull FAILED"
        FAILED+=("$label")
    fi
    echo ""
}

run_source "Google Drive"    "$SCRIPT_DIR/pull-drive.sh" "$@"
run_source "Gmail"           "$SCRIPT_DIR/pull-gmail.sh" "$@"
run_source "GitHub"          "$SCRIPT_DIR/pull-github.sh" "$@"
run_source "Google Calendar" "$SCRIPT_DIR/pull-calendar.sh" "$@"

if [[ ${#FAILED[@]} -eq 0 ]]; then
    echo "=== All pulls complete ==="
    exit 0
fi

echo "=== Pulls complete WITH FAILURES (${#FAILED[@]}): ${FAILED[*]} ==="
exit 1
