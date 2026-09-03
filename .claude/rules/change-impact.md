## Change Impact Awareness

Before any change, identify its scope:
- **Project-specific config only?** Test that project.
- **Shared code/logic?** Test across affected projects.
- **Agency-wide rule change?** Propagate to all projects via `scripts/sync-shared.sh`.
- Never let a fix for one project break another.

### Audit the read side — a control nothing reads is a decoration (promoted 2026-07-17 from seal-security-v2)

When reviewing or changing any control surface — admin panel, feature flag, config knob,
workflow toggle — the write path proves nothing. **Trace UI → API → persistence → the code
that READS the value**, and grep the field name across the whole codebase for consumers.

A single review found **five** toggles whose write path was flawless, fully tested, and wired
to nothing. One rendered `OFF` for a gate that was hardcoded `ON` and running at 100% — it
displayed the exact inverse of live state. Write-path tests pass on a placebo; only the read
side tells the truth.

- **Grep for the reader before believing the label.** No consumer = the control is decorative,
  and the UI is asserting something false. Delete it or wire it — never ship it.
- **Beware the inverted safety story.** Placebo toggles tend to be the ones labelled
  scary/`danger`, while the one knob with real teeth ships with no confirm step. Rank guards
  by measured blast radius, not by how the label reads.
- **Check that the *live lane* reads it, not just *some* lane.** A value honoured at
  pre-delivery recheck but ignored during selection burns real work (LLM spend, API quota) on
  items that are then silently dropped. Retired lanes reading it correctly is not coverage.
- **A registered-but-unrendered knob is still writable** via the API allow-list. Removing the
  UI does not remove the control.

### Confirm what production actually runs before trusting any finding

Tools, subagents, and greps read the **working tree** — which may be an unmerged branch, and
therefore not what production runs. Diff against `origin/main` *and* check the deployed commit
on the box before reporting. Two findings in one review were wrong for exactly this reason:
the branch had already fixed what prod still shipped.
