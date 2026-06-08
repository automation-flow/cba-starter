---
name: ingest
description: Brain step. Turn raw source files into linked wiki pages. Use after pulling, or on a specific file.
---

# Ingest

The Brain step. Process raw file(s) into the wiki, following the schema in CLAUDE.md.

1. Read the raw source.
2. Pull out the facts that matter. Interpret, don't dump.
3. Create or update the right pages (client, meeting, person, project, ...).
4. Cross-link every name as a [[wikilink]].
5. Set frontmatter, and list the raw files under `sources`.
6. Update wiki/index.md and append a line to wiki/log.md.

One source can touch many pages. Prefer updating a page over creating a duplicate.
If new info contradicts a page, flag it and update to the latest.
