# Changelog

All notable changes to this project are documented here. Format follows Keep a Changelog; versioning
follows SemVer.

## [1.3.1]

### Added
- README (EN and PT-BR): a single "golden path" quickstart (scaffold, fill AGENTS.md, set
  CODEOWNERS, arm branch protection) plus a "this repo runs on its own standard" note pointing to
  the end-to-end fixtures. The branch-protection step flags the Ruleset gotcha (`enforce_admins` is
  not a status-check context).

## [1.3.0]

### Added
- Scaffolder now arms the authoritative gate. `scaffold.sh` prints a branch-protection command
  (`gh api ... /branches/<branch>/protection`) personalized from the target's `origin` remote and
  default branch, and an opt-in `--protect` flag applies it (needs gh + a repo-admin token; honors
  `--dry-run`, confirms on a TTY). It also warns when the generated `verify.yml` is the generic
  placeholder, so you do not require a status check that verifies nothing.
- `scripts/verify.sh` covers the new scaffolder output (branch-protection guidance; `--protect`
  respects `--dry-run`).

## [1.2.2]

### Fixed
- Quickstart: the global-skill install snippet referenced the wrong directory after `git clone`
  (`cd ai-engineering-standards` should be `cd ai_engineering_standards`), in README (EN and PT-BR).
- CHANGELOG accuracy: the v1.2.0 note overstated eval automation. CI validates the eval-suite
  structure via `verify.sh`; the evals themselves run manually (`claude plugin eval`).

## [1.2.1]

### Security
- Hardened the Bash guard: it now also catches shell-wrapper evasion (`bash -c`, `sh -c`, `eval`),
  piping a download into a shell (`curl ... | sh`), and writing to secret files via redirection
  (`> .env`, `id_rsa`, `*.pem`, `.git-credentials`, `.npmrc`). Still fail-open, still a guardrail and
  not a sandbox.
- Scaffolded Node CI installs with `--ignore-scripts`; both CI templates document version and action
  SHA pinning.
- Added `.github/CODEOWNERS` and a "Threat model and trust boundary" plus "Repository hardening"
  section to SECURITY.md (branch protection, required Code Owner review, tagged releases).

## [1.2.0]

### Added
- Hooks bundle (`hooks/`): conservative, fail-open `PreToolUse` guards that block clearly destructive
  Bash (`rm -rf /`, `git push --force`, fork bomb, `dd` to a device) and edits to secrets/credentials
  files. Active when the plugin is enabled; complements the settings deny-list and CI.
- Eval suite (`evals/`) for `claude plugin eval` with a with/without control arm: skill activation,
  greenfield scaffold artifacts, and AGENTS.md repo-specificity. Its structure is validated in CI by
  `verify.sh`; the evals themselves run manually (`claude plugin eval`).
- `scripts/verify.sh` now checks the hooks (JSON, shell/Python syntax, block/allow behavior) and the
  eval-suite structure.

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
