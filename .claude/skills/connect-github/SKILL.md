---
name: connect-github
description: Connect GitHub to the brain with the gh CLI, so pull-github.sh pulls repo activity (commits, issues) into raw/. Use when the user wants their code or repo activity captured.
---

# Connect: GitHub

You're wiring the user's GitHub so repo activity lands in the brain. This is the
smoothest source — the `gh` CLI signs in through the browser, no keys to manage,
and the starter already ships `pull-github.sh` that uses it.

## 1. Install the gh CLI
Offer to run the one that fits, then confirm with `gh --version`:
- macOS / Linux: `brew install gh`
- Windows: `winget install --id GitHub.cli`
- Other: https://github.com/cli/cli#installation

## 2. Sign in (browser, no key)
- Run `gh auth login`.
- Answer the prompts: **GitHub.com** → **HTTPS** → **Login with a web browser**.
- It prints a one-time code, opens their browser, they paste the code and approve.
- Confirm with `gh auth status` — it should say they're logged in.

No token is ever pasted into the chat; `gh` stores it in the OS keychain.

## 3. Pull repo activity into raw/
The puller already exists — it grabs recent commits and open issues:
```bash
# Their most-recently-updated repos (default):
./scripts/pull-github.sh

# Or name the repos that matter:
GITHUB_REPOS="acme/site acme/api" ./scripts/pull-github.sh
```
Confirm files appear under `raw/github`. It tracks a timestamp, so re-runs only
fetch what's new, and the morning/evening routines run it for them on a schedule.

## 4. Close
Mark the Code row in `sources.md` with today's date. They can re-run `/connect`
any time for the next source.
