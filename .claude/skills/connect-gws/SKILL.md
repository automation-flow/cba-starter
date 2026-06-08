---
name: connect-gws
description: Install the Google Workspace CLI (gws) and sign the user in, so the brain can pull Google Drive, Gmail, and Calendar into raw/ as local copies. Use when connecting any Google source as a saved local copy rather than a live connector.
---

# Connect: Google Workspace (the gws CLI)

You're wiring the user's Google Drive, Gmail, and Calendar so the brain keeps a
local copy in `raw/`. The user is not technical. Do the typing yourself, explain
each step in one line, and stop if something fails instead of pushing on.

This is the **local-copy** path (data saved to disk, the way our own brain pulls
Google). If they only want an agent to read Gmail or Calendar *live* and never
need a saved copy, a connector is simpler — see `/connect-gmail`. Use gws when
they want the data sitting in `raw/`, searchable and ingestible offline.

## 1. Install gws
Offer to run the one that fits their machine, then confirm with `gws --version`:
- macOS / Linux: `brew install googleworkspace-cli`
- Any OS with Node 18+: `npm install -g @googleworkspace/cli`
- No package manager: download a binary from
  https://github.com/googleworkspace/cli/releases and put `gws` on their PATH.

## 2. Sign in — their own Google account, no shared key
- `gws auth setup` — one-time. It walks them through creating their **own**
  Google Cloud project and logs them in. It uses the `gcloud` CLI under the hood.
- If they don't have `gcloud`, do the manual setup instead: Google Cloud Console
  → OAuth consent screen → **add themselves as a Test user** → create a **Desktop
  app** OAuth client → download the JSON → save it to
  `~/.config/gws/client_secret.json`. (Full steps:
  https://github.com/googleworkspace/cli#authentication)
- `gws auth login -s drive,gmail,calendar` — sign in and scope it to what they
  need. Scope to **services**, not the big "recommended" preset: an unverified
  app is capped at ~25 scopes and the preset will fail.
- If the browser warns "Google hasn't verified this app", that's expected for
  their own testing-mode app — have them click **Continue**.

Credentials are encrypted at rest in the OS keyring. **Never** have them paste a
key or token into the chat.

> If the Google Cloud / `gcloud` setup gets hairy and they really just want their
> email or calendar *readable* (not saved to disk), stop here and use the
> connector instead — `/connect-gmail`, a browser sign-in with no project to
> create. Only push through the gws setup when they genuinely need a local copy
> in `raw/`.

## 3. Confirm it works
`gws drive files list --params '{"pageSize": 5}'` should print a few file names.
For Gmail or Calendar, run `gws gmail --help` / `gws calendar --help` to see the
exact resource, or `gws schema drive.files.list` to introspect any method.

## 4. Turn it into a puller (so it refreshes on its own)
Copy `scripts/pull-example.sh` to `scripts/pull-drive.sh` (or ask Claude to write
it): have it call `gws` and write under `raw/drive`. Same shape for `pull-gmail.sh`
and `pull-calendar.sh`. Run each once and confirm files land in `raw/`. Once they
exist, the morning/evening routines pick them up automatically.

## 5. Close
Mark the Drive / Email / Calendar rows in `sources.md` with today's date. Tell
them in two lines what's live and what's next. They can re-run `/connect` any time.
