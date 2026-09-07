## Debugging Approach

When debugging issues:
1. Trace the full execution path from input to output
2. Check for: data transformation errors, state issues, output formatting
3. Provide deep root-cause analysis, not surface-level inspection
4. After proposing a fix, verify it handles ALL similar cases

### Read the error BODY, never the exception class (promoted 2026-07-17 from seal-security-v2)

An exception's *class* and HTTP *status* routinely misname the real cause. Logs that
record only `BadRequestError` or `429` send you to debug the wrong system. Make **one live
call with the real credential and print the response body** — it usually ends the
investigation in a single step.

**LLM provider billing failures are the canonical trap:**

| Symptom | Actually means |
|---|---|
| Anthropic **400** `invalid_request_error`, body says *"credit balance is too low"* | **Out of credit.** Not a malformed request. |
| Anthropic **404** | Invalid/retired **model id** |
| Anthropic **401** | Bad API key |
| OpenAI **429** with body `code: "insufficient_quota"` | **Out of credit.** NOT rate-limiting — backing off and retrying never succeeds. |
| OpenAI **429** without that code | Genuine rate limit; back off |

A dry account therefore surfaces as a `400` on one provider and a `429` on the other —
neither looks like billing. Never conclude "billing" or "bug" from the status alone; and
never conclude billing is the *whole* cause without proving the code delivers once funded.

### Fatal must outrank failover

A fallback/retry wrapper must not downgrade a **fatal** error into a retryable one. Fatal =
a property of the **account** (billing, auth, quota) — every subsequent call fails
identically. Retryable = a property of the **call** (rate limit, 5xx, transport).

Classify the primary's failure **before** failing over. A wrapper that catches the
primary's fatal error, fails over, and then surfaces only the secondary's error destroys
the classification: callers see something retryable, skip the item, and the batch reports
success having done nothing. This exact shape silently skipped every lead of a production
batch while the run stayed green.

### A `--dry-run` that short-circuits cannot rehearse the failure

If dry-run returns before the expensive step (the LLM call, the API write), it does not
exercise the code path that breaks in production. Never accept a green dry-run as evidence
that the real run works — verify against the path that actually executes.
