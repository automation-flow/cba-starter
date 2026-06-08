---
name: connect
description: Turn on backup and wire the brain to the user's tools, with them, one at a time. Run after /onboard, or any time to add a source. Sync first, then sources, then an optional schedule.
---

# Connect

You set up the user's connections WITH them, one at a time. Never wire everything
at once. Ask before each step, do it, test it, then move to the next. The user is
not a developer. Explain in plain words and keep them in the driver's seat. They
can stop after any step, this is resumable.

## The golden rule on secrets

You almost never need an API key now. Most tools connect as a remote connector
with a browser sign-in (OAuth), and Claude Code registers itself automatically.
So: never ask the user to paste a key or token into the chat. If a tool genuinely
has no connector and needs a key, it goes in a git-ignored `.env` or their
password manager, and you reference it. The raw value never gets stored in chat
or committed. Keep `raw/` git-ignored and the GitHub repo private.

## Order, do not skip ahead

### 1. Backup and team sync (git + the Obsidian Git plugin)

This is the part everyone needs: the vault backs up to GitHub on its own, and a
partner gets your edits automatically. Do this first.

- Make sure backup points at THEIR OWN private repo, not this starter. Run
  `git remote -v`. If `origin` is empty, OR it still points at the starter
  (`github.com/automation-flow/cba-starter` — they can't push there), they need
  their own repo before backup can work at all:
  - Easiest: have them open the starter on GitHub and click **Use this template
    → Create a new repository**, set it **Private**, and create it. Then point
    their local copy at it: `git remote set-url origin <their-new-repo-url>`
    (or `git remote add origin <url>` if there was no remote).
  - Do the first push for them: `git push -u origin main`. If it's **denied**,
    the remote is still wrong — fix it before moving on.
  Backup is only really on once `git push` succeeds. Do NOT enable auto-commit or
  the schedule (step 3) until it does, or it will fail silently every few minutes.
- First, have them turn on community plugins: a fresh vault opens in Restricted
  Mode, so Settings > Community plugins > "Turn on community plugins" (or choose
  "Trust" if Obsidian prompts on open). Without this, Browse is greyed out and
  they'll get stuck. Don't skip this step.
- Then have them install the Obsidian Git plugin (by Vinzent03): Settings >
  Community Plugins > Browse > search "Git" > Install > Enable.
- The settings ship in `.obsidian/plugins/obsidian-git/data.json` already (commit
  and push every 5 min, pull every 10, merge). Tell them to reload Obsidian
  (Cmd+P > "Reload app without saving") to pick them up.
- Confirm it works: have them make a tiny edit and watch the status bar in
  Obsidian's bottom-right commit, then push.

### 2. Sources, one at a time (connectors, no keys)

First, open `sources.md` and read the source table. That table is the checklist:
every row still marked "not yet" is a source they haven't connected. Show them
where they stand before you start, in plain words, e.g. "You've got 6 sources and
0 are live yet: Meetings, Email, Docs, Calendar, Code, Web pages. Let's do them
one at a time." This running count is what stops them connecting one thing and
drifting off without knowing what's left.

Ask which source matters most right now. Do that ONE. Get it working before you
mention the next.

For the common sources there's a step-by-step playbook, each written for a
non-technical user — follow it with them instead of improvising:
- `/connect-gmail` — email, the easy connector way or a local copy.
- `/connect-github` — repo activity via the `gh` CLI.
- `/connect-clickup` — tasks via a personal API token.
- `/connect-gws` — Drive, Gmail, Calendar as local copies via the Google
  Workspace CLI.
- `/connect-schedule` — once a source is wired, run the scripts on a schedule so
  the brain refreshes itself (step 3 below).
For anything else, use the general path below.

The easy, modern path is a remote connector with a browser login. Two ways:

- **Clicks (best for non-technical users):** have them open the Anthropic
  connector directory at https://claude.ai/directory (or
  https://claude.ai/customize/connectors), add the connector (Google Drive,
  Gmail, Google Calendar, Notion, Slack, and more), and sign in. If they're
  logged into Claude Code with the same Claude account, the connector shows up
  automatically. Confirm with `/mcp`.
- **Terminal:** `claude mcp add --transport http <name> <url>`, then run `/mcp`
  and finish the sign-in in the browser. Claude Code registers itself
  automatically (no OAuth app to create). Find server URLs in the directory above
  or at https://docs.claude.com/en/docs/claude-code/mcp.

For Google Drive, Gmail, and Calendar, you have a second option: the **Google
Workspace CLI**, `gws` (https://github.com/googleworkspace/cli). A connector reads
Google live; `gws` writes a permanent local copy into `raw/`, which is how our own
brain pulls Google data. Use it when they want that local copy, not just live access.

- Install it (pick one): `brew install googleworkspace-cli` (macOS/Linux),
  `npm install -g @googleworkspace/cli` (needs Node 18+), or a pre-built binary
  from https://github.com/googleworkspace/cli/releases.
- Sign in with the user's OWN Google account, no shared key:
  `gws auth setup` once (it walks them through their own Google Cloud project;
  it uses `gcloud` under the hood, and the repo's "Manual OAuth setup" covers it
  if they don't have `gcloud`), then `gws auth login -s drive,gmail,calendar` to
  scope it. An unverified app caps at ~25 scopes, so pick services, don't use the
  big "recommended" preset. Credentials are encrypted at rest in the OS keyring —
  nothing gets pasted into chat or committed.
- Confirm it works: `gws drive files list --params '{"pageSize": 5}'`.
- Then turn it into a puller: copy `scripts/pull-example.sh` to `pull-drive.sh`
  (or ask Claude to write it), have it call `gws` and write under `raw/drive`,
  same for gmail and calendar, and mark those rows in `sources.md` when files land.

Only if a tool has no connector at all, fall back to a local pull script: copy
`scripts/pull-example.sh` to `scripts/pull-<source>.sh` (or use the ready
`pull-github.sh`), run it once, confirm files land in `raw/<source>/`, then update
that row in `sources.md`.

After it works, mark that row in `sources.md` with today's date, then show the
updated count: "That's 2 of 6 live (Email, Code). Still waiting: Meetings, Docs,
Calendar, Web pages." Then ask if they want the next one or to stop here. Keep
showing this running tally every time, so they always see what's left.

### 3. Schedule, optional (Mac)

Offer this once at least one source is connected and they want hands-off refresh.
It's worth offering even to people on connectors only, not just pull-script users.
For the full walkthrough (what each routine does, the auto-commit heads-up, how to
verify and test it), follow the `/connect-schedule` playbook.

- `./scripts/install-launchagents.sh` schedules a morning pull (8am) and an
  evening pull + lint + push (9pm), Sun-Thu. On Linux, point cron at
  `scripts/morning-routine.sh` and `scripts/evening-routine.sh`.
- Say in one line what each part does. Pull scripts get refreshed on the schedule;
  connectors already refresh live, but the evening job still lints the wiki and
  pushes a backup to GitHub, which everyone wants. Don't run it without a yes.
- It also turns on auto-commit, which commits and pushes every 5 minutes even when
  Obsidian is closed (so the vault is still backed up overnight or from the
  terminal). Heads up, and say this before you run it: the installer pushes once
  the moment it loads, so make sure there's nothing sitting in the folder they
  don't want backed up to GitHub yet.

## Close

Update `sources.md` so every source you connected shows a real date under "last
pulled" (or "connected") instead of "not yet". Then tell them in two lines what's
live now and what's still waiting. Remind them they can run `/connect` again any
time to add the next tool.
