# Changelog

All notable changes to this project are documented here. Format follows Keep a Changelog; versioning
follows SemVer.

## [1.9.0]

### Added
- Two advisory, non-blocking hooks that nudge the standard during a session (fail-open, and quiet
  unless they have something to say):
  - `SessionStart` (`hooks/session-bootstrap.*`): in a git repo whose `AGENTS.md`/`CLAUDE.md` does not
    yet carry the Zeroth bootstrap, injects a one-line suggestion to run `/zeroth scaffold`. Silent
    once the bootstrap is present, and outside a project.
  - `PostToolUse` on Write/Edit/MultiEdit (`hooks/motion-nudge.*`): after a UI-file change, flags a
    small set of high-signal Pillar 2 anti-patterns (`transition: all`, `<div onClick>`) as an
    advisory that points to `/zeroth-review`. Silent on clean writes and non-UI files.
- `verify.sh` covers both hooks (flags the anti-patterns, stays silent otherwise, fail-open on bad
  input) and requires their files.
- Scaffolder now ships local git hooks: `skills/zeroth/assets/lefthook.yml` with a ready,
  language-agnostic Conventional Commits `commit-msg` check (no Node dependency) and a `pre-commit`
  section to bind the local gate per stack. `scaffold.sh` places it and prints `lefthook install`;
  `verify.sh` covers it.
- Scaffolded CI now pins every `actions/*` (and golangci) to a full commit SHA with a version comment,
  and the scaffolder ships a `.github/dependabot.yml` (weekly, grouped) so the pins stay current
  downstream. `verify.sh` proves the templates are SHA-pinned, and `SECURITY.md` reflects the posture
  (`dtolnay/rust-toolchain@stable` stays a channel ref).
- Scaffolder now ships a soft `pr-hygiene.yml` workflow (Pillar 1): it warns when a PR has no linked
  Issue, is over ~400 lines, or has a non-conventional title, and never blocks a merge. `SECURITY.md`
  adds an opt-in posture section (an OpenSSF Scorecard snippet, reviewdog, Allstar). `verify.sh` covers
  both.

## [1.8.0]

### Added
- `zeroth-reviewer` subagent (`agents/zeroth-reviewer.md`): a read-only reviewer that audits a change
  set (the working tree, a branch, or a PR) against the 4 pillars and returns a structured findings
  report. It is advisory (CI plus branch protection stay the authoritative gate) and cannot edit,
  stage, or commit (its tools are allowlisted to Read/Grep/Glob/Bash). It auto-delegates on "review my
  changes" style requests and is invocable as `zeroth:zeroth-reviewer`.
- `/zeroth-review` command: delegates to the reviewer for the working tree, a base branch, or a PR
  number, with a read-only inline fallback so it also works on a global-skill install. Added a `review`
  route to `/zeroth`, and `install-skill.sh` now installs subagents into `~/.claude/agents/`.
- `verify.sh` requires the reviewer agent and `/zeroth-review`, checks the agent frontmatter, and
  proves the reviewer is read-only (no Write/Edit in its tool allowlist).

## [1.7.1]

### Fixed
- Version consistency: the master spec `zeroth.md` still read `Version 1.1.0` while the plugin shipped
  at 1.7.0. Corrected it, and added a `verify.sh` guard that fails when `plugin.json`, `SKILL.md`, and
  `zeroth.md` disagree, so the drift cannot recur.
- Scaffolded CI no longer hardcodes Codecov as the coverage sink. The `coverage upload` step is now a
  commented, vendor-neutral placeholder (Codecov, Coveralls, SonarQube, or self-hosted) in
  `ci.node/python/go/jvm/dotnet.yml`, matching the spec's "pick any Cobertura/LCOV sink" rule and
  avoiding a broken gate on private repos that have no upload token.
- `ci.node.yml` now matches its sibling templates: added the missing `build` step and documented
  `arch` and `deadcode` as optional next steps.
- `ci.go.yml` `fmt` step is now a block scalar. As a plain scalar its inline `fix with:` made the file
  invalid YAML (`verify.sh` greps templates but never parsed them, so it went unnoticed).
- `evals/skill-activation` actually exercises activation now: the grader uses the documented
  `tool: Skill` + `input_match` schema (the old `tool_name: zeroth` was not a supported field), and
  `prompt.md` grants the `Skill` tool so the skill can fire in the eval sandbox.

## [1.7.0]

### Changed
- Observability is now an opt-in production practice, not a mandatory Pillar 3 item. The Pillar 3 CI
  gate (`fmt -> ... -> build`) is unchanged and still applies to every project, but OpenTelemetry,
  Sentry, and a coverage sink are no longer framed as required: a library, CLI, plugin, or
  pre-production app scaffolds with no demand to stand up an OTel Collector, and the coverage sink is
  pluggable (Codecov, Coveralls, SonarQube, self-hosted). Split
  `references/observability-quality-testing.md` into `quality-and-testing.md` (the gate, always) and
  `observability.md` (deployed apps, opt-in, tiered by maturity). Reframed the spec, `SKILL.md`,
  `stack-appendix.md`, `workflow-github.md`, the scaffolded `assets/AGENTS.md`, and the `/zeroth`
  command map. Pillar 3 keeps its name and the gate is unchanged.
- Streamlined both READMEs (EN and PT) into a shorter, beginner-friendly front door: what it is,
  how to install, the commands to run, the 4 pillars, and links out to the spec and per-domain
  references. Moved the branch-protection JSON, the repository tree, and the deeper how-tos into the
  files that already hold them, so a newcomer is not overwhelmed on the first screen.

## [1.6.0]

### Added
- Scaffolded CI now delivers a real gate for every stack the scaffolder detects. Added starter
  workflows `ci.go.yml`, `ci.rust.yml`, `ci.jvm.yml`, and `ci.dotnet.yml` (joining `ci.node.yml` and
  `ci.python.yml`), each binding the capability contracts to the stack's idiomatic tools
  (`fmt -> lint -> typecheck -> test -> coverage -> build`; typecheck folds into build on compiled
  languages). Previously Go/Rust/JVM/.NET fell back to the always-passing placeholder, so the
  scaffolder had to leave the required status check unset. Now those stacks produce a gate that runs,
  and the scaffolder requires the `verify` check for them.
- `scripts/verify.sh` proves each stack marker (`go.mod`, `Cargo.toml`, `pom.xml`, `*.csproj`) selects
  its stack template rather than the placeholder, and that a generic target still warns as before.
- Brand assets: `docs/logo.png` (wordmark), `docs/icon.png`, and `docs/favicon.ico`. The site favicon,
  Open Graph, and Twitter image now use the icon; the hero shows the wordmark on dark and the icon
  mark on light (the wordmark's text is light, so it is dark-surface only). Both READMEs show the
  wordmark in GitHub dark mode and the icon in light mode.

## [1.5.1]

### Fixed
- Secret-path guard (`hooks/guard_paths.py`) no longer blocks template files: `.env.example`,
  `.env.sample`, and any `*.example` / `*.sample` / `*.template` / `*.dist` path is allowed (these
  carry no real secret and exist to be committed). Real `.env` / `.env.local` still block.

### Added
- Secret-path guard now also covers `*.key`, `*.pfx`, `secret(s).yml|yaml|json`,
  `service-account*.json`, `.pypirc`, and more SSH key types (`id_dsa`, `id_ecdsa`, `id_ed25519`).
  New behavior is covered by `scripts/verify.sh` hook tests.

## [1.5.0]

### Changed
- Renamed the project to **Zeroth**. The plugin id is now `zeroth` (install with
  `/plugin install zeroth`), the skill lives at `skills/zeroth/`, the slash command is `/zeroth`, the
  spec is `zeroth.md`, and the repository is `DouglasVulcano/zeroth-ai` (site at
  `douglasvulcano.github.io/zeroth-ai/`). Update any marketplace add to `DouglasVulcano/zeroth-ai`.
  Existing installs should reinstall under the new name (/plugin install zeroth).

## [1.4.0]

### Added
- Scaffolder branch-protection guidance is now ruleset-aware. It prints both the classic
  branch-protection command and a **Ruleset** command (`POST /repos/{o}/{r}/rulesets`), and a new
  `--ruleset` flag makes `--protect` create a ruleset instead of classic protection. Both paths warn
  that `enforce_admins` is not a status-check context (it is the `enforce_admins` field in the classic
  API and the `bypass_actors` list in a ruleset). SECURITY.md documents the ruleset equivalent. This
  closes the gap where hand-adapting the classic JSON into a ruleset could hang a PR at
  "Expected - Waiting for status to be reported".

## [1.3.2]

### Security
- Pinned the repo's own CI action (`actions/checkout`) to a full commit SHA with a version comment,
  and added `.github/dependabot.yml` (grouped, weekly) to keep it current. SECURITY.md now states the
  posture accurately: this repo pins to SHA; scaffolded templates default to major-version tags
  (which receive patches) and can be pinned for the strictest posture.

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
  (`cd zeroth` should be `cd zeroth-ai`), in README (EN and PT-BR).
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
- Governance scaffolder (`skills/zeroth/scaffold.sh` + `assets/`): issue/PR templates,
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
- Initial `zeroth` skill (4 pillars), the master spec, the installer, the `/zeroth`
  command, and the self-check.
