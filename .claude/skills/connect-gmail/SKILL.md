---
name: connect-gmail
description: Connect Gmail to the brain — the easy connector way (browser sign-in, no key) or as a saved local copy via the gws CLI. Use when the user wants their email readable by the brain.
---

# Connect: Gmail

You're connecting the user's email. There are two ways. The user is not
technical, so **start with the connector** — it's a browser sign-in, no keys, and
an agent can read Gmail live. Use the gws path only if they want a permanent
local copy in `raw/`. Never have them paste a password or token into the chat.

## Option A — Connector (easiest, recommended)
A live connection: Claude reads Gmail when it works; nothing is saved to disk.
1. Have them open the Anthropic connector directory:
   https://claude.ai/directory (or https://claude.ai/customize/connectors).
2. Find **Gmail**, add it, and sign in with their Google account in the browser.
3. If they're logged into Claude Code with the **same** Claude account, it shows
   up automatically. Confirm inside Claude Code with `/mcp` — Gmail should be
   listed.

Terminal alternative: `claude mcp add --transport http <name> <url>`, then `/mcp`
to finish the sign-in. Claude registers itself, so there's no OAuth app to create.

## Option B — Local copy in raw/ (via gws)
Use this when they want emails saved to disk — to ingest in bulk, search offline,
or keep history. This is the Google Workspace CLI path: run `/connect-gws`, which
installs `gws`, signs in (`gws auth login -s gmail`), and writes into `raw/gmail`.

## Which to pick
- "I just want my agent to see my email" → **Option A**.
- "I want my email in the brain, saved and ingested" → **Option B**.
Either is fine, and they can add the other later.

## Close
Mark the Email row in `sources.md` with today's date and whether it's connector
or local-copy. Then ask if they want the next source or to stop here.
