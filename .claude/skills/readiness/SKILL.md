---
name: readiness
description: Score how ready this brain is across the three layers, Capture, Brain, and Act. Read-only. Run it weekly and watch the score climb.
---

# Readiness

A read-only health score for the brain, on our three layers. Do not change any
files. Scan, score, and report. Three axes, about 33 points each, 100 total.

## The three layers
**Capture (/33).** Is data flowing in, and is it fresh? Check sources.md and raw/.
Points for each connected source, for recent files in raw/, for a schedule that
keeps it current, and for meetings being transcribed. Empty raw/ scores low.

**Brain (/33).** Is the wiki real and linked? Count pages in wiki/, check they use
[[wikilinks]], flag orphan pages (nothing links to them), broken links, and stale
pages (not updated in 60+ days). Confirm index.md, log.md, and overview.md exist
and are current. A pile of raw files with no wiki pages scores low.

**Act (/34).** Can it do work? Count skills in .claude/skills/ and any agents, and
check whether they actually read the wiki. Points for skills that run on a schedule
without you asking. Zero skills scores low.

## Output
1. The three scores and the total out of 100.
2. A stage: 0-40 Foundation, 41-70 Built, 71-90 Compounding, 91+ Autonomous.
3. The top 3 gaps, ranked by leverage (points you would gain times how much it
   helps day to day). For each gap, give the exact next command or prompt to fix it.

Keep it short. End with the single highest-leverage next step.
