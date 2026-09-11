# Contributing

Thanks for improving the `engineering-standards` package.

## Workflow
- Open an Issue (Fix / Improvement / New feature) before non-trivial work.
- Branch `<type>/<issue>-<slug>`; use Conventional Commits; the PR references its Issue (`Closes #N`).

## Before you push
- `bash scripts/verify.sh` must pass (CI runs the same script).
- Write source files in English; no em dash or en dash in prose (hyphens and compounds are fine).
- Keep `SKILL.md` a lean router (under 500 lines); put detail in `references/` (one level deep; add a
  table of contents to any reference over 100 lines).
- Do not edit `docs/origin/` (provenance of the original config).

## Making changes
1. Edit the sources (`ai-engineering-standards.md`, the skill, the assets, the scripts).
2. `bash scripts/verify.sh`.
3. `bash install-skill.sh` to sync the local skill.
4. Bump `version` in `.claude-plugin/plugin.json` and in `skills/engineering-standards/SKILL.md`, then
   add a `CHANGELOG.md` entry.

## Scope of changes
- Keep the Pillar 3 core stack-agnostic; put tool-specific commands in `references/stack-appendix.md`.
- The skill is advice; mechanical enforcement belongs in CI, hooks, and branch protection.
