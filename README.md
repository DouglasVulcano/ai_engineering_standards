# AI Engineering Standards

**English** · [Português](README.pt-BR.md)

> A single engineering standard for AI agents, packaged as a **central Claude Code skill**. One
> source of truth, applied consistently by any agent of any model, on any project.

![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-6C4BF6)
![Scope](https://img.shields.io/badge/scope-global%20%7C%20per%20project-informational)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## What it is

This repository turns a personal AI configuration (`prompts.txt` plus `skills.txt`) into a **formal,
versioned, installable engineering standard**. It delivers:

1. **`ai-engineering-standards.md`**: the complete, readable specification (single source of truth).
2. **`engineering-standards` skill**: the same knowledge packaged for Claude Code, with progressive
   disclosure (it loads only the domain relevant to the task, for maximum context performance).
3. **`install-skill.sh`**: the command that imports everything as a **central** skill under
   `~/.claude/skills/` and registers the `/standards` slash command.

The goal: whenever any AI agent starts, plans, or reviews work, it automatically applies the same
standards for workflow, UI, observability, quality, and testing.

## The 4 pillars

| # | Pillar | Summary |
|---|---|---|
| 1 | **Workflow and Governance** | Issue first, PR driven. Every task (Fix/Improvement/New feature) starts as an **Issue**; every deploy goes through a **PR that references the Issue** (`Closes #N`). Conventional Commits. Feeds the project's `CLAUDE.md`/`AGENTS.md`. |
| 2 | **Motion and UI/UX** | Every interface has **skeleton, lazy loading, and enter/exit/loading/progress animations**. Honors `prefers-reduced-motion`; animates only `transform`/`opacity`. Frequency Gate plus Web Interface Guidelines. |
| 3 | **Observability, Quality, Testing** | OpenTelemetry (base) plus Sentry/Datadog/New Relic; Biome, architecture contracts, Commitlint, Knip, Stryker; unit plus integration plus E2E (Playwright) with coverage on Codecov. |
| 4 | **Arsenal (MCP and Skills)** | The right tool per task: shadcn-ui-mcp, 21st.dev Magic, chrome-devtools-mcp, design-motion-principles, web-design-guidelines, humanizer. |

## Repository structure

```
.
├── README.md                          # this file (English)
├── README.pt-BR.md                    # Portuguese version
├── LICENSE                            # MIT
├── .gitignore                         # ignores build artifacts (.tar.gz/.zip)
├── ai-engineering-standards.md        # the complete specification (single source of truth)
├── install-skill.sh                   # importer: installs the skill into ~/.claude/skills/ + /standards
├── engineering-standards/             # the skill (payload that gets imported)
│   ├── SKILL.md                       # lean hub (triggers on its own)
│   └── references/                    # per domain deep dives (loaded on demand)
│       ├── workflow-github.md
│       ├── motion-and-ui.md
│       ├── observability-quality-testing.md
│       └── arsenal-mcp-skills.md
└── docs/origin/                       # provenance: original config that produced the standard
    ├── prompts.txt                    # pillars 1 to 3
    └── skills.txt                     # arsenal of pillar 4
```

## Quick install

```bash
# clone anywhere; the folder name is up to you
git clone https://github.com/DouglasVulcano/ai-engineering-standards.git
cd ai-engineering-standards
bash install-skill.sh
```

The installer is **idempotent** and location independent (it resolves its own path), so run it from
the repo root wherever you cloned it. It copies the skill into
`~/.claude/skills/engineering-standards/`, bundles the full spec into `references/`, and creates the
`/standards` command. Reopen Claude Code (or run `/skills`) and you are set.

**Per project scope** (instead of global), installing into a specific repo (run from the repo root):
```bash
CLAUDE_DIR=./.claude bash install-skill.sh
```

## How to use

- **Automatic**: the skill triggers on its own when your request matches the triggers: "create the
  issue/PR", "review the UI", "add skeleton/lazy loading", "set up observability", "follow the
  standards", and so on.
- **Explicit**: the slash command:
  ```
  /standards            # apply everything
  /standards ui         # motion/UI only
  /standards workflow   # Issues/PR/deploy only
  /standards o11y       # observability only
  /standards testing    # quality/testing only
  /standards arsenal    # choose or install an MCP or skill
  ```

When you work in a repository, the skill also ensures the **bootstrap block** in `CLAUDE.md`/
`AGENTS.md`, making the standard self enforcing for the next agents, of any model.

## Install on another machine / another Claude

**Claude Code (CLI/IDE)**: clone the repo and run `install-skill.sh` (as above). To update, from the
clone directory:
```bash
git pull && bash install-skill.sh
```

**Without git**: build a package from the repo folder (`tar -czf ai-standards.tar.gz -C <repo-folder> .`),
carry it to the other machine, extract it into any folder, and run `bash install-skill.sh` inside.

**Claude Desktop / claude.ai (web)**: they do not use `~/.claude`. Install through the Skills UI by
uploading the `engineering-standards/` folder (compress it first). The `/standards` slash command is
exclusive to Claude Code and does not apply there.

> Note: MCP servers with API keys (21st.dev, shadcn, chrome-devtools) do not travel automatically;
> they must be reconfigured on the new machine. Commands in
> [`engineering-standards/references/arsenal-mcp-skills.md`](engineering-standards/references/arsenal-mcp-skills.md).

## Edit and evolve the standard

1. Edit the source files in the clone (the `ai-engineering-standards.md` and/or the skill).
2. Reinstall: `bash install-skill.sh`.
3. Commit plus push. On other machines: `git pull && bash install-skill.sh`.

Keep `ai-engineering-standards.md` as the complete narrative and the `references/*` as the lean
operational units (that is what preserves context performance).

## Arsenal (external references)

| Tool | Type | Use |
|---|---|---|
| [humanizer](https://github.com/blader/humanizer) | Skill | Make copy/docs read human |
| [21st.dev Magic](https://github.com/21st-dev/magic-mcp) | MCP | Generate/discover UI (React/Tailwind) |
| [shadcn-ui-mcp-server](https://github.com/Jpisnice/shadcn-ui-mcp-server) | MCP | shadcn/ui components (code/blocks) |
| [web-design-guidelines](https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines) | Skill | Audit UI (a11y/UX) |
| [chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | MCP | Perf/errors in a real browser |
| [design-motion-principles](https://github.com/kylezantos/design-motion-principles) | Skill | Correct motion / audit animations |

## What is **not** automatic (by design)

- The skill **guides my decisions**, but it does not run destructive actions or install MCPs with
  API keys without your confirmation.
- Rules that must be **mechanically enforced** (run lint on pre commit, block a merge without an
  Issue) belong in **hooks / branch protection / CI**, not in a skill.

## Credits

Standards distilled from the author's personal configuration and the projects referenced in the
Arsenal. Full specification in [`ai-engineering-standards.md`](ai-engineering-standards.md).

## License

MIT, feel free to adapt it to your flow.
