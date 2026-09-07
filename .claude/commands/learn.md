# Learn

Capture a learning, pattern, or fix that should be remembered and potentially shared across projects.

## Usage

`/learn [description]`

The description can be a short sentence or Claude can extract the learning from the current session context.

## What to Capture

- **Error patterns**: "When X error happens, the fix is always Y"
- **Project conventions**: "This project uses pattern X for all API routes"
- **Debugging insights**: "When feature X breaks, check Y first"
- **Configuration patterns**: "Service X needs setting Y to work correctly"
- **Performance fixes**: "Using approach X instead of Y improved performance"
- **User corrections**: "The user prefers X over Y for this type of task"

## Steps

### 1. Identify the learning

If the user provided a description, use it. Otherwise, analyze the current session:
- What errors were encountered and how were they fixed?
- What patterns were established?
- What did the user correct or prefer?
- What took multiple attempts to get right?

### 2. Classify the learning

Determine the type:
- `error-fix` — a specific error and its resolution
- `pattern` — a coding or architectural pattern to follow
- `convention` — a project-specific convention or preference
- `debugging` — a debugging technique or diagnostic approach
- `performance` — a performance optimization

And the scope:
- `project` — specific to this project only
- `type` — relevant to all projects of this type (n8n or fullstack)
- `universal` — relevant to all projects

### 3. Save the learning

Create or update the file `docs/learnings/LEARNINGS.md` with:

```markdown
## [Date] — [Short title]

**Type:** [error-fix | pattern | convention | debugging | performance]
**Scope:** [project | type | universal]
**Confidence:** [high | medium] (high = proven fix, medium = seems to work)

### Context
[What situation triggered this learning]

### Learning
[The actual insight — what to do or avoid]

### Example
[Code snippet or specific example if applicable]
```

### 4. Apply immediately

If the learning is about a pattern or convention:
- Check if it should be added to a rule file (e.g., `code-standards.md`)
- If scope is `project`, suggest adding it to the project's `CLAUDE.md`
- If scope is `type` or `universal`, flag it for promotion:

```
This learning has scope "type" — it could benefit all fullstack projects.
To promote it: update the relevant rule in _shared/fullstack/rules/ and run sync-shared.sh
```

### 5. Confirm

Tell the user what was saved and where. If the learning has broader scope, recommend promoting it.

## Rules
- Create `docs/learnings/` directory if it doesn't exist
- Append to LEARNINGS.md, never overwrite (it's a log)
- Be specific — "always check X" is less useful than "when error Y happens in context Z, the fix is X because of W"
- High confidence = you've verified the fix works. Medium = it worked once but needs more validation
- Never save sensitive data (tokens, passwords, personal info) as learnings
