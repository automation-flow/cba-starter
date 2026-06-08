# Sources (the Capture layer)

Where this brain pulls from, and how fresh each one is. This is Capture: what
isn't recorded doesn't exist. One row per source. Update "last pulled" when you
wire or refresh one.

| Source | Tool | How it lands in raw/ | Auth | Last pulled |
|--------|------|----------------------|------|-------------|
| Meetings | Spinach / Otter | transcripts into raw/meetings | account | not yet |
| Email | Gmail | pull script or MCP into raw/gmail | OAuth | not yet |
| Docs | Google Drive | pull script into raw/drive | OAuth | not yet |
| Calendar | Google Calendar | pull script or MCP into raw/calendar | OAuth | not yet |
| Code | GitHub | gh CLI into raw/github | gh auth | not yet |
| Web pages | Web Clipper / Firecrawl | clip to vault, or scrape | account or key | not yet |
| (your CRM / tasks) | ... | ... | ... | not yet |

## Two ways in
- **script**: a small puller that writes into raw/. You own a local copy.
- **mcp**: a live connection an agent queries while it works.

Start with one. Prove it works. Add the next. Don't wire everything on day one.

## Researched once, saved forever
The first time you wire a source, have Claude write a short note at
`references/<tool>.md`: the endpoints, the auth steps, the gotchas. Next time it
reads the note instead of figuring it all out again.
