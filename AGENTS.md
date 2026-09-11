# AGENTS.md

> Canonical, model-agnostic guide for agents working on THIS repository (the `engineering-standards`
> plugin/skill). Read by Claude Code via the CLAUDE.md import, and by Codex/Cursor/Copilot directly.

## Project
A distributable Claude Code plugin/skill that carries a stack-agnostic engineering standard plus a
governance scaffolder. Content is Markdown and Bash; there is no application runtime.

## Layout
- `skills/engineering-standards/` the skill: `SKILL.md` router + `references/` + `scaffold.sh` + `assets/`
- `commands/standards.md` the `/standards` slash command
- `.claude-plugin/` `plugin.json` + `marketplace.json`
- `ai-engineering-standards.md` the full readable spec (bundled into the skill at install)
- `install-skill.sh` global-skill installer; `scripts/verify.sh` the self-check
- `docs/origin/` provenance (do not edit); `docs/research-and-benchmarks.md` research + self-benchmark

## Commands (gate verbs for this repo)
- verify (lint/test): `bash scripts/verify.sh` (files, shell syntax, JSON validity, no em/en dashes,
  description length, installer + scaffolder smoke tests)
- install locally: `CLAUDE_DIR=./.tmp bash install-skill.sh`
- scaffold (manual test): `bash skills/engineering-standards/scaffold.sh <target> --dry-run`
There is no separate build/test toolchain (this is a Markdown and Bash repo); `verify.sh` is the gate.

## Conventions
- Issue-first, PR-driven; Conventional Commits; every PR references its Issue (`Closes #N`).
- Source files are in English; no em dash or en dash in prose (hyphens and compounds are fine).
- Author: DouglasVulcano. Keep `docs/origin/` untouched (provenance).
- After editing the skill: run `bash scripts/verify.sh`, then `bash install-skill.sh` to sync the
  local skill; bump `version` in `.claude-plugin/plugin.json` and `SKILL.md`, and add a CHANGELOG entry.

## AI Engineering Standards (this repo dogfoods them)
Issue-first/PR-driven workflow; the `fmt -> ... -> build` gate is instantiated here as
`scripts/verify.sh` and enforced by CI (`.github/workflows/verify.yml`). Full spec:
`ai-engineering-standards.md`.
