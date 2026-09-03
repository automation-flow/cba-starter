## Configuration Philosophy

- **Config over code**: behavior driven by configuration files, not hardcoded per-type logic
- **Modular architecture**: small focused sub-workflows, each doing one thing well
- **Production-grade from day one**: error handling, logging, monitoring

### The safe mode is the default, not an override (promoted 2026-07-17 from seal-security-v2)

If production is only correct because someone set a runtime override, then production is one
click, one "reset to default", or one dropped row away from silently reverting to the unsafe
mode. The override row is not a decision — it is a **sticky note on a loaded gun**.

Found live: the correct delivery mode was held up by a single mutable DB row, while the code
default underneath it was still the mode that had already caused a zero-delivery incident.

- **Once a mode is chosen, change the default and delete the chooser.** Leaving the old
  default plus a UI selector means the revert path stays reachable forever.
- **If a value must not be operator-reachable, remove it from the write allow-list**, so a
  write is rejected outright rather than merely un-rendered. An un-rendered knob that the API
  still accepts is a footgun with the safety filed off.
- **Keep the abandoned branch as a documented break-glass** (config-file-only + redeploy), not
  as a live control. Say so in a comment at the definition, or someone will delete the branch.
- **"Empty means default" is almost always false.** Storing `null` and having a reader do
  `if value is not None:` means empty takes the *else* branch — frequently "unlimited". Check
  what the reader actually does before writing that helper text, and make absent-vs-null
  render differently in any UI.
- **Interlocked knobs must state their master.** A field that is inert unless another flag is
  on has to say so *in the UI*, not only in a code comment. Otherwise an operator tunes it and
  correctly concludes the system is broken.
