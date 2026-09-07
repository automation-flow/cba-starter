# Sync Drive

Manually sync Google Drive documents for this project.

## Steps

### 1. Check configuration
Check if `.drive.json` exists in the project root.
- If missing, ask the user if they want to initialize Drive sync (run init).
- If present but `enabled: false`, inform the user and offer to help configure it.

### 2. Choose action
Ask the user what they want to do:
- **Pull** — download latest Google Docs as markdown
- **Push** — upload local markdown changes to Google Docs
- **Status** — show sync state for all tracked files
- **Init** — initialize Drive sync for this project

### 3. Find the sync script
Locate `drive-sync.py` by walking up from the project directory:
```bash
AGENCY_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
DRIVE_SCRIPT="$AGENCY_ROOT/scripts/drive-sync.py"
```

### 4. Execute
Run the chosen action:
```bash
python3 "$DRIVE_SCRIPT" <action> --project-dir .
```

### 5. Report results
Show the user what was synced, any conflicts resolved, and current status.

## Rules
- If `.drive.json` is missing, don't error — offer to init
- If dependencies are missing, show the install command
- Always show what changed after pull/push
