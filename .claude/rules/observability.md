## Observability

> Synced from `_shared/common/rules/`. Edit there, not in a project copy.

- Log one structured JSON line per event via `.claude/lib/logger.mjs`
  (timestamp, level, scope, message, context). Greppable, not prose in console noise.
- Never swallow an error silently. Log it with context, then handle or re-throw.
- Agent runs log tokens in and out, so cost is visible per agent.

### A green run that produced nothing is a lie until it proves otherwise

A scheduled job that finishes `ok` having delivered **zero** output is indistinguishable
from a legitimately quiet day — both look identical to a dashboard. That ambiguity hid a
**four-day dead daily push** (2026-07-13→16) behind a green console.

- **Record what the run had to work with**, not just what it produced. Write a durable
  row/event carrying the input count (`candidates_total`) and the reason for the empty
  result. Zero-in / zero-out is honest; N-in / zero-out is a fault.
- **Alert on `status='ok' AND inputs > 0 AND delivered = 0`.** A status field alone can
  never express this — the alert needs the input count to tell "quiet" from "broken".
- **Log the per-item skip, not just the batch total.** If a loop skips every item via
  `continue`, emit one line per skip with the reason. A batch that silently drops N items
  and reports success leaves nothing to debug.
- Run **duration** is a free tripwire: a job that normally takes ~400ms and suddenly takes
  52s while reporting success is doing something expensive and futile (e.g. retrying a
  dead provider once per item).

### A skip is not a success — and a skip that writes no row is invisible (promoted 2026-07-17 from seal-security-v2)

The rule above assumes there is a run row to alert on. **The common case is that there isn't.**
An early-return guard — no API token, empty roster, feature flag off, brake engaged, nothing
eligible — typically returns `ok=True` and writes **nothing at all**. The console then renders
"Ran fine just now" beside a *stale* last-run timestamp, and the zero-output alert never fires
because there is no row to match. One audit found **eleven** such skip paths in a single
scheduler.

- **Every early return writes a durable outcome with a reason.** Model it as three states —
  `ok` / `skipped(reason)` / `error` — never two. `skipped` is the state most systems omit,
  and it is the one that hides the outage.
- **A boolean `ok` cannot carry a reason.** If the return type has no field for *why* zero
  happened, the reason is discarded at the boundary and no downstream alert can ever recover
  it. Fix the type, not the alert.
- **Grep every structured field you emit for a consumer.** A `blocked_reasons` /
  `skipped_items` field that is constructed and never read is worse than absent — the code
  and its comments claim coverage that does not exist. Same for an alert key that is emitted
  and never queried.
- **"N jobs · N on schedule" must not be computed as `total - paused`.** That counts a job
  failing every fire, and a job that has never run, as healthy. Never-run renders as
  "Never run", never as blank.
- **On-page alerting is not monitoring.** A strip that polls while a tab is open detects
  nothing at 07:30. If the scheduled run *is* the product, ship one off-page channel (webhook
  → Slack/email) before calling it production.
