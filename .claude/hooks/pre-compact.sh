#!/bin/bash
# Hook: runs before context compaction
# Reminds Claude to save work before context is lost

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
STATUS_FILE="$PROJECT_DIR/CURRENT_STATUS.md"

# --- Auto-push to Google Drive (if configured) ---
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
    python3 -I "$DRIVE_SCRIPT" push --project-dir "$PROJECT_DIR" 2>/dev/null || true
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
