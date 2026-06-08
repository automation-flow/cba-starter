# Build your own brain: the full setup guide

This is the detailed guide from the **2-Person Enterprise** talk by [Automation Flow](https://automationsflow.com). It takes you from a fresh clone of the starter to a working "second brain" (an LLM wiki) that your AI agents read before they do any work.

You don't need to be a developer. Most steps are: run a command, then answer the questions Claude asks you.

---

## What you're building

A single folder of plain text (markdown) files that holds everything your business knows: clients, projects, people, meetings. Claude Code writes and maintains it. Obsidian is how you read and browse it. This is the pattern Andrej Karpathy named the **LLM Wiki**.

Three layers, in order:

1. **Capture.** Record everything (meetings, emails, calls).
2. **Brain.** Turn that raw data into linked, clean knowledge.
3. **Act.** Agents that read the Brain and do work (marketing, proposals, finance).

---

## Step 0: install two things

You install two apps. Claude sets up everything else with you later, so don't worry about git, GitHub, or Python yet.

- **Obsidian**, https://obsidian.md, free. How you read and browse the wiki.
- **Claude Code**, which writes the wiki and runs the agents. Either:
  - the **desktop app**, no terminal needed, download from https://claude.com/download; or
  - one line in a terminal: `curl -fsSL https://claude.ai/install.sh | bash` (macOS/Linux), or `irm https://claude.ai/install.ps1 | iex` (Windows PowerShell).

> Claude Code needs a paid Claude plan (Pro or Max). The free plan doesn't include it.

---

## Step 1: get your own copy

The starter has the `CLAUDE.md` schema, the folder structure, the skills, and the scripts. You want your **own private copy**, not a clone of ours — this vault will hold your whole business, and you back it up to a repo only you can push to.

Easiest path: on GitHub, open the starter and click **Use this template → Create a new repository**. Name it (e.g. `business-brain`), set it **Private**, and create it. Then clone *your* new repo:

```bash
git clone https://github.com/<your-username>/business-brain
cd business-brain
```

> No GitHub account yet? You can still `git clone https://github.com/automation-flow/cba-starter business-brain` to try it locally — but **backup won't work** until you make your own private repo (it can't push to ours). `/connect` walks you through that.

Then:

1. In Obsidian, choose "Open folder as vault" and pick this folder.
2. Open Claude Code inside it (run `claude`).

---

## Step 2: tell Claude "let's go"

In Claude Code, run `/onboard`, or just type "let's go, set this up with me." From here you mostly answer questions. Claude:

- interviews you one question at a time, then writes your `CLAUDE.md` and the first wiki pages;
- offers to connect your tools and turn on backup, one at a time, when you're ready;
- explains each step as it goes.

No config to learn, no commands to memorize. About an hour, most of it spent answering questions while Claude does the typing.

---

## Step 3: connect your tools (`/connect`)

When you say "let's go", Claude offers to wire your tools. You can also run `/connect` any time. It does this with you, one at a time, and you approve each step.

The good news: you almost never need an API key now. Most tools connect as a **connector** with a browser sign-in.

### A. Connectors (the easy way, no keys)

Open the Anthropic connector directory at https://claude.ai/directory (or https://claude.ai/customize/connectors), add the one you want (Google Drive, Gmail, Google Calendar, Notion, Slack, and more), and sign in. If you're logged into Claude Code with the same Claude account, the connector shows up automatically. Check it inside Claude Code with `/mcp`.

Prefer the terminal? `claude mcp add --transport http <name> <url>`, then run `/mcp` and finish the sign-in in your browser. Claude registers itself, so there's no developer "app" to set up.

### B. Pull scripts (when you want a local copy in `raw/`)

For sources without a connector, a small script writes a copy into `raw/`. `pull-github.sh` already works with the `gh` CLI; for others, copy `scripts/pull-example.sh` or just ask Claude to write it.

For **Google Drive, Gmail, and Calendar**, the cleanest puller is the **Google Workspace CLI** (`gws`, https://github.com/googleworkspace/cli) — it's how our own brain pulls Google data. Install it (`brew install googleworkspace-cli`, or `npm install -g @googleworkspace/cli` with Node 18+, or a binary from the [releases page](https://github.com/googleworkspace/cli/releases)), then sign in with your own Google account — no shared key:

```bash
gws auth setup                              # one-time: your own Google Cloud project + login
gws auth login -s drive,gmail,calendar      # scope it to what you need
gws drive files list --params '{"pageSize": 5}'   # confirm it works
```

Credentials are encrypted at rest in your OS keyring, never pasted into chat or committed. Once it's authed, point a `pull-drive.sh` (copied from `pull-example.sh`) at `gws` and it writes into `raw/drive`.

Rule of thumb: use a connector when you want the agent to read a system live, a pull script (or `gws`) when you want a permanent local copy.

> **Security:** keep your GitHub repo private, this vault holds your whole business. Keep `raw/` git-ignored so your real emails and docs never leave your machine. On the rare tool that needs a key, it goes in a git-ignored `.env` file or a password manager, never pasted into the chat or committed.

---

## Step 4: sync across your team

The vault lives in git, and one Obsidian plugin keeps everyone in sync. The starter ships the settings pre-baked in `.obsidian/plugins/obsidian-git/data.json`, so you install the plugin and reload.

1. First time only: a fresh vault opens in **Restricted Mode**, which disables community plugins. In Obsidian, Settings > Community plugins > **Turn on community plugins**. (If Obsidian asks to "Trust author and enable plugins?" when you open the vault, choose Trust — that does the same thing.) Until you do this, the "Browse" button in the next step is greyed out.
2. Now Settings > Community plugins > Browse, search "Git" (by Vinzent03), Install, Enable.
3. Reload Obsidian (Cmd+P > "Reload app without saving") so it picks up the bundled settings:

| Setting | Value | What it does |
|---|---|---|
| Auto save interval | `5` | Commit your changes every 5 min |
| Auto push interval | `5` | Push to GitHub every 5 min |
| Auto pull interval | `10` | Pull teammates' changes every 10 min |
| Pull on boot | `on` | Get the latest when you open Obsidian |
| Pull before push | `on` | Avoids most conflicts |
| Sync method | `merge` | Safer than rebase for a shared vault |

After that you never think about git again. Edit anything, it's committed in 5 min, pushed in 5, your teammate pulls it in 10.

---

## Step 5: keep it fresh on a schedule

The starter ships the scripts that do the boring part, in `scripts/`:

- `pull-all.sh` runs every `pull-<source>.sh` into `raw/`.
- `lint-wiki.sh` health-checks the wiki and writes `wiki/_health.md`.
- `auto-ingest.sh` turns the newly-pulled `raw/` data into linked wiki pages, unattended (see below).
- `morning-routine.sh` pulls fresh data. `evening-routine.sh` does the full loop: pull, **ingest**, lint, then commit and push.
- `auto-commit.sh` syncs the vault every few minutes, alongside the Obsidian Git plugin.

### The brain updates itself overnight

The evening routine doesn't just pull data, it **ingests** it. Step 3 runs `auto-ingest.sh`, which calls your AI agent **headless** (`claude -p`, or `codex exec` if you use Codex) to read the new `raw/` files and write them into the wiki as linked pages — the same thing `/daily` does when you run it by hand, but while you sleep. You wake up to an updated brain.

Two things to know:

- **It needs your agent logged in for non-interactive use.** An ordinary logged-in Claude Code session is enough on your own Mac. If it isn't logged in (or isn't installed), the step **skips itself with a clear message and the rest of the routine still runs** — your backup is never blocked. You can always open Claude Code and run `/daily` instead.
- **Its edits go straight to `main`.** The agent writes wiki pages and the routine pushes them, with no human gate. That's the point of a self-maintaining wiki, but it's why `auto-ingest.sh` is scoped to *edit the wiki only* (it never pulls or pushes itself — the routine owns that).

On a Mac, schedule them with one command (Sun-Thu, 8am and 9pm, no sudo, no Full Disk Access):

```bash
./scripts/install-launchagents.sh
```

> Heads up: auto-commit starts the moment you run this — it commits and pushes whatever's in the folder right now, then again every 5 min. Make sure there's nothing sitting there you don't want on GitHub yet before you turn it on.

Check they're loaded with `launchctl list | grep businessbrain`. Logs land in `/tmp/kb-morning-routine.log` and `/tmp/kb-evening-routine.log`. On Linux, point cron at `morning-routine.sh` and `evening-routine.sh` instead.

---

## Step 6: install skills

A **skill** is a saved instruction set that teaches Claude to do one thing your way. The easy way to add one: tell Claude "install the humanizer skill for me" and it does it. To share skills across your team, say "set these up for my whole team" and it puts them at the org level so everyone gets them.

By hand, if you ever need it, skills live in `.claude/skills/` (per project) or `~/.claude/skills/` (everywhere):

```bash
mkdir -p .claude/skills && cd .claude/skills
git clone <skill-repo-url>
```

Start with these:

- **Humanizer**, strips the AI fingerprint from anything you write. https://github.com/blader/humanizer
- **Skill Creator**, the skill that builds new skills. This is how you make your own.
- **Superpowers**, planning, tests, and code review built in.

Once installed, you don't memorize commands. Type `/humanizer`, or just say "clean this up so it doesn't sound like AI," and Claude runs the right one.

---

## Reference: what's inside `CLAUDE.md`

The starter's `CLAUDE.md` is the schema Claude follows. `/onboard` fills it in for your business, but here's what it defines, so you know what you're steering:

```markdown
# CLAUDE.md, my knowledge base

This folder is my company's knowledge base, an LLM wiki. You (Claude) write
and maintain the pages in wiki/. I steer.

## Page types
Each page is one markdown file in wiki/<type>/. Types:
- client    paying customers
- lead      prospects, not paying yet
- project   work we're doing
- person    a contact or a teammate
- meeting   notes from a call (filename: YYYY-MM-DD-topic.md)

## Frontmatter (goes at the top of every page)
---
type: client | lead | project | person | meeting
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

## The one rule that matters
Every name of a person, client, or project is written as a [[wikilink]]:
the name inside double square brackets. Example:
"Met with [[John Smith]] from [[Acme]] about [[Acme Onboarding]]."
This is what connects the pages into a graph. Do it everywhere.

## Folders
- raw/   source data pulled from my tools. NEVER edit these by hand.
- wiki/  the pages you write and maintain.

## How to work
- Prefer updating an existing page over creating a duplicate.
- When new info contradicts a page, flag it and update to the latest.
- Keep an index.md (catalog of all pages) and a log.md (what changed, when).
```

That `[[wikilink]]` rule is the one that matters. A name in double square brackets, like `[[John Smith]]`, becomes a clickable link, and Obsidian draws a map of how everything connects. Write every person, client, and project name that way.

---

## The daily loop

That's the whole thing. From here it's repetition:

1. Capture everything (transcribe meetings, save useful web pages).
2. Ask Claude in plain words: *"what's new with client X?"*, *"update Y's page from yesterday's meeting."*
3. The third time you do a task by hand, ask Claude to build a skill or an agent for it.

Questions? Talk to us: https://wa.me/972559958398 or hello@automationsflow.com
