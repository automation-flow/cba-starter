# AGENTS.md — run this brain with Codex

This repo is an LLM-wiki "second brain": a folder of markdown pages that holds
everything a business knows. It was built for Claude Code, but only the agent
wiring is tool-specific — the schema, the scripts, and the wiki itself are
tool-agnostic, so it runs under Codex (or any agent that reads `AGENTS.md`) too.

## Read this first
The authoritative schema and rules live in **CLAUDE.md**. Read it now, in full,
before doing anything. It defines the page types, the frontmatter, the
`[[wikilink]]` rule, the folders, and how to work. Everything there applies to
you verbatim — read "Claude" as "you". This file only adds the Codex-specific
wiring, so there is still one source of truth (do not fork CLAUDE.md).

## The method (from CLAUDE.md): Capture → Brain → Act
- **Capture** — raw data lands in `raw/` (never edit it by hand).
- **Brain** — you turn raw into clean, linked pages in `wiki/`.
- **Act** — the workflows below read the Brain and do work.

## Workflows (the "skills")
Claude Code exposes these as `/slash` commands. Under Codex, the user asks for
one by name and you execute it by reading its instruction file and following it
exactly. Each file is plain prose — it ports as-is, no translation needed.

| Ask for…     | Read and follow                        | Does |
|--------------|----------------------------------------|------|
| onboard      | `.claude/skills/onboard/SKILL.md`      | first-time setup interview |
| connect      | `.claude/skills/connect/SKILL.md`      | wire tools + turn on backup (conductor) |
| connect-gmail | `.claude/skills/connect-gmail/SKILL.md` | email: connector or local copy |
| connect-github | `.claude/skills/connect-github/SKILL.md` | code via the `gh` CLI |
| connect-clickup | `.claude/skills/connect-clickup/SKILL.md` | ClickUp tasks via API token |
| connect-gws  | `.claude/skills/connect-gws/SKILL.md`  | Drive/Gmail/Calendar local copies via `gws` |
| connect-schedule | `.claude/skills/connect-schedule/SKILL.md` | run the scripts on a schedule |
| pull         | `.claude/skills/pull/SKILL.md`         | Capture: fetch into `raw/` |
| ingest       | `.claude/skills/ingest/SKILL.md`       | Brain: raw → linked pages |
| query        | `.claude/skills/query/SKILL.md`        | answer from the wiki, cited |
| lint         | `.claude/skills/lint/SKILL.md`         | health-check the wiki |
| daily        | `.claude/skills/daily/SKILL.md`        | the full loop |
| readiness    | `.claude/skills/readiness/SKILL.md`    | score Capture / Brain / Act |
| meeting-prep | `.claude/skills/meeting-prep/SKILL.md` | example Act-layer agent |

Optional: to get a real Codex `/slash` command, copy a file into
`~/.codex/prompts/<name>.md` (user-level — it is not shared through this repo).

## Connecting tools under Codex
- **Pull scripts** (`scripts/pull-github.sh`, etc.) are plain shell — they work
  unchanged. `pull-github.sh` is the one that ships ready; run `gh auth login`
  once first.
- **Live connectors** (Drive, Gmail, Calendar) use MCP over streamable HTTP with
  OAuth. See `.codex/config.toml.example`: copy it to `~/.codex/config.toml` (or
  `.codex/config.toml` for this project, once trusted), then run
  `codex mcp login <server>`. No API key, browser sign-in — the same idea as
  Claude Code's connector directory.

## Backup and team sync
Same as the Claude path: install the Obsidian Git plugin and turn on community
plugins first (a fresh vault opens in Restricted Mode). The `/connect` workflow
above covers it; or see SETUP.md Step 4.

## Prerequisite
Codex needs a paid plan (ChatGPT Plus/Pro) or an API key — the same way Claude
Code needs a paid Claude plan (Pro/Max).
