---
name: lint
description: Health-check the wiki. Use weekly, or before trusting it for something important.
---

# Lint

Scan the wiki and report. Don't fix without asking first.

- Orphan pages (nothing links to them).
- Broken [[wikilinks]] (point to a page that doesn't exist).
- Stale pages (not updated in 60+ days).
- Missing pages (referenced but never created).
- Contradictions between pages.

Write the report to wiki/_health.md. End with the few things most worth fixing.
