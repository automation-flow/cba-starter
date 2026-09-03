# Promote

Promote a learning, pattern, or rule from the current project to the framework level so it applies to all projects of the relevant type.

## Usage

`/promote [description]`

No technical knowledge needed — Claude handles everything (finding the framework, writing the rule, syncing).

## Steps

### 1. Find the framework root

Look for the framework root directory by searching upward from the current project for a directory containing `workspace.json` and `_shared/`. This is the agency framework root.

If the framework root is not found (e.g., the project is standalone), tell the user:
```
I can't find the framework root (workspace.json + _shared/).
This project may not be inside the automation-flow workspace.
Save the learning with /learn instead, and ask the admin to promote it manually.
```

### 2. Determine what to promote

Ask the user (if not provided in the command):

**"What do you want to promote?"**

Options:
1. **A learning from this session** — something discovered during current work
2. **An existing learning** — from `docs/learnings/LEARNINGS.md`
3. **A new rule** — a standard that should apply everywhere

If option 2, read `docs/learnings/LEARNINGS.md` and show the learnings that have scope `type` or `universal`. Let the user pick which one(s) to promote.

### 3. Determine the target

Based on the learning's scope:

| Scope | Target | Effect |
|-------|--------|--------|
| `type` | `_shared/{project-type}/rules/` | Applies to all projects of this type |
| `universal` | `_shared/common/rules/` | Applies to ALL projects |

To determine the project type, read `workspace.json` at the framework root and find the current project's type.

**Ask the user:**
- "Should this apply to all **{type}** projects, or to **all** projects?" (if not obvious from context)
- "Which rule file should this go into?" — suggest the most relevant existing rule file, or offer to create a new one

### 4. Write the rule

Navigate to the framework root and update the target rule file in `_shared/`:

- If updating an existing rule: read the file, find the right section, add the new content
- If creating a new rule: create a file following the pattern of existing rules (heading, clear bullet points, examples)

**Important:** Write clear, actionable rules. Not vague guidance. Compare:
- Bad: "Handle errors properly"
- Good: "All API route handlers must wrap the body in try/catch. Return `{ error: message }` with appropriate HTTP status codes. Log the full error server-side, return a safe message to the client."

### 5. Commit in the framework repo

Run these commands from the framework root:

```bash
cd <framework-root>
git add _shared/
git commit -m "Promote learning: <short description>"
```

### 6. Sync to all projects

```bash
./scripts/sync-shared.sh
```

This copies the updated rules to every project of the matching type.

### 7. Mark the learning as promoted

If the promotion came from `docs/learnings/LEARNINGS.md`, update the original entry:

```markdown
**Status:** Promoted to `_shared/{target}/rules/{file}.md` on {date}
```

### 8. Confirm

Tell the user exactly what happened:

```
Done! Here's what I did:

1. Added rule to: _shared/fullstack/rules/code-standards.md
2. Committed in the framework repo
3. Synced to all fullstack projects (sunny, website)

The rule is now active everywhere. Next time anyone runs `claude` in a fullstack project, they'll get this rule automatically.
```

## Rules

- **Never promote sensitive data** (tokens, passwords, project-specific secrets)
- **Never overwrite existing rules** — always append or merge
- **Always show the user what will be written** before committing
- **If unsure about scope**, default to `type` (narrower is safer, can always widen later)
- **Keep rules specific and actionable** — vague rules create confusion, specific rules create consistency
- The framework repo commit does NOT get pushed automatically — the admin decides when to push
