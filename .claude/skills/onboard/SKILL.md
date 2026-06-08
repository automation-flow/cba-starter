---
name: onboard
description: The first-run guided setup. The moment someone opens a fresh brain, this walks them — one step at a time — from empty repo to a working, connected, self-updating LLM wiki: their business, into Obsidian, connecting their tools, backup + automation, and the first small thing to capture. Use on first run, or to re-onboard.
---

# Onboard — set up the brain together, one step at a time

You are setting up a non-technical person's "second brain" (an LLM wiki) from a
fresh clone. This is a guided journey, not a form. You do the work; they mostly
answer and click. Hold their hand the whole way, and never assume they know git,
the terminal, or what a vault is.

## The two rules that keep this from being annoying
1. **One thing at a time.** Ask ONE question, or give ONE instruction, then STOP
   and wait for their reply. NEVER paste a list of questions, and never dump a
   wall of steps. If you catch yourself writing "1… 2… 3…" of things for them to
   do, stop and give only the first. This is the rule people complain about most
   when it's broken — do not break it.
2. **One line of why, then the ask.** A short reason, then the step. No lectures.

Write each answer into the wiki as you go (overview.md, voice.md, sources.md), so
if the session stops you can resume from where the files leave off.

## 0. Are we actually onboarding?
Check `wiki/overview.md`. If it still says "(empty until /onboard runs)" or its
dates are `YYYY-MM-DD`, this is a fresh brain — onboard. (The type folders under
`wiki/` holding only `.gitkeep` is the same signal; the shipped `pricing.md` /
`proposal-guidelines.md` / `hot.md` come with the starter, so ignore those.) If
overview.md has real content and the wiki has real pages, ask: "You already have a
brain here. Re-onboard from scratch?" Continue only on yes, and first move the old
files to `archives/onboard-<date>/` so nothing is lost.

## Step 1 — Who they are (the first question)
Open warm and short: "Let's set up your brain together — I'll guide you the whole
way, one step at a time." Then ask ONE thing:
**"What does your business do, and who's on the team?"**
Wait. Then write `wiki/overview.md` from their answer (what the business does, the
team). That's their first real page — they'll see it in Obsidian in a moment.

## Step 2 — Get them into Obsidian
Now they need to *see* the brain. Obsidian is how they read it; you write it.
- Ask if they have Obsidian. If not: "Grab it now — it's free, https://obsidian.md.
  Install it and tell me when it's open, I'll wait." (It can download while we keep
  going; don't block on it.)
- When it's open: "In Obsidian, choose **Open folder as vault** and pick this
  folder." Confirm they can see `wiki/` and the overview page you just wrote.
One step, then wait for "done" before the next.

## Step 3 — How they write (so nothing sounds like a robot)
One ask, and hold the line on it:
"Paste me 1–2 real things you've written — a real email or LinkedIn post. Paste it
**raw**. Don't type a fresh one here: if you write it while we talk, it's already
shaped by our chat. Open a real one in another tab and paste the unedited text.
This is the one rule I can't bend."
Wait. Then write `wiki/voice.md` from the samples: sentence length, tone, the words
they use and avoid, quoting the samples so it stays grounded. This is what the
humanizer and every writing agent reads before it writes a word for them.

## Step 4 — Fill in the rest of the brain (quick, so they see something real)
Now scaffold, so Obsidian shows a living brain instead of empty folders:
- `CLAUDE.md`, filled for their business. Keep the "Voice: before you write…" rule
  intact (it points at `voice.md`). Keep the page-type folders they'll actually use,
  and tell them the rest are there for when they grow.
- `sources.md`: you'll fill it properly in the next step.
- Make sure `wiki/index.md` and `wiki/log.md` exist; log this onboarding session.
Tell them in one line what you just built and that they can watch it appear in
Obsidian.

## Step 5 — Connect their tools (this is the important one)
This is where the brain starts feeding itself, so go slow and do it WITH them.
Ask ONE: **"What tools do you use day to day, and where does your information live —
calls, email, docs, calendar, chat, code?"** Wait.
Then ask ONE more, because it's the spine of Capture: **"And your meetings and calls
— are they recorded or transcribed yet (Spinach, Otter, Granola), or not?"** Wait.
Write their answers into `sources.md`, one row per source, all marked "not yet".

Now hand off to **/connect** — do not improvise the wiring. /connect does backup
first, then sources ONE AT A TIME with a running tally, using the per-source
playbooks (`/connect-gmail`, `/connect-github`, `/connect-clickup`, `/connect-gws`).
Pick the source that matters most, get it working, then the next. If they don't
transcribe their calls yet, say plainly that turning on a recorder today is the
single highest-value move — it's the raw material the whole brain is built from.

## Step 6 — Backup + keep-it-fresh (so it survives and updates itself)
/connect covers this; make sure it actually happens, in this order:
- **Backup to THEIR OWN private repo** (not the starter — they can't push to ours),
  plus the **Obsidian Git plugin** for team sync. Confirm the first `git push`
  truly works before moving on.
- Then offer the **schedule** (`/connect-schedule`): the morning pull, the evening
  pull → ingest → lint → push, and auto-commit. Only after a source is connected and
  they want hands-off refresh. One line each on what it does, and get a yes before
  scheduling anything (auto-commit pushes the moment it loads).

## Step 7 — Start small (not a 90-day plan)
Do NOT ask for big goals or a roadmap. Our way is the opposite: start tiny, grow by
need. Ask ONE: **"What's the one task that eats your week?"** Wait. Then frame it:
"Don't build a big system. Take that one task, do it by hand in here a couple of
times, and the third time you do it, we turn it into a skill or an agent — that's
the rule. First time it's special, second it's familiar, third it's a pattern, and
a pattern an agent does better than you."
The growth mechanism isn't a plan, it's a habit: run **/readiness** now and then — it
scores Capture, Brain, Act and names the single next highest-leverage step. The brain
grows one proven need at a time, not in a big upfront build.

## Step 8 — Close
Three lines, no more:
- What you built and connected.
- The one first thing to capture — their Step 7 task, or "turn on a recorder today"
  if they don't transcribe yet.
- "Try me now: ask 'what should I focus on this week?'"
Never ask them to paste an API key or token into the chat, ever — not here, not in
/connect. Keys live in a git-ignored `.env` or a password manager; you reference
them, the raw value is never stored or committed.
