# Growing your brain

Start lean. Add structure only when the work asks for it. A good test: if you've
wanted a thing three times, add it. Not before.

## What to add, and when
- A new page type under `wiki/` when a kind of thing keeps recurring (partner, deal, supplier).
- A skill in `.claude/skills/` when you've done the same task by hand three times.
- A pull script or an MCP when you keep pasting the same source in by hand.
- A schedule (cron or launchd) once pulling fresh data manually gets annoying.

## What NOT to add
- No `notes/`, `misc/`, `tmp/`, or `inbox/` folders. They become graveyards.
- No folder inside a folder inside a folder. Flat beats nested. If you can't find
  it, neither can the agent.
- One `index.md`, one `log.md`, one `CLAUDE.md`. Don't fork them into copies.
- The wiki holds interpreted facts, not raw dumps. Unprocessed files belong in
  `raw/`. If a page is just a paste, it's Capture, not Brain.

## Where to look as you grow
- `/readiness` scores Capture, Brain, and Act, and tells you the next
  highest-leverage move. Run it weekly.

The rhythm, from the workshop: the third time you do a task by hand, build an
agent for it. Not before. Manual first, get stuck, then build.
