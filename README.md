# Build Your Own Brain: a starter

This is a starter for an LLM-wiki "second brain". An LLM wiki is a folder of
plain-text markdown pages that holds everything your business knows: clients,
projects, people, meetings. Claude Code writes and maintains the pages. Obsidian
is how you read and browse them. This is the pattern Andrej Karpathy named the
LLM Wiki.

You don't need to be a developer. You clone this, open it, and tell Claude to set
it up with you — it guides you one step at a time, and mostly you just answer and
click.

## The method: Capture, Brain, Act

Three layers, in order. You record everything, turn it into linked knowledge, then
let agents act on it. This repo is the Brain, and it ships the skills that run all three:

| Layer | What happens | Where it lives | Skills |
|-------|--------------|----------------|--------|
| **Capture** | Record everything as it comes in: meetings, email, docs, repo activity | `raw/` | `/connect`, `/pull` |
| **Brain** | Raw data becomes linked, searchable knowledge you can trust | `wiki/` | `/ingest`, `/query`, `/lint` |
| **Act** | Skills and agents read the Brain and do real work for you | `.claude/skills/` | `/daily`, `/meeting-prep`, `/guy` |

Each layer needs the one before it. Capture with no Brain is a pile of files; a
Brain with no Act just sits there. `/readiness` scores all three so you can see
where the weak link is.

The Brain ships a folder for every kind of page — clients, leads, partners,
projects, people, meetings, proposals, decisions, research, operations, legal,
presentations, tasks, tech, templates — empty until you fill them. Onboarding keeps
the ones you'll use and leaves the rest waiting until you grow into them.

## How to use it

1. Make your own private copy: on GitHub click **Use this template** on the starter, create a **private** repo, and clone that (full steps in [SETUP.md](SETUP.md)). Just trying it out? Clone this repo directly — but backup waits until you make your own, since you can't push to ours.
2. Install Obsidian (https://obsidian.md) and Claude Code (https://docs.claude.com/claude-code).
3. In Obsidian, choose "Open folder as vault" and pick this folder.
4. Open Claude Code inside this folder (run `claude`). Just say hi or "let's go" — on a fresh brain it starts the setup automatically (or type `/onboard`).
5. Claude guides you the whole way, one step at a time: your business, getting you into Obsidian, connecting your tools, turning on backup and automation, and the first small thing to capture. Mostly you just answer and click.

> Claude Code needs a paid Claude plan (Pro or Max). The free plan doesn't include it. Full details in [SETUP.md](SETUP.md).

Once it's running, type `/readiness` any time to score how ready your brain is (Capture, Brain, Act, Cadence) and see the next highest-leverage step.

## Day to day

Once it's running, these skills are how you work it:
- `/connect` turn on backup and wire your tools, one at a time, with you.
- `/pull` fetch new data into raw/ (Capture).
- `/ingest` turn raw files into linked wiki pages (Brain).
- `/query` ask the wiki anything, get answers with citations.
- `/lint` health-check the wiki.
- `/daily` the full loop: pull, ingest, summarize.
- `/readiness` score how ready your brain is, across Capture, Brain, Act.
- `/meeting-prep` a working example agent: name + company in, a sourced client profile out. Copy its shape to build your own.
- `/guy` a second example agent: a sales call transcript in, a client-ready price proposal out. It's an **orchestrator that composes three independent, reusable specialists** (`product-discovery`, `technical-discovery`, `pricing`) plus a solution-research tool — each stands alone, so any agent you build later can reuse them. It reads your pricing + voice from the Brain, and asks before it guesses. Try it: tell Claude "run Guy on `raw/transcripts/example-call.md`". Running it as a demo? See [DEMO.md](DEMO.md). This is the orchestrator-workers pattern from Anthropic's [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents).

The one rule from the workshop: the third time you do a task by hand, build an
agent for it. Manual first, get stuck, then build.

## What is a `[[wikilink]]`?

It is a name wrapped in double square brackets, like `[[John Smith]]`, and
Obsidian turns it into a clickable link that connects every page into a graph.

## Automate it

The `scripts/` folder keeps the brain current on its own: `pull-github.sh` pulls
your repo activity (it works out of the box with the `gh` CLI), `lint-wiki.sh`
checks the wiki, and the morning/evening routines run both. On a Mac, schedule
them with `./scripts/install-launchagents.sh` (Sun-Thu, 8am and 9pm); on Linux,
point cron at the routine scripts. For Drive, Gmail and calendar, connect an MCP
server with `/connect` instead of a script. For backup and team sync, install the
Obsidian Git plugin (Settings > Community plugins > Browse > "Git" by Vinzent03 —
turn on community plugins first if it's a fresh vault); the config ships in
`.obsidian/` so it just works once installed. `/connect` walks you through it.

## Prefer Codex?

The whole brain — the schema, the scripts, the wiki — is tool-agnostic, so it
also runs under OpenAI Codex. Codex reads `AGENTS.md` instead of `CLAUDE.md`, so
open it and follow from there: it points back to `CLAUDE.md` for the schema,
lists the same workflows (onboard, connect, pull, ingest, query…), and explains
connectors via `.codex/config.toml.example`. The pull scripts and Obsidian setup
are identical.

## Full guide

For the complete walkthrough (connecting your tools, syncing across a team,
scheduling, skills), see SETUP.md.

---

Built from the 2-Person Enterprise workshop by Automation Flow, https://automationsflow.com
