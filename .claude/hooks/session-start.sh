#!/bin/bash
# Hook: runs at session start
# Loads current project status and checks for stale handoff

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
STATUS_FILE="$PROJECT_DIR/CURRENT_STATUS.md"

# --- Auto-pull from Google Drive (if configured) ---
DRIVE_CONFIG="$PROJECT_DIR/.drive.json"
DRIVE_SCRIPT=""

# drive-sync.py runs only from the framework root: the nearest of this repo,
# its parent or grandparent that carries workspace.json, with the script owned
# by this user and writable by nobody else. A project repo's own copy never runs.
trusted_script() {
  [ -f "$1" ] && [ -O "$1" ] && [ -z "$(find "$1" \( -perm -020 -o -perm -002 \) 2>/dev/null)" ]
}

REPO_ROOT="$(cd "$PROJECT_DIR" && git rev-parse --show-toplevel 2>/dev/null)"
for root in "$REPO_ROOT" "$(cd "$PROJECT_DIR/../.." 2>/dev/null && pwd)" "$(cd "$PROJECT_DIR/../../.." 2>/dev/null && pwd)"; do
  if [ -n "$root" ] && [ -f "$root/workspace.json" ] && trusted_script "$root/scripts/drive-sync.py"; then
    DRIVE_SCRIPT="$root/scripts/drive-sync.py"
    break
  fi
done

if [ -f "$DRIVE_CONFIG" ] && [ -n "$DRIVE_SCRIPT" ]; then
  ENABLED=$(cd / && python3 -I -c 'import json, sys; print(json.load(open(sys.argv[1])).get("enabled", False))' "$DRIVE_CONFIG" 2>/dev/null)
  if [ "$ENABLED" = "True" ]; then
    python3 -I "$DRIVE_SCRIPT" pull --project-dir "$PROJECT_DIR" 2>/dev/null || true
  fi
fi
# --- End Drive sync ---

if [ -f "$STATUS_FILE" ]; then
  # Extract "Last updated" date from CURRENT_STATUS.md
  LAST_UPDATED=$(grep -m1 '^\*\*Last updated:\*\*' "$STATUS_FILE" | sed 's/.*\*\*Last updated:\*\* *//')
  TODAY=$(date +%Y-%m-%d)

  echo "=== PROJECT STATUS (from CURRENT_STATUS.md) ==="
  cat "$STATUS_FILE"
  echo "=== END STATUS ==="

  # Warn if last update was before today
  if [ -n "$LAST_UPDATED" ] && [ "$LAST_UPDATED" != "$TODAY" ]; then
    echo ""
    echo "=== STALE HANDOFF WARNING ==="
    echo "CURRENT_STATUS.md was last updated on $LAST_UPDATED (today is $TODAY)."
    echo "The previous session may not have completed handoff."
    echo "Verify the status above is accurate before starting work."
    echo "=== END WARNING ==="
  fi
else
  echo "No CURRENT_STATUS.md found. Run /recap to create one."
fi
