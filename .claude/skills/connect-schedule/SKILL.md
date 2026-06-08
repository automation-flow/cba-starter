---
name: connect-schedule
description: Wire the brain's scripts to run on a schedule — pull, ingest, lint, backup — so it stays current on its own. Use after at least one source is connected and the user wants hands-off refresh.
---

# Connect: Schedule (run the scripts on their own)

You're turning on the automation so the brain refreshes without the user lifting
a finger. Do this once at least one source is connected (`/connect`). The user is
not technical — explain each part in one line, and get an explicit **yes** before
you schedule anything.

## What the scripts do
The `scripts/` folder is the machinery. The schedule runs two routines plus a
backup loop:
- `morning-routine.sh` (8am) — pulls fresh data into `raw/` (runs every
  `pull-<source>.sh`, including the `pull-drive.sh` / `pull-github.sh` etc. the
  connect playbooks set up).
- `evening-routine.sh` (9pm) — the full loop: pull, **ingest** new `raw/` into the
  wiki (`auto-ingest.sh`, headless), lint, then commit and push a backup.
- `auto-commit.sh` — commits and pushes every few minutes even when Obsidian is
  closed, so nothing is ever lost.

## 1. Schedule them (macOS)
One command installs all three as launchd agents (Sun–Thu, 8am and 9pm; no sudo,
no Full Disk Access):
```bash
./scripts/install-launchagents.sh
```
**Say this before you run it:** the installer also turns on auto-commit, which
pushes once the moment it loads and then every 5 minutes. So make sure there's
nothing sitting in the folder they don't want backed up to GitHub yet. Then get
the yes.

On **Linux**, point cron at `scripts/morning-routine.sh` and
`scripts/evening-routine.sh` instead.

## 2. Confirm they're loaded
```bash
launchctl list | grep businessbrain
```
Three entries (morning, evening, autocommit) means they're scheduled. Logs land
in `/tmp/kb-morning-routine.log` and `/tmp/kb-evening-routine.log`.

## 3. Test without waiting for the clock
Kick one off now so they see it work:
```bash
./scripts/evening-routine.sh
# or via launchd:
launchctl kickstart -k gui/$UID/com.businessbrain.kb-evening
```

## A note on overnight ingest
The evening routine ingests **headless** — it calls the agent (`claude -p`, or
`codex exec`) to turn new `raw/` into wiki pages while they sleep, and pushes the
result straight to `main`. That's the point of a self-maintaining brain. It needs
the agent logged in for non-interactive use; if it isn't, the step **skips itself
with a message and the rest of the routine (the backup) still runs**. They can
always run `/daily` by hand instead.

## Close
Tell them in two lines what now runs on its own and when. The brain is now
updating itself. They can re-run `/connect` any time to add another source.
