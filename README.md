<p align="center">
  <img src="docs/logo.svg" alt="Zeroth" width="96" height="96">
</p>

<h1 align="center">Zeroth</h1>

<p align="center">
  <a href="https://douglasvulcano.github.io/zeroth-ai/"><b>Website</b></a> · <b>English</b> · <a href="README.pt-BR.md">Português</a>
</p>

> A single, stack-agnostic engineering standard for AI agents, packaged as a **Claude Code plugin and
> skill**, with a **governance scaffolder**. One source of truth, applied consistently by any agent of
> any model, on any project, in any language.

![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin%20%2B%20skill-6C4BF6)
![Agnostic](https://img.shields.io/badge/stack-agnostic-success)
![Scope](https://img.shields.io/badge/scope-global%20%7C%20project%20%7C%20team-informational)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## What it is

A distributable standard that turns loose AI configuration into a **formal, versioned, installable**
package. It delivers:

1. **`zeroth.md`** the complete, readable specification (single source of truth).
2. **The `zeroth` skill** the same knowledge with progressive disclosure (loads only
   the domain relevant to the task) plus a bundled **scaffolder** and governance **assets**.
3. **Plugin packaging** (`.claude-plugin/`) for versioned team distribution, and **`install-skill.sh`**
   for a global personal install.

Goal: when any AI agent starts, plans, or reviews work, it applies the same standard for workflow,
UI, observability, quality, and testing, and can scaffold the governance to enforce it.

## Quickstart: the golden path

The standard pays off when the whole path is in place, not just the skill. From zero to enforced
governance:

**1. Scaffold governance** (issue/PR templates, CODEOWNERS, a CI gate, `AGENTS.md` + a thin
`CLAUDE.md`, a `.claude` safety deny-list). Preview, then apply:

```bash
bash skills/zeroth/scaffold.sh /path/to/repo --dry-run
bash skills/zeroth/scaffold.sh /path/to/repo
```

**2. Fill `AGENTS.md`** with your stack and its gate commands (see the stack appendix), and **3. set
real owners** in `.github/CODEOWNERS` (the two things the scaffolder cannot guess).

**4. Arm branch protection** on your default branch, the authoritative gate. Re-run the scaffolder
with `--protect`, or apply it yourself (classic branch-protection API):

```bash
gh api -X PUT repos/OWNER/REPO/branches/main/protection --input - <<'JSON'
{ "required_pull_request_reviews": { "required_approving_review_count": 1, "require_code_owner_reviews": true },
  "required_status_checks": { "strict": true, "contexts": ["verify"] },
  "enforce_admins": true, "restrictions": null }
JSON
```

> Using a **Ruleset** (GitHub's newer model)? The shape differs: `enforce_admins` is not a status
> check (it maps to the bypass list), and the required check `contexts` is the job name (here
> `verify`). Do not drop the classic fields into a ruleset's status-check list, or the merge box
> hangs at "Expected - Waiting for status to be reported".

The skill is advice; **CI plus branch protection are what enforce it**. The skill alone is the least
return; the scaffolder plus a filled `AGENTS.md` plus an armed gate is where the value is.

> **This repo runs on its own standard:** its `AGENTS.md`, `.github/workflows/verify.yml`, and the
> ruleset on `main` (requiring the `verify` check plus review) are the same setup the scaffolder
> produces. It is a living reference; see [`docs/research-and-benchmarks.md`](docs/research-and-benchmarks.md)
> for the greenfield/brownfield fixtures verified end to end.

## The 4 pillars

| # | Pillar | Summary |
|---|---|---|
| 1 | **Workflow and Governance** | Issue-first, PR-driven. Every task is an **Issue**; every deploy is a **PR that references it** (`Closes #N`). Conventional Commits. Feeds **AGENTS.md** (canonical) with a thin **CLAUDE.md** import. |
| 2 | **Motion and UI/UX** | Skeleton, lazy loading, enter/exit/loading/progress animations; `prefers-reduced-motion`; animate only `transform`/`opacity`. Frequency Gate + Web Interface Guidelines. |
| 3 | **Observability, Quality, Testing (stack-agnostic)** | OpenTelemetry to an OTLP Collector to any backend; a capability-contract gate (`fmt, lint, typecheck, arch, deadcode, test, coverage, build`); Testcontainers + Playwright + Codecov. Per-stack commands in the appendix. |
| 4 | **Arsenal (MCP and Skills)** | The right tool per task: shadcn-ui-mcp, 21st.dev Magic, chrome-devtools-mcp, design-motion-principles, web-design-guidelines, humanizer. |

## Repository structure

```
.
├── README.md / README.pt-BR.md        # docs (EN / PT)
├── AGENTS.md / CLAUDE.md              # this repo's own guide (canonical + thin import)
├── CONTRIBUTING.md / CHANGELOG.md / SECURITY.md / LICENSE
├── zeroth.md        # the complete specification (single source of truth)
├── install-skill.sh                   # global-skill installer (+ /zeroth command)
├── .claude-plugin/                    # plugin.json + marketplace.json (team distribution)
├── commands/zeroth.md              # the /zeroth slash command
├── scripts/verify.sh                  # repo self-check (dogfoods pillar 3)
├── hooks/                             # plugin PreToolUse guards (block destructive Bash / secret edits)
├── evals/                             # claude plugin eval suite (with/without control arm)
├── skills/zeroth/       # the skill (payload that gets installed)
│   ├── SKILL.md                       # lean router (triggers on its own)
│   ├── references/                    # per-domain deep dives (loaded on demand)
│   │   ├── workflow-github.md · motion-and-ui.md
│   │   ├── observability-quality-testing.md · stack-appendix.md
│   │   └── arsenal-mcp-skills.md
│   ├── scaffold.sh                    # governance scaffolder (safe, idempotent)
│   └── assets/                        # issue/PR templates, CODEOWNERS, CI gate, AGENTS/CLAUDE, settings
├── .github/workflows/verify.yml       # CI self-check
└── docs/                              # origin/ (provenance) + research-and-benchmarks.md
```

## Install

**Plugin (recommended for teams; versioned, no drift):**
```text
/plugin marketplace add DouglasVulcano/zeroth-ai
/plugin install zeroth
```
Update later with `claude plugin update`.

**Global skill (personal):**
```bash
git clone https://github.com/DouglasVulcano/zeroth-ai.git
cd zeroth-ai
bash install-skill.sh
```
The installer is idempotent and location-independent; it copies the skill (with the scaffolder and
assets) into `~/.claude/skills/` and registers `/zeroth`. Per-project scope:
`CLAUDE_DIR=./.claude bash install-skill.sh`.

**Team / project-wide (auto-enable for everyone).** Commit a `.claude/settings.json` so anyone who
trusts the repo gets the plugin automatically, with no manual steps:
```json
{
  "extraKnownMarketplaces": {
    "zeroth-ai": { "source": { "source": "github", "repo": "DouglasVulcano/zeroth-ai" } }
  },
  "enabledPlugins": { "zeroth@zeroth-ai": true }
}
```
The scaffolder writes this for you:
`scaffold.sh <repo> --with-plugin DouglasVulcano/zeroth-ai`.

## Use

- **Automatic**: the skill triggers when your request matches ("create the issue/PR", "review the
  UI", "set up observability", "follow the standards").
- **Explicit**: `/zeroth` (everything) or `/zeroth ui | workflow | o11y | testing | arsenal |
  scaffold`.

## Scaffold governance into a repo

The highest-leverage feature. It creates issue/PR templates, `CODEOWNERS`, a stack-aware CI gate,
**AGENTS.md** (canonical) + a thin **CLAUDE.md**, and a `.claude/settings.json` safety deny-list.
It **detects your stack**, is **idempotent**, and **never overwrites** a file without `--force`.

```bash
# preview, then apply (path defaults to the current directory)
bash skills/zeroth/scaffold.sh /path/to/repo --dry-run
bash skills/zeroth/scaffold.sh /path/to/repo
```
Add `--with-plugin OWNER/REPO` to also wire the project's `.claude/settings.json` so the plugin
auto-enables for the whole team. After installing globally, the same script lives at
`~/.claude/skills/zeroth/scaffold.sh`. Then fill `AGENTS.md` with your stack's gate
commands (see the stack appendix) and set real owners in `.github/CODEOWNERS`.

## Stack-agnostic by design

Pillar 3 is a set of **capability contracts** (the 8 verbs), not a fixed toolset. The exact command
per verb for JS/TS, Python, Go, Rust, JVM, and .NET lives in
`skills/zeroth/references/stack-appendix.md`. The original JS/TS toolset (Biome, Knip,
Stryker, Playwright, Codecov) is simply one column of that appendix.

## Install on another machine or another Claude

- **Claude Code**: install the plugin, or clone and run `install-skill.sh`. Update with
  `git pull && bash install-skill.sh`.
- **Claude Desktop / claude.ai (web)**: upload the `skills/zeroth/` folder through the
  Skills UI (the `/zeroth` command is Claude Code only).
- MCP servers with API keys (21st.dev, shadcn, chrome-devtools) do not travel automatically; see
  `references/arsenal-mcp-skills.md`.

## Edit and evolve

1. Edit the sources.
2. `bash scripts/verify.sh` (must pass; CI runs it).
3. `bash install-skill.sh` to sync the local skill.
4. Bump `version` in `.claude-plugin/plugin.json` and `SKILL.md`; add a `CHANGELOG.md` entry; commit.

## Research and benchmarks

The design is evidence-based. See [`docs/research-and-benchmarks.md`](docs/research-and-benchmarks.md)
for the research synthesis (with sources) and the self-benchmark (greenfield + brownfield fixtures,
scored by artifacts, with the scaffolder and a fixed sample project verified end to end).

## Arsenal (external references)

| Tool | Type | Use |
|---|---|---|
| [humanizer](https://github.com/blader/humanizer) | Skill | Make copy/docs read human |
| [21st.dev Magic](https://github.com/21st-dev/magic-mcp) | MCP | Generate/discover UI (React/Tailwind) |
| [shadcn-ui-mcp-server](https://github.com/Jpisnice/shadcn-ui-mcp-server) | MCP | shadcn/ui components |
| [web-design-guidelines](https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines) | Skill | Audit UI (a11y/UX) |
| [chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | MCP | Perf/errors in a real browser |
| [design-motion-principles](https://github.com/kylezantos/design-motion-principles) | Skill | Correct motion / audit animations |

## What is not automatic (by design)

- The skill guides decisions; it does not run destructive actions or install MCPs with API keys
  without confirmation. The scaffolder never overwrites without `--force`.
- Mechanical enforcement (lint on pre-commit, blocking a merge without an Issue) belongs in **CI,
  hooks, and branch protection**, not in a skill. The skill is advice; CI is the authoritative gate.
- As a plugin it ships **conservative hooks** (fail-open) that block clearly destructive Bash and
  edits to secrets, a deterministic in-session guard alongside the settings deny-list. A versioned
  `evals/` suite self-tests the package (`claude plugin eval`, with/without control arm).

## Credits and License

Standards distilled from the author's configuration and the projects in the Arsenal. MIT licensed.
Full specification in [`zeroth.md`](zeroth.md).
