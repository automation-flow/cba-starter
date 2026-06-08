#!/bin/bash
# auto-ingest.sh — the Brain step, unattended.
#
# Turns new data in raw/ into linked wiki pages by running your AI coding agent
# headless (Claude Code, or Codex as a fallback). evening-routine.sh calls this
# after the pull and before the lint + push, so the schedule actually completes
# the Capture -> Brain -> Act loop instead of leaving raw data sitting un-ingested.
#
# FAILS SOFT by design: if no agent is installed, or it isn't logged in for
# non-interactive use, this logs a clear message and exits 0 so the surrounding
# routine (lint + backup push) still runs. You can always open Claude Code and
# run /daily by hand instead.
#
# Auth note: the agent must be usable non-interactively — an existing logged-in
# Claude Code session, or ANTHROPIC_API_KEY in the environment. On a fresh
# machine with no auth, this step is skipped, not fatal.
set -uo pipefail

KB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KB_ROOT"

ts()  { date "+%Y-%m-%d %H:%M:%S"; }
log() { echo "[$(ts)] auto-ingest: $*"; }

# launchd/cron start with a minimal PATH that misses common install dirs. Add the
# usual ones so the agent binary is found (official installer -> ~/.local/bin,
# Homebrew -> /opt/homebrew/bin).
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

# Cap the run so a hung agent can't wedge the routine forever (20 min). macOS
# ships no `timeout`/`gtimeout`, so fall back to running uncapped. NB: a bare
# empty-array expansion "${RUN[@]}" is an "unbound variable" error under `set -u`
# on bash 3.2 (the macOS default), so wrap the optional timeout in a function.
TIMEOUT_BIN=""
if   command -v timeout  >/dev/null 2>&1; then TIMEOUT_BIN="timeout"
elif command -v gtimeout >/dev/null 2>&1; then TIMEOUT_BIN="gtimeout"
fi
run_agent() {  # run the agent, wrapped in a 20-min timeout if one is available
    if [[ -n "$TIMEOUT_BIN" ]]; then "$TIMEOUT_BIN" 1200 "$@"; else "$@"; fi
}

# Same instruction whichever agent runs it.
read -r -d '' PROMPT <<'EOF' || true
Run the daily Brain update for this knowledge base, non-interactively, following CLAUDE.md (or AGENTS.md).

1. Ingest every new or changed file in raw/ into the wiki: create or update the right pages, cross-link every person/client/project as a [[wikilink]], set frontmatter, and list the raw sources used.
2. Update wiki/index.md and append a dated entry to wiki/log.md describing what changed.
3. Refresh wiki/overview.md and wiki/hot.md if the overall picture changed.

Only edit files under wiki/ — do not touch scripts, config, CLAUDE.md, .env, .mcp.json, or anything outside wiki/.
Never copy secrets, credentials, API keys, tokens, passwords, or private keys into a wiki page; if a raw file contains one, write [REDACTED] instead.

Do NOT run pull scripts (data is already pulled this run). Do NOT git commit or push (the routine handles that). If raw/ has nothing new since the last ingest, say so and change nothing.
EOF

# Protect gitignored secret files the agent must never modify. The post-run
# revert below only covers TRACKED files, so back these two up and restore them
# verbatim no matter how the run ends.
PROTECT_BAK="$(mktemp -d 2>/dev/null || echo /tmp/ai-protect-$$)"
mkdir -p "$PROTECT_BAK"
for f in .env .mcp.json; do
    [[ -f "$f" ]] && cp -p "$f" "$PROTECT_BAK/$f" 2>/dev/null || true
done
restore_protected() {
    for f in .env .mcp.json; do
        [[ -f "$PROTECT_BAK/$f" ]] && cp -p "$PROTECT_BAK/$f" "$f" 2>/dev/null || true
    done
    rm -rf "$PROTECT_BAK"
}
trap restore_protected EXIT

# Prefer Claude Code; fall back to Codex. Both run the same prompt headless.
ran_ok=false
if command -v claude >/dev/null 2>&1; then
    log "ingesting via Claude Code ($(command -v claude)) ..."
    # acceptEdits auto-approves file writes; allowedTools scopes the rest. The
    # routine (not the agent) does the push, and the guard below reverts any
    # stray edits the agent makes outside wiki/.
    if run_agent claude -p "$PROMPT" \
            --permission-mode acceptEdits \
            --allowedTools "Read" "Edit" "Write" "Glob" "Grep" "Bash(git status:*)" "Bash(git diff:*)" \
            2>&1; then
        ran_ok=true
    else
        log "Claude run failed (most often: not logged in for headless use)."
    fi
elif command -v codex >/dev/null 2>&1; then
    # Codex path: `codex exec` runs non-interactively; --sandbox workspace-write
    # lets it edit files in this folder without prompting. The same post-run
    # wiki-only revert + secret scan apply to whatever it changes.
    log "ingesting via Codex ($(command -v codex)) ..."
    if run_agent codex exec --sandbox workspace-write -C "$KB_ROOT" "$PROMPT" 2>&1; then
        ran_ok=true
    else
        log "Codex run failed (most often: not logged in for headless use)."
    fi
else
    log "no AI agent on PATH (looked for 'claude' and 'codex') — skipping. Open Claude Code and run /daily to ingest by hand."
    exit 0
fi

if [[ "$ran_ok" != true ]]; then
    log "ingest skipped — open Claude Code and run /daily (or 'codex exec') by hand instead."
    exit 0
fi

# Safety net: ingest must only touch wiki/. Revert any tracked changes the agent
# made outside it (scripts, config, CLAUDE.md, ...) so they can never be pushed.
# NUL-delimited so filenames with spaces/globs are handled correctly.
if git diff --name-only -- . ':(exclude)wiki/' | grep -q .; then
    log "agent edited tracked files outside wiki/ — reverting them (ingest writes wiki/ only):"
    git diff --name-only -- . ':(exclude)wiki/' | sed 's/^/    /'
    git diff --name-only -z -- . ':(exclude)wiki/' | xargs -0 git checkout -- 2>/dev/null || true
fi

log "done."
exit 0
