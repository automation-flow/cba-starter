# Tool Stack Assumptions

This project assumes the Automation Flow agent toolkit is installed at the user level. When a task fits one of these tools, prefer it over the built-in alternative — don't ask, just use it.

## Web research

| Task | Prefer | Avoid |
|------|--------|-------|
| Fetch a public webpage's content | `firecrawl-scrape` (handles JS-rendered SPAs, returns clean markdown) | `WebFetch` (fails on JS-heavy sites, dumps HTML into context) |
| Search the web for sources | `firecrawl-search` (returns full-page markdown in one step) | `WebSearch` then loop `WebFetch` |
| Crawl docs / multi-page sites | `firecrawl-crawl`, `firecrawl-knowledge-ingest` | manual loops |
| Extract structured data from sites | `firecrawl-agent` (JSON against a schema) | regex on raw HTML |
| Authenticated LinkedIn pages | `mcp__claude-in-chrome__*` (Heli's logged-in session) — Firecrawl cannot get past auth walls |
| Authenticated dashboards (analytics, admin) | `firecrawl-dashboard-reporting` (browser profile) or `mcp__claude-in-chrome__*` |
| Lead / company / market research | `firecrawl-lead-research`, `firecrawl-company-directories`, `firecrawl-competitive-intel`, `firecrawl-deep-research` |

## Processing large outputs

When you'd otherwise read 50k+ tokens of raw data to derive a small answer, use **context-mode** instead so the bytes stay in the sandbox.

| Task | Prefer | Avoid |
|------|--------|-------|
| Run 3+ shell commands then query their output | `ctx_batch_execute(commands, queries)` | sequential `Bash` calls |
| Filter / count / aggregate file contents | `ctx_execute_file(path, language, code)` | `Read` then mentally compute |
| Parse, transform, or summarize log/data | `ctx_execute(language, code)` | `Bash` piping into context |
| Fetch web pages for research (not for content you'll edit) | `ctx_fetch_and_index` or `firecrawl-scrape` | `WebFetch` |

**Exception:** When you're about to `Edit` a file, use `Read` — Edit needs the exact bytes in your conversation to match against.

## Memory & session recall

`claude-mem` auto-captures every session into a searchable knowledge base. `ctx_search(sort: "timeline")` reaches the same store plus indexed web fetches.

**At session start, before reading `CURRENT_STATUS.md` or asking the user for context:**
1. Run `mcp__plugin_claude-mem_mcp-search__timeline` for the last 7 days on this project
2. Run `ctx_search(sort: "timeline", source: "<project-slug>")` for prior decisions and errors
3. *Then* fall back to `CURRENT_STATUS.md` and git log to fill gaps

When the user references something from a past session ("the bug we hit", "the decision we made"), search memory first instead of asking them to re-explain.

## Document deliverables

| Task | Prefer |
|------|--------|
| Word doc (.docx) — final client deliverable | `document-skills:docx` |
| Markdown → .docx with track-changes-style suggestions | `document-skills:doc-coauthoring` (pairs with `docx`) |
| PDF parsing / extraction | `document-skills:pdf` |
| Spreadsheet generation | `document-skills:xlsx` |
| Slide deck | `document-skills:pptx` |
| Slack-bound GIFs | `document-skills:slack-gif-creator` |

For Automation Flow client-facing deliverables (proposals, profiles, reports), `.docx` is the rule — never ship markdown to the buyer.

## Behavioral defaults

- **Surface assumptions before coding.** If a request has multiple interpretations, present them — don't pick silently.
- **Simplicity first.** No abstractions for single-use code. No flexibility/configurability that wasn't requested. No error handling for impossible scenarios.
- **Surgical changes.** Touch only what the task requires. Don't refactor adjacent code or "improve" formatting.
- **Goal-driven execution.** Define a verifiable success criterion before starting multi-step work.

(These mirror the Andrej Karpathy guardrails — same rules, project-level enforcement so they apply even when the plugin isn't installed.)
