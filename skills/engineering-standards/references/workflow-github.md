# Reference: Engineering Workflow and Governance (GitHub)

> Pillar 1. Source: `prompts.txt` #1. Principle: **Issue first, PR driven.**
> No work starts without an Issue; no code reaches production without a PR.

## Canonical flow
`Issue -> Branch -> Commits (Conventional) -> PR (references the Issue) -> Review/Checks -> Merge -> Deploy`

## Issue taxonomy (label is mandatory)
| Category | Label | Branch | Commit |
|---|---|---|---|
| Fix (bug) | `type: fix` | `fix/<issue>-<slug>` | `fix:` |
| Improvement (refactor/perf/DX) | `type: improvement` | `refactor/<issue>-<slug>` | `refactor:`/`perf:`/`chore:` |
| New feature | `type: feature` | `feat/<issue>-<slug>` | `feat:` |

Supporting labels: `priority: p0..p3`, `area: <domain>`, `status: in-progress`.

## Issue template
```markdown
## Context
<problem/opportunity>
## Goal / Acceptance criteria
- [ ] <verifiable condition>
## Scope
- Includes: ... / Excludes: ...
## Technical notes
<files, risks, dependencies, screens>
```
```bash
gh issue create --title "feat: <summary>" --label "type: feature,priority: p2" --body-file .github/ISSUE_TEMPLATE/feature.md
```

## Commits and Branches
- **One branch per Issue**; name `<type>/<number>-<slug>`.
- **Conventional Commits** (`feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`, `ci`, `chore`)
  feed commitlint and semver/changelog. Use `Refs #N` in the body when useful.

## Pull Requests as the unit of deploy
- **Every description references the Issue** with a closing keyword: `Closes #N` / `Fixes #N` /
  `Resolves #N`.
- Small PR (under about 400 lines), 1 PR per Issue. Branch protection with checks: lint, types,
  tests, coverage, build.

Template `.github/pull_request_template.md`:
```markdown
## Summary
<what changes and why>
## Issue
Closes #<number>
## Type
- [ ] Fix  - [ ] Improvement  - [ ] New feature
## How to test
1. ...
## Checklist
- [ ] Follows the AI Engineering Standards
- [ ] Tests (unit/integration/e2e) updated
- [ ] Observability instrumented in new flows
- [ ] prefers-reduced-motion respected in new animations
- [ ] No lint/types/knip regression
```
```bash
gh pr create --fill --base main --title "feat: <summary>" --body "Closes #142

## Summary
..."
```

## Deploy and rollback
- Trunk based: `main` always deployable; **preview per PR**, then staging (optional), then
  production (merge).
- Rollback means reverting the PR (`git revert` / `gh pr revert`), never a hotfix straight to
  production without an Issue and a PR.

## Propagation (key rule)
> Make **AGENTS.md** the canonical, model-agnostic guide (read by Claude Code via a thin `CLAUDE.md`
> import, and by Codex/Cursor/Copilot directly). If it does not exist, create it; if it exists, merge
> without deleting.

Fastest path is the bundled scaffolder (safe, idempotent, never overwrites without `--force`):
```bash
bash "${CLAUDE_SKILL_DIR:-.}/scaffold.sh" .   # AGENTS.md + thin CLAUDE.md + .github governance + CI gate + safety deny-list
```

Or add the bootstrap block to `AGENTS.md` by hand:

```markdown
## AI Engineering Standards (mandatory)
1. Issue first, PR driven (every task is an Issue; every deploy is a PR that references the Issue). Conventional Commits.
2. UI: skeleton, lazy loading, enter/exit/loading/progress animations; prefers-reduced-motion; animate only transform/opacity.
3. Observability: OpenTelemetry to an OTLP Collector to any backend (Sentry/Datadog/New Relic).
4. Quality + Testing: the fmt -> lint -> typecheck -> arch -> deadcode -> test -> coverage -> build gate (bind verbs per stack; see stack-appendix).
5. Enforcement lives in CI + branch protection + hooks; the skill is advice.
```

CLAUDE.md then stays thin (single source of truth in AGENTS.md):
```markdown
See @AGENTS.md for the canonical project guide and the AI Engineering Standards.
```
