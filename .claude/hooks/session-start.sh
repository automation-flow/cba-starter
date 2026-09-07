#!/bin/bash
# Hook: runs at session start
# Loads current project status and checks for stale handoff

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
STATUS_FILE="$PROJECT_DIR/CURRENT_STATUS.md"

# --- Auto-pull from Google Drive (if configured) ---
DRIVE_CONFIG="$PROJECT_DIR/.drive.json"
DRIVE_SCRIPT=""

for candidate in \
  "$(cd "$PROJECT_DIR" && git rev-parse --show-toplevel 2>/dev/null)/scripts/drive-sync.py" \
  "$(cd "$PROJECT_DIR/../.." 2>/dev/null && pwd)/scripts/drive-sync.py" \
  "$(cd "$PROJECT_DIR/../../.." 2>/dev/null && pwd)/scripts/drive-sync.py"; do
  if [ -f "$candidate" ]; then
    DRIVE_SCRIPT="$candidate"
    break
  fi
done

if [ -f "$DRIVE_CONFIG" ] && [ -n "$DRIVE_SCRIPT" ]; then
  ENABLED=$(python3 -c "import json; print(json.load(open('$DRIVE_CONFIG')).get('enabled', False))" 2>/dev/null)
  if [ "$ENABLED" = "True" ]; then
    python3 "$DRIVE_SCRIPT" pull --project-dir "$PROJECT_DIR" 2>/dev/null || true
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
