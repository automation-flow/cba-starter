---
name: pull
description: Capture step. Fetch new data from a source into raw/. Use before ingesting, or to refresh a source.
---

# Pull

The Capture step. Bring new or changed data from one source into raw/<source>/.
Sources are listed in sources.md (drive, gmail, github, calendar, web).

- Ask which source if I didn't say, or pull "all".
- Use the right tool: a pull script, an MCP, or the gh CLI for code.
- Write only into raw/<source>/. Never touch wiki/ here.
- Track a timestamp so re-runs fetch only what's new.
- Update the "last pulled" cell in sources.md.

Report what landed: how many files, which source, the date range.
