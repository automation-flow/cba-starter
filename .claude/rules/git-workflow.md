## Git Workflow

- **Never commit directly to `main`** — always create a feature branch first
- Branch naming: `feat/<description>`, `fix/<description>`, or `chore/<description>`
- When starting work on a task, create a branch before making any changes
- When the work is complete, open a PR to `main` for review
- Include a clear PR title and summary of changes
- Do not merge the PR yourself — leave it for review unless explicitly told otherwise

### CI & merge-train gotchas (promoted 2026-07-17 from seal-security-v2)

- **`gh pr merge --auto` merges IMMEDIATELY on repos without branch protection** — there is nothing to queue behind. Sequence explicitly: `gh run watch <run-id> --exit-status` (or `gh pr checks <n> --watch`) FIRST, then `gh pr merge --squash`. And read `mergeStateStatus` — `mergeable: MERGEABLE` only means "no conflicts"; `UNSTABLE` means checks are pending or failing.
- **A FAILED verdict from watch tooling is not proof the run failed.** `gh run watch` / `gh pr checks --watch` exit non-zero on transient GitHub API 503s. Before acting on a "failure", re-verify the run's actual state: `gh run view <id> --json status,conclusion`.
- **Job-timeout kills masquerade as test failures.** When CI goes red, read the run *annotations* before debugging tests — "exceeded the maximum execution time" means the suite outgrew `timeout-minutes`. Common after a merge train: each PR's run fits the budget, the combined main run doesn't.
- **A freshly-published CVE against a pinned dependency fails EVERY open PR at once** (pip-audit / npm audit run per-PR). Don't debug the PRs. Fix once: for a uv-managed transitive pin, add `[tool.uv] constraint-dependencies = ["pkg>=fixed-version"]` to pyproject.toml + `uv lock`. Merge that first, then `gh pr update-branch <n>` on each open PR so its checks re-run against fixed main.
- **Merging a stacked PR with `--delete-branch` closes its child, permanently** (promoted 2026-08-27 from the website repo). When PR B is based on PR A's branch, `gh pr merge A --squash --delete-branch` closes B the moment the base branch disappears, and GitHub refuses to reopen or retarget a closed PR whose base branch is gone: `Cannot change the base branch of a closed pull request`. Nothing recovers B itself. Recovery is `git rebase --onto origin/main <A's-tip-sha> <B's-branch>` — which replays only B's own commits and sidesteps the conflict that a plain rebase hits after A was squashed — then open a fresh PR and comment the supersede on the closed one. Avoid it by merging the child first, or by merging the parent WITHOUT `--delete-branch` and cleaning up after the child lands.
- **Parallel agents/worktrees: always branch from `origin/main`**, never from the local checkout — concurrent sessions move it. Before landing a branch another session owns, check its worktree for uncommitted changes (`git -C <worktree> status --porcelain`); dirty = live session, do not touch it.
