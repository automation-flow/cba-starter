## Session Management

- Start sessions with `/recap` to understand current state
- End sessions with `/handoff` to save progress to `CURRENT_STATUS.md`
- One major task per session, then handoff
- Do not rely on PreCompact hook — hand off early and often
- After completing any major task, run `/handoff` before starting the next
- Never end a session with uncommitted changes to a **tracked** file. Land them
  on a branch and open a PR, or revert them. A tracked file left modified is
  what makes the next `git pull` fail under a human's hands, and the person who
  hits it is rarely the one who left it. Untracked scratch is fine: add it to
  `.gitignore` instead.
- This applies hardest to `workspace.json` in the framework repo, which several
  sessions register projects into. Two sessions editing it on the same day is
  normal; two sessions leaving it dirty is what breaks the next pull.
- `scripts/framework-sync.sh` pulls the framework checkout every 10 minutes, but
  only when the tree is clean. When it is blocked it records the offending files
  in `.git/af-sync-status.json` rather than working around them. Read that file
  before asking why a checkout is behind.
