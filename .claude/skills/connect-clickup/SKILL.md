---
name: connect-clickup
description: Connect ClickUp tasks to the brain with a personal API token and a pull script, so open work lands in raw/. Use when the user manages tasks or projects in ClickUp.
---

# Connect: ClickUp

You're connecting the user's ClickUp so their tasks land in the brain. The user
is not technical — do the typing, and **never** let them paste the token into the
chat. It goes in a git-ignored file you reference, nothing more.

First, check the connector directory (https://claude.ai/directory) for a
**ClickUp** connector. If one exists, prefer it: add it, sign in, confirm with
`/mcp`, done — skip the rest. If there's no connector, use the token + pull-script
path below.

## 1. Get a personal API token
Walk them through it in ClickUp (they click, you don't):
1. In ClickUp, click their avatar (bottom-left) → **Settings**.
2. In the sidebar, open **Apps**.
3. Under **API Token**, click **Generate** (or **Regenerate**) and **Copy**.
   The token starts with `pk_`.

## 2. Store it safely (never in chat)
Tell them **not** to paste the token into the chat. Create the git-ignored file
for them to fill themselves (or have them paste it into their password manager and
tell you the file path):
```bash
cat > scripts/clickup-token.env <<'EOF'
CLICKUP_TOKEN=pk_paste_yours_here
EOF
chmod 600 scripts/clickup-token.env
```
Confirm `scripts/clickup-token.env` is in `.gitignore` before anything commits.
The token never gets committed or printed back.

## 3. Find their workspace (so they don't hunt for IDs)
With the token set, the ClickUp API tells you the rest:
```bash
source scripts/clickup-token.env
curl -s -H "Authorization: $CLICKUP_TOKEN" https://api.clickup.com/api/v2/team
```
Pick the team they want and note its `id`. Spaces → folders → lists drill down
the same way (`/team/<id>/space`, `/space/<id>/folder`, …).

## 4. Pull tasks into raw/
Copy `scripts/pull-example.sh` to `scripts/pull-clickup.sh` (or ask Claude to
write it): read the token from the env file, call the ClickUp API for their open
tasks, and write the JSON/markdown under `raw/clickup`. Run it once and confirm
files appear.

## 5. Close
Mark the Tasks row in `sources.md` with today's date. Remind them they can re-run
`/connect` any time to add the next source.
