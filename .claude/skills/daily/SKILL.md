---
name: daily
description: The full daily cycle: pull everything, ingest what's new, summarize. Use once a day.
---

# Daily

The whole Capture, Brain, Act loop, once a day.

1. Pull all: fetch new data from every source in sources.md into raw/.
2. Ingest the new raw files into the wiki, linked.
3. Update wiki/overview.md and wiki/hot.md if the picture changed.
4. Summarize what changed today in a few lines, and append it to wiki/log.md.

This is what a scheduled job (cron or launchd) can run on its own, so the Brain
stays current while your laptop is closed.
