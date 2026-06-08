# CLAUDE.md, my knowledge base

This folder is the **Brain** in Capture, Brain, Act. It's an LLM wiki: a folder
of plain-text pages that holds everything the business knows. You (Claude) write
and maintain the pages in wiki/. I steer. This is the pattern Andrej Karpathy
named the LLM Wiki.

## First run — onboard before anything else
Check `wiki/overview.md`. If it's still unfilled — it contains the line
"(empty until /onboard runs)", or its `created:`/`updated:` are still `YYYY-MM-DD`
— then this is a fresh clone the user hasn't set up yet (the type folders under
`wiki/` will also still hold only `.gitkeep`; ignore the shipped `pricing.md` /
`proposal-guidelines.md` / `hot.md`, those ship with the starter). On their **very
first message, whatever it says**, do NOT offer to explore the brain, run
`/readiness`, or `/lint` an empty wiki. Say one line — "Looks like a fresh brain.
Let's set it up together, step by step." — and immediately start onboarding (read
`.claude/skills/onboard/SKILL.md` and follow it, one step at a time). Onboarding is
the only correct first move on a fresh brain.

## The method: Capture, Brain, Act
Three layers, in order, no skipping.
- **Capture.** Record everything. Meetings, emails, calls, docs land in raw/.
  What isn't recorded doesn't exist.
- **Brain.** This wiki. Raw data becomes linked, clean knowledge. One source of truth.
- **Act.** Skills and agents that read the Brain and do work.

## Page types
Each page is one markdown file in `wiki/<folder>/`. The `type:` in frontmatter is
the singular; the folder is the plural shown below. This is the full set we use —
the wiki ships every folder, and your own `CLAUDE.md` keeps the ones you use.
- client       → clients/       paying customers
- lead         → leads/         prospects, not paying yet
- partner      → partners/      vendors, referral partners, investors
- project      → projects/      work we're doing, internal or for a client
- person       → people/        a contact or a teammate
- meeting      → meetings/      notes from a call (filename: YYYY-MM-DD-topic.md)
- proposal     → proposals/     a quote or pitch, with its status and outcome
- decision     → decisions/     a choice we made and why (filename: YYYY-MM-DD-summary.md)
- tech         → tech/          a tool, pattern, or technology, and how we use it
- task         → tasks/         open work, who owns it, what's next
- research     → research/      something you studied — a video, article, tech eval — and how it applies
- operation    → operations/    a process: pricing, sales, onboarding, infrastructure
- legal        → legal/         contracts, NDAs, terms, anything legal
- presentation → presentations/ decks, talks, workshop material
- template     → templates/     reusable starting points (a proposal template, an email template)

## Frontmatter (top of every page)
```
---
type: <one of the above>
tags: [relevant, tags]
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: [raw files that informed this page]
---
```
Set `updated` to the real last-edit date. List the raw sources you used.

## The one rule that matters
Every name of a person, client, project, or partner is a [[wikilink]]: the name
in double square brackets. "Met with [[John Smith]] from [[Acme]] about
[[Acme Onboarding]]." Use [[page|Display Name]] when the text differs from the
filename. Cross-link generously. The links are where the value is.

## File naming
Lowercase kebab-case: acme-corp.md, onboarding-project.md. Meetings and decisions
are date-prefixed: 2026-05-31-acme-kickoff.md. If a file needs renaming, you rename
it so the [[links]] don't break. Never let me rename by hand.

## Folders
- raw/   source data pulled from my tools. NEVER edit by hand. Only the pull steps write here.
- wiki/  the pages you write and maintain.
Each client, lead, or partner with a logo gets a sibling folder named like its
page, with the logo at <slug>/logo.svg.

## Special files (keep current)
- wiki/index.md     a catalog of every page, one line each, by category.
- wiki/log.md       append-only: what changed and when, one entry per work session.
- wiki/overview.md  a living summary of the whole business.
- wiki/hot.md       a ~500-word cache of the most important current context, so
                    another tool can read one file and catch up fast.

## How to work
- Prefer updating an existing page over creating a duplicate.
- When new info contradicts a page, flag it plainly and update to the latest:
  "> Contradiction: old claim vs new claim, resolved as ...".
- Pages are factual. Opinions and analysis go in a query answer or a decision page.
- Update index.md and log.md after any change.

## Voice: before you write anything for a human
Any time you write or edit prose a person will read — an email, a LinkedIn post,
a proposal, a client doc, website copy — do two things first, every time, not
only when asked:
1. Load wiki/voice.md and write in that voice. It's grounded in real samples the
   owner pasted at onboard: their sentence length, tone, the words they use and
   avoid.
2. Run the humanizer so it doesn't read as AI (see SETUP.md step 6 to install it).
Skip this only for code, config, and raw notes. This is the whole difference
between a marketing agent that sounds like the owner and ChatGPT that sounds like
everyone. Generic AI writing has no idea who they are; voice.md is how it learns.

## Capture: where the data comes from
Sources are listed in sources.md. The first time you wire one, save a short note
at references/<tool>.md so next time you don't figure it out again.

## Scripts and automation
scripts/ holds the machinery:
- pull-all.sh runs every pull-<source>.sh into raw/. Copy pull-example.sh to add a source.
- lint-wiki.sh health-checks the wiki and writes wiki/_health.md.
- auto-ingest.sh runs your agent headless (claude -p, or codex exec) to ingest new raw/ into the wiki. Fails soft if no agent is logged in.
- morning-routine.sh pulls fresh data; evening-routine.sh does the full loop: pull, ingest (auto-ingest.sh), lint, then push.
- install-launchagents.sh schedules both on macOS (Sun-Thu, 8am and 9pm). On Linux, use cron.
- auto-commit.sh and the Obsidian Git plugin (config in .obsidian/) keep the vault synced.

## Act: skills and agents
Reusable work lives in .claude/skills/. The rule from the workshop:
**the third time you do a task by hand, you build an agent for it.** First time
it's special, second it's familiar, third it's a pattern, and a pattern an agent
does better than you. Don't build a complex system on day one. Do it by hand,
get stuck, then build. An agent without this Brain underneath it is shallow.

Day to day, these ship as skills:
- /pull      fetch new data from a source into raw/ (Capture).
- /ingest    turn raw files into linked wiki pages (Brain).
- /query     search the wiki and answer with [[wikilink]] citations.
- /lint      health-check the wiki: orphans, broken links, stale pages.
- /daily     pull everything, ingest what's new, summarize the day.
Plus /onboard (first-time setup) and /readiness (score Capture, Brain, Act).
And /meeting-prep, a working example agent: it reads the Brain, researches a
person and company, and writes a profile back. Copy its shape to build your own.

## What NOT to add
- No notes/, misc/, tmp/, or inbox/ folders. They become graveyards.
- Flat beats nested. If you can't find it, neither can I.
- One index.md, one log.md, one CLAUDE.md. Don't fork them.
- The wiki holds interpreted facts. Raw dumps stay in raw/.
