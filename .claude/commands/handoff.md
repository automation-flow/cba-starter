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

### 4. Sync to Google Drive
If `.drive.json` exists in the project root and has `enabled: true`, push docs to Drive:
```bash
python3 <agency-root>/scripts/drive-sync.py push --project-dir .
```
Find the script by walking up from the project directory (same as hooks do).
Report any sync results to the user.

### 5. Confirm
Tell the user what was saved, what the next session should start with, and any warnings or blockers.

## Rules
- CURRENT_STATUS.md should always be readable by a new agent with zero prior context
- Keep it concise — just enough to resume, not a full history
- The "Quick Start" section is the most important part
- Always append to the Session Log, never overwrite it
