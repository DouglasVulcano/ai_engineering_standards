# AI Engineering Standards

**English** · [Português](README.pt-BR.md)

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

1. **`ai-engineering-standards.md`** the complete, readable specification (single source of truth).
2. **The `engineering-standards` skill** the same knowledge with progressive disclosure (loads only
   the domain relevant to the task) plus a bundled **scaffolder** and governance **assets**.
3. **Plugin packaging** (`.claude-plugin/`) for versioned team distribution, and **`install-skill.sh`**
   for a global personal install.

Goal: when any AI agent starts, plans, or reviews work, it applies the same standard for workflow,
UI, observability, quality, and testing, and can scaffold the governance to enforce it.

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
├── ai-engineering-standards.md        # the complete specification (single source of truth)
├── install-skill.sh                   # global-skill installer (+ /standards command)
├── .claude-plugin/                    # plugin.json + marketplace.json (team distribution)
├── commands/standards.md              # the /standards slash command
├── scripts/verify.sh                  # repo self-check (dogfoods pillar 3)
├── hooks/                             # plugin PreToolUse guards (block destructive Bash / secret edits)
├── evals/                             # claude plugin eval suite (with/without control arm)
├── skills/engineering-standards/       # the skill (payload that gets installed)
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
/plugin marketplace add DouglasVulcano/ai_engineering_standards
/plugin install engineering-standards
```
Update later with `claude plugin update`.

**Global skill (personal):**
```bash
git clone https://github.com/DouglasVulcano/ai_engineering_standards.git
cd ai_engineering_standards
bash install-skill.sh
```
The installer is idempotent and location-independent; it copies the skill (with the scaffolder and
assets) into `~/.claude/skills/` and registers `/standards`. Per-project scope:
`CLAUDE_DIR=./.claude bash install-skill.sh`.

**Team / project-wide (auto-enable for everyone).** Commit a `.claude/settings.json` so anyone who
trusts the repo gets the plugin automatically, with no manual steps:
```json
{
  "extraKnownMarketplaces": {
    "ai_engineering_standards": { "source": { "source": "github", "repo": "DouglasVulcano/ai_engineering_standards" } }
  },
  "enabledPlugins": { "engineering-standards@ai_engineering_standards": true }
}
```
The scaffolder writes this for you:
`scaffold.sh <repo> --with-plugin DouglasVulcano/ai_engineering_standards`.

## Use

- **Automatic**: the skill triggers when your request matches ("create the issue/PR", "review the
  UI", "set up observability", "follow the standards").
- **Explicit**: `/standards` (everything) or `/standards ui | workflow | o11y | testing | arsenal |
  scaffold`.

## Scaffold governance into a repo

The highest-leverage feature. It creates issue/PR templates, `CODEOWNERS`, a stack-aware CI gate,
**AGENTS.md** (canonical) + a thin **CLAUDE.md**, and a `.claude/settings.json` safety deny-list.
It **detects your stack**, is **idempotent**, and **never overwrites** a file without `--force`.

```bash
# preview, then apply (path defaults to the current directory)
bash skills/engineering-standards/scaffold.sh /path/to/repo --dry-run
bash skills/engineering-standards/scaffold.sh /path/to/repo
```
Add `--with-plugin OWNER/REPO` to also wire the project's `.claude/settings.json` so the plugin
auto-enables for the whole team. After installing globally, the same script lives at
`~/.claude/skills/engineering-standards/scaffold.sh`. Then fill `AGENTS.md` with your stack's gate
commands (see the stack appendix) and set real owners in `.github/CODEOWNERS`.

## Stack-agnostic by design

Pillar 3 is a set of **capability contracts** (the 8 verbs), not a fixed toolset. The exact command
per verb for JS/TS, Python, Go, Rust, JVM, and .NET lives in
`skills/engineering-standards/references/stack-appendix.md`. The original JS/TS toolset (Biome, Knip,
Stryker, Playwright, Codecov) is simply one column of that appendix.

## Install on another machine or another Claude

- **Claude Code**: install the plugin, or clone and run `install-skill.sh`. Update with
  `git pull && bash install-skill.sh`.
- **Claude Desktop / claude.ai (web)**: upload the `skills/engineering-standards/` folder through the
  Skills UI (the `/standards` command is Claude Code only).
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
Full specification in [`ai-engineering-standards.md`](ai-engineering-standards.md).
