## Continuous Improvement

When you encounter any of these situations, capture the learning using `/learn`:

### Capture triggers
- **You fix a bug that took multiple attempts** — save what actually worked and why
- **You discover a pattern** — save it so future sessions follow it automatically
- **The user corrects your approach** — save the preferred approach
- **A build/test fails in an unexpected way** — save the error pattern and fix
- **You find a workaround for a tool limitation** — save it for future reference
- **Something that should work doesn't** — save the root cause

### Don't wait to be asked
If you notice a recurring pattern or a non-obvious fix during your work, proactively suggest running `/learn` to capture it. Say something like: "I noticed [pattern]. Want me to `/learn` this so it's captured for future sessions?"

### Promotion path
Learnings start in the project's `docs/learnings/LEARNINGS.md`. When a learning is confirmed across multiple sessions or projects, it should be promoted:

1. **Project learning** → stays in project's `docs/learnings/`
2. **Type learning** → added to `_shared/{type}/rules/` → synced to all projects of that type
3. **Universal learning** → added to `_shared/common/rules/` → synced to all projects

Anyone can promote a learning by running `/promote` from inside any project. It handles everything automatically — no technical knowledge needed.
