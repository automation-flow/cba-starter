# Checkpoint

Create or verify named snapshots before and after risky changes. Works across all project types.

## Usage

- `/checkpoint create <name>` — save current state with a name
- `/checkpoint verify <name>` — compare current state against a saved checkpoint
- `/checkpoint list` — show all checkpoints

## Steps

### create

1. **Generate checkpoint file** at `docs/checkpoints/CHECKPOINT-<name>.md`:

```markdown
# Checkpoint: <name>

**Created:** <date and time>
**Created by:** <session context>

## Git State
- Branch: <current branch>
- Last commit: <hash> <message>
- Uncommitted changes: <yes/no — list files if yes>

## Project State
- Active work from CURRENT_STATUS.md: <summary>

## n8n State (n8n projects only)
- Workflows checked: <list workflow IDs and names>
- Active/inactive status of each
- Recent execution status (last 3 per workflow: success/error)

## Fullstack State (fullstack projects only)
- Build status: <pass/fail>
- TypeScript status: <pass/fail>

## Notes
<any user-provided context about why this checkpoint was created>
```

2. **Create a git tag** (if inside a git repo):
```bash
git tag checkpoint/<name>
```

3. Confirm to the user what was saved.

### verify

1. Read the checkpoint file `docs/checkpoints/CHECKPOINT-<name>.md`
2. Compare current state against each section:
   - Git: any new commits since checkpoint? Uncommitted changes?
   - n8n: workflow status changes? New errors?
   - Fullstack: build still passing?
3. Present a diff summary:
   - What changed since the checkpoint
   - Whether changes look intentional
   - Any regressions (new errors, broken builds)

### list

1. List all files in `docs/checkpoints/`
2. Show name, date, and git tag status for each

## Rules
- Always create the `docs/checkpoints/` directory if it doesn't exist
- Checkpoint names should be short and descriptive (e.g., `before-migration`, `pre-refactor`, `stable-v2`)
- For n8n projects, only check workflows listed in `CLAUDE.md` — don't scan for unknown workflows
- For fullstack projects, run `npx tsc --noEmit` and `npm run build` to capture build state
- Never delete checkpoints automatically — the user decides when to clean up
