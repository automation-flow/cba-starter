#!/bin/bash
# Hook: runs before context compaction
# Reminds Claude to save work before context is lost

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
STATUS_FILE="$PROJECT_DIR/CURRENT_STATUS.md"

# --- Auto-push to Google Drive (if configured) ---
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
    python3 "$DRIVE_SCRIPT" push --project-dir "$PROJECT_DIR" 2>/dev/null || true
  fi
fi
# --- End Drive sync ---

TODAY=$(date +%Y-%m-%d)
URGENT="false"

if [ -f "$STATUS_FILE" ]; then
  FILE_DATE=$(stat -f "%Sm" -t "%Y-%m-%d" "$STATUS_FILE" 2>/dev/null || stat -c "%y" "$STATUS_FILE" 2>/dev/null | cut -d' ' -f1)
  if [ "$FILE_DATE" != "$TODAY" ]; then
    URGENT="true"
  fi
else
  URGENT="true"
fi

if [ "$URGENT" = "true" ]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "URGENT: CONTEXT COMPACTION IMMINENT. CURRENT_STATUS.md has NOT been updated this session. You MUST run /handoff NOW to save all work before context is lost. After handoff, tell the user: 'Context is full. Start a new session for best results.'"
  }
}
EOF
else
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "CONTEXT COMPACTION IMMINENT. CURRENT_STATUS.md was updated today but may not reflect latest work. If you made changes since last handoff, run /handoff NOW. After compaction, suggest the user start a new session."
  }
}
EOF
fi
