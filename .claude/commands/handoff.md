# Handoff

Generate a handoff summary so the next session or agent can pick up exactly where this one left off.

Run this at the end of a work session or when switching to a different task.

## Steps

### 1. Summarize this session
Review the conversation and list:
- What was the goal of this session
- What was accomplished
- What was NOT completed (and why)
- Any decisions made
- Any issues discovered

### 2. Read current state
Read these files to understand the full picture:
- `CURRENT_STATUS.md`
- Active plan files in `docs/plans/`
- `CLAUDE.md` for workflow IDs

### 3. Write the handoff to CURRENT_STATUS.md

Update CURRENT_STATUS.md with this structure:

```markdown
# Current Status

**Last updated:** <date>
**Last session:** <brief description of what was done>

## Active Work

### <Plan/Task Name>
- **Plan file:** docs/plans/PLAN-xxx.md
- **Phase:** X of Y
- **Progress:** X/Y tasks done
- **Next task:** <task ID and description>
- **Blockers:** <any blockers, or "none">

## Recently Completed
- <what was finished recently>

## Known Issues
- <issues that need attention>

## Quick Start for Next Session
1. Read this file for context
2. Read the active plan file: `docs/plans/PLAN-xxx.md`
3. Start with task <X.Y>: <description>
4. Key workflow IDs: <list relevant ones>

## Session Log
| Date | What was done | Agent |
|------|---------------|-------|
| <date> | <summary> | <agent/session> |
```

### 4. Report the session to the Hub

Write `.handoff.json` in the project root (add it to `.gitignore` if it is
not there: `grep -qx '.handoff.json' .gitignore || echo .handoff.json >> .gitignore`)
with this shape, filled from the summary in step 1:

```json
{
  "event_key": "<fresh uuid, from `uuidgen | tr A-Z a-z`>",
  "project": "<hub_project from CLAUDE.md front matter, else the directory name>",
  "person": "<git config user.email, the part before @>",
  "machine": "<scutil --get ComputerName>",
  "started_at": "<ISO 8601 with offset, when the session began>",
  "ended_at": "<now, ISO 8601 with offset>",
  "branch": "<git branch --show-current, or null>",
  "prs": ["#123"],
  "migration": "<the migration number this session pushed, or null>",
  "shipped": "<what was accomplished, two to four sentences>",
  "left_open": "<what was not completed and why, as prose>",
  "items": [
    { "ref": "<the item's ref from the previous .handoff.json, else a fresh uuid>", "title": "<one open item, one line>", "body": "<the detail>", "kind": "bug|feature|question", "system": "<system key or null>" }
  ]
}
```

One item per thing left open or discovered that somebody should decide on.
Nothing already filed; a decision made in this session is not an item.

`.handoff.json` stays on disk between sessions (it is git-ignored). Read the
previous one before overwriting it: an item still open from that file keeps
its `ref`, so the Hub recognises it and does not file a second draft; only a
new item gets a fresh uuid. The `event_key` is always fresh, one per session.

Then run, from the project root. The loop picks the first path that exists
and runs the script once:

```bash
rc=2
for p in "$(git rev-parse --show-toplevel 2>/dev/null)/../../internal/af-hub/scripts/session/report.mjs" "$HOME/dev/automation-flow/internal/af-hub/scripts/session/report.mjs"; do
  [ -f "$p" ] && { node "$p" .handoff.json; rc=$?; break; }
done
echo "report exit $rc"
```

The last line printed is the script's own exit code. When neither path
exists nothing runs and `rc` stays 2, which reads as not connected.

Exit 0: say "Reported to the Hub" with the ids it printed. Exit 2: say
"Not connected to the Hub on this machine" once and continue. Exit 1: quote
the body it printed in the handoff under Known Issues; a 404 means the
project slug is wrong, a 409 means the key was reused with different content.

### 5. Sync to Google Drive
If `.drive.json` exists in the project root and has `enabled: true`, push docs to Drive:
```bash
python3 <agency-root>/scripts/drive-sync.py push --project-dir .
```
Find the script by walking up from the project directory (same as hooks do).
Report any sync results to the user.

### 6. Confirm
Tell the user what was saved, what the next session should start with, and any warnings or blockers.

## Rules
- CURRENT_STATUS.md should always be readable by a new agent with zero prior context
- Keep it concise — just enough to resume, not a full history
- The "Quick Start" section is the most important part
- Always append to the Session Log, never overwrite it
