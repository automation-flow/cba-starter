# Demo runbook — the live segment

This is the run sheet for the webinar's live beat ("watch the tools talk, then watch
Guy run"). It pairs with the deck's Live slide. Keep it open on a second screen.

## The two halves

The live beat has two parts. Only one of them runs on this starter:

- **"The tools talk"** (Spinach → `raw/` → git Brain → NanoClaw → Discord/WhatsApp) is
  our *production* system. Show it from there, or narrate over screenshots. It does
  not run on this bare starter.
- **"Guy runs"** (transcript → proposal, with the price-mismatch stop) **runs here.**
  This is the live demo. Everything below is that.

## Pre-flight

- Open this folder as an Obsidian vault, and open Claude Code inside it (`claude`).
- Have `raw/transcripts/example-call.md` visible (this is the captured call).
- Clean state: `wiki/proposals/` should be empty (delete any `*.md` from a prior take).
- Recording cued as a fallback. If a step stalls, cut to the clip:
  "we recorded this earlier so we can walk it step by step."

## The run (Capture → Brain → Act)

1. **Capture.** Show `raw/transcripts/example-call.md`. Say: this is what the recorder
   dropped in, raw, untouched. (Optionally run `/ingest` to show it becoming a linked
   page in `wiki/` — that's the Brain.)
2. **Act, kick off Guy.** The reliable way to invoke it is natural language:
   > "Run Guy on `raw/transcripts/example-call.md`."
   (The `/guy` slash form may also work depending on your Claude Code build — test it
   before you record.)
3. **Watch the agents.** Guy is an orchestrator and holds the whole context. It
   dispatches three independent sub-agents in order: **Product Discovery → Technical
   Discovery → Pricing**, with a **Solution Research tool** in between to check prior
   art. They're real registered subagents — you'll see each one named as Guy delegates
   to it. Call each out as it runs; that's slide 10 made real. The agents live in
   `.claude/agents/` (`product-discovery`, `technical-discovery`, `pricing`); the
   tool is in `.claude/skills/guy/tools/`.
4. **The money moment.** The call said **$4,000**; the pricing model's agent-build band
   is **$6,000–$12,000**. The Pricing agent reports a **MISMATCH** and hands it back,
   and Guy **stops and asks you which to use** instead of guessing. Pause here. This is
   the beat that kills the "AI goes rogue" fear: the human decides, the agent executes.
5. **The proposal.** Pick a number when Guy asks. It assembles the proposal from the
   three agents' findings (plus the research tool) and saves it to `wiki/proposals/`.
   Open it. Narrate: in real use this exports to a `.docx` in the client's Drive folder.

## Reset for another take

- Delete the generated proposal: remove `wiki/proposals/*.md` (keep `.gitkeep`).
- Nothing else changes; `raw/transcripts/example-call.md` and the Brain stay put.

## If asked "is this the real Guy?"

Same shape, smaller. Our production Guy runs the same three agents (plus the research
tool) under an orchestrator, wired to Drive and our CRM. This starter is the teaching
version you can clone and run yourself tonight.
