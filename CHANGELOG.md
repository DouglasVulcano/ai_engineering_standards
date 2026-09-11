# Changelog

All notable changes to this project are documented here. Format follows Keep a Changelog; versioning
follows SemVer.

## [1.1.0]

### Added
- Claude Code plugin packaging (`.claude-plugin/plugin.json` + `marketplace.json`) for versioned team
  distribution alongside the global-skill installer.
- Governance scaffolder (`skills/engineering-standards/scaffold.sh` + `assets/`): issue/PR templates,
  CODEOWNERS, a stack-aware CI gate, AGENTS.md (canonical) + a thin CLAUDE.md, and a `.claude`
  safety deny-list. Safe by design (no overwrite without `--force`) and idempotent, with `--dry-run`.
- Stack-agnostic Pillar 3: a capability-contract gate
  (`fmt`/`lint`/`typecheck`/`arch`/`deadcode`/`test`/`coverage`/`build`) plus a per-stack appendix
  (`references/stack-appendix.md`) for JS/TS, Python, Go, Rust, JVM, .NET.
- MCP governance checklist in the arsenal reference.
- Professional root files: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `SECURITY.md`, this changelog.
- `docs/research-and-benchmarks.md`: research synthesis (with sources) plus the self-benchmark.
- Scaffolder `--with-plugin OWNER/REPO`: writes a project `.claude/settings.json`
  (`extraKnownMarketplaces` + `enabledPlugins`) so the plugin auto-enables for everyone who trusts the
  repo (safe JSON merge with the deny-list).
- Dedicated `scaffold` command and robust scaffolder path resolution
  (`${CLAUDE_SKILL_DIR}` then `${CLAUDE_PLUGIN_ROOT}`) so it works whether installed as a skill or a
  plugin; `install-skill.sh` now installs all `commands/*.md`.

### Changed
- Propagation now targets `AGENTS.md` (canonical, model-agnostic) with a thin `CLAUDE.md` that imports
  it, so the standard applies to Codex/Cursor/Copilot as well as Claude Code.
- `install-skill.sh` bundles the whole skill payload (skill + scaffolder + assets); `scripts/verify.sh`
  adds JSON and plugin-manifest checks plus a scaffolder smoke test.

### Fixed
- CI actions bumped to Node 24 runtimes (`actions/checkout@v5`, `actions/setup-python@v6`,
  `actions/setup-node@v5`, `codecov/codecov-action@v5`) to clear the Node 20 deprecation warning, in
  the repo workflow and in the scaffolded CI templates.

## [1.0.0]

### Added
- Initial `engineering-standards` skill (4 pillars), the master spec, the installer, the `/standards`
  command, and the self-check.
