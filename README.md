<p align="center">
  <img alt="Zeroth" src="docs/logo.png#gh-dark-mode-only" width="320">
  <img alt="Zeroth" src="docs/icon.png#gh-light-mode-only" width="96">
</p>

<h1 align="center">Zeroth</h1>

<p align="center">
  <a href="https://douglasvulcano.github.io/zeroth-ai/"><b>Website</b></a> · <b>English</b> · <a href="README.pt-BR.md">Português</a>
</p>

> One engineering standard your AI coding agents actually follow, on every project and in any
> language. It ships as a **Claude Code plugin and skill**, and also travels as a plain **`AGENTS.md`**
> that any agent of any model (Claude, Cursor, Copilot, Codex) can read.

![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin%20%2B%20skill-6C4BF6)
![Agnostic](https://img.shields.io/badge/stack-agnostic-success)
![Scope](https://img.shields.io/badge/scope-global%20%7C%20project%20%7C%20team-informational)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## What it is

AI agents write code a little differently every time. Zeroth gives them one shared playbook, so the
way you work, build, test, and ship stays the same no matter which agent or model is helping. It is
three things:

- **A standard** you install once and reuse everywhere (the full, readable spec is [`zeroth.md`](zeroth.md)).
- **A skill** that loads the right part automatically when you start, plan, or review work.
- **A scaffolder** that drops governance into any repo in one command (issue/PR templates, a CI gate,
  `AGENTS.md`, safety rules).

You do not adopt it all at once. Install it and the agent starts applying the standard; run the
scaffolder when you want a repo to enforce it.

## Install

**For a team (recommended)** - versioned, no drift. In Claude Code:

```text
/plugin marketplace add DouglasVulcano/zeroth-ai
/plugin install zeroth
```

**For yourself** - a global skill on your machine:

```bash
git clone https://github.com/DouglasVulcano/zeroth-ai.git
cd zeroth-ai
bash install-skill.sh
```

Update later with `claude plugin update` (plugin) or `git pull && bash install-skill.sh` (skill).

## Use

- **Automatic** - just work. The skill triggers when your request matches ("create the issue and PR",
  "review this screen", "set up the CI gate", "follow the standards").
- **On demand** - run `/zeroth` to apply everything, or focus one area:

  ```text
  /zeroth workflow | ui | testing | o11y | arsenal | scaffold
  ```

- **Set up a repo** - `/zeroth scaffold` (or preview first with
  `bash skills/zeroth/scaffold.sh /path/to/repo --dry-run`) adds issue/PR templates, a stack-aware CI
  gate, `AGENTS.md`, and safety rules. It detects your stack, never overwrites without `--force`, and
  is safe to re-run. Add `--with-plugin DouglasVulcano/zeroth-ai` to auto-enable the plugin for
  everyone who trusts the repo.

## What you get: the 4 pillars

| # | Pillar | In one line |
|---|---|---|
| 1 | **Workflow** | Issue-first, PR-driven. Every task is an Issue; every deploy is a PR that closes it (`Closes #N`). Conventional Commits. |
| 2 | **Motion and UI** | Every screen has skeleton, lazy loading, and smooth enter/exit/loading states; respects `prefers-reduced-motion`. |
| 3 | **Quality and Testing** | One CI gate (`fmt -> lint -> typecheck -> arch -> deadcode -> test -> coverage -> build`), bound to your stack. Observability (OpenTelemetry) is opt-in, for deployed apps. |
| 4 | **Arsenal** | The right MCP or skill per task: UI generation, browser performance, motion, humanized copy. |

The standard is **stack-agnostic**: the gate is a set of contracts, and each verb maps to your
language's tools (JS/TS, Python, Go, Rust, JVM, .NET). The skill is advice; your **CI plus branch
protection** are what actually enforce it.

## Learn more

- **[Full specification (`zeroth.md`)](zeroth.md)** - the complete standard, readable end to end.
- **Deep dives** (the skill loads these on demand):
  [workflow](skills/zeroth/references/workflow-github.md) ·
  [motion and UI](skills/zeroth/references/motion-and-ui.md) ·
  [quality and testing](skills/zeroth/references/quality-and-testing.md) ·
  [observability](skills/zeroth/references/observability.md) ·
  [per-stack commands](skills/zeroth/references/stack-appendix.md) ·
  [arsenal](skills/zeroth/references/arsenal-mcp-skills.md).
- **[Security](SECURITY.md)** - threat model, branch protection, and the trust boundary.
- **[Contributing](CONTRIBUTING.md)** - how to change the standard and pass the gate.
- **[Research and benchmarks](docs/research-and-benchmarks.md)** - the evidence behind the design.

## License

MIT. Standards distilled from the author's configuration and the projects in the Arsenal.
