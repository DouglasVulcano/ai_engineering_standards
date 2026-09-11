# Research and Benchmarks

Evidence base for the 1.1.0 redesign. Three parallel research tracks fed the design; a sandbox
self-benchmark then tested what the package actually delivers and what to fix.

---

## 1. Method

Three focused research passes (web sources, September 2026), then a sandbox benchmark:
- Track A: AI agent-configuration best practices (skills, AGENTS.md/CLAUDE.md, MCP, enforcement).
- Track B: language/stack-agnostic tooling across six ecosystems.
- Track C: high-leverage features + a credible benchmark method.

---

## 2. Findings that shaped the design

### 2.1 Agent configuration (Track A)
- **Progressive disclosure** is the performance model: only `name`+`description` are pre-loaded; the
  body loads on trigger; references load on demand. Keep `SKILL.md` under 500 lines, references one
  level deep, a TOC on any reference over 100 lines. The **description is the trigger** and the #1
  failure point. ([skill best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices), [Claude Code skills](https://code.claude.com/docs/en/skills))
- **AGENTS.md is the canonical, model-agnostic layer** (60k+ repos; stewarded under the Linux
  Foundation; read by 20-30+ tools). Make `CLAUDE.md` thin and import it. Generic, bloated context
  files *reduce* success and raise cost, so keep them lean and repo-specific. ([agents.md](https://agents.md/), [lean context wins](https://marmelab.com/blog/2026/01/21/agent-experience.html))
- **Split advice from enforcement.** A skill/CLAUDE.md is advice a model can skip; **CI + branch
  protection + hooks are the authoritative gate**. Ship both; state which is which. ([hooks](https://code.claude.com/docs/en/hooks), [CC security](https://generalanalysis.com/guides/anthropic-claude-code-security-best-practices))
- **Distribute as a plugin via a marketplace** (versioned, auto-updating) to kill copy-paste drift.
  ([plugins reference](https://code.claude.com/docs/en/plugins-reference), [marketplaces](https://code.claude.com/docs/en/plugin-marketplaces))
- **MCP only for live data/execution**; vet for prompt-injection, token audience, least privilege,
  SSRF, supply chain. ([MCP security](https://modelcontextprotocol.io/docs/tutorials/security/security_best_practices))

### 2.2 Agnostic tooling (Track B)
- The standard generalizes because each gate stage names a **capability**, not a tool. Eight verbs:
  `fmt, lint, typecheck, arch, deadcode, test, coverage, build`.
- **Agnostic core (contracts + gate order + thresholds) + a thin per-stack appendix (verb to
  command)** for JS/TS, Python, Go, Rust, JVM, .NET. Type-check folds into `build` for compiled
  languages; one tool may satisfy two stages (Ruff = fmt+lint). ([Ruff](https://docs.astral.sh/ruff/formatter/), [Testcontainers](https://testcontainers.com/getting-started/), [Playwright languages](https://playwright.dev/docs/languages))
- **Fully cross-language cells**: Conventional Commits, OpenTelemetry (OTLP to Collector),
  Testcontainers, Playwright, Codecov. OTel traces/metrics are Stable everywhere; logs vary, so use
  structured stdout + Collector where logs are not Stable. ([OTel languages](https://opentelemetry.io/docs/languages/))

### 2.3 Features + benchmark (Track C)
- Prioritized P0/P1 features: safety rails + idempotent scaffolding, reliable discoverability,
  AGENTS.md/CLAUDE.md bootstrap, governance scaffolding, agnostic CI gate, a bundled eval/self-test,
  self-versioning, multi-language detection. ([features/plugins](https://code.claude.com/docs/en/plugins-reference))
- **Measure objectively, never by self-report** (devs felt 20% faster but were 19% slower in an RCT).
  Use DORA + DX Core 4, and always pair a speed metric with a stability metric. ([METR RCT](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/), [DORA](https://dora.dev/guides/dora-metrics/), [DX Core 4](https://getdx.com/dx-core-4/))
- **Self-test on greenfield + brownfield fixtures**, scored by artifacts; `claude plugin eval`
  (early access) provides a with/without control arm. ([plugin eval](https://www.matthewswong.com/en/blog/claude-code-plugin-eval-test-suite/))

---

## 3. What we implemented (and what is roadmap)

| Finding | Implemented in 1.1.0 |
|---|---|
| AGENTS.md canonical + thin CLAUDE.md | Propagation, scaffolder assets, repo dogfoods it |
| Advice vs enforcement split | Stated in Pillar 3, PR checklist, SECURITY; CI templates shipped |
| Plugin distribution | `.claude-plugin/plugin.json` + `marketplace.json` |
| Agnostic core + per-stack appendix | Pillar 3 rewrite + `references/stack-appendix.md` |
| Governance scaffolding + safety | `scaffold.sh` + `assets/` (idempotent, no overwrite, `--dry-run`) |
| MCP governance | Checklist in `references/arsenal-mcp-skills.md` |
| Self-test | `scripts/verify.sh` (files, JSON, dashes, smoke tests) + this benchmark |
| Hooks (enforcement in session) | `hooks/` PreToolUse guards: destructive Bash + secret edits, fail-open |
| Eval suite | `evals/` for `claude plugin eval` (with/without control arm) |

**Roadmap (not yet shipped):** format-on-write and local commitlint hooks; semantic-release wiring;
optional policy-as-code (conftest/OPA) and OpenSSF Scorecard in CI; deeper stack detection that fills
CI commands automatically.

---

## 4. Self-benchmark

### 4.1 Setup
Two git fixtures (in a sandbox, not committed):
- **Greenfield**: an empty repo.
- **Brownfield**: a small **Python FastAPI** todo service with planted gaps (hardcoded secret, no
  validation, no error handling, a `delete` KeyError bug, no tests, no CI, no governance). Python was
  chosen on purpose to stress the agnostic claim (the standard originated JS/TS-first).

### 4.2 Rubric (pass / fail per item)
Activation, governance files present and valid, AGENTS.md + CLAUDE.md, CI gate stack-appropriate,
safety/idempotency (no overwrite, clean re-run), and the gate running green.

### 4.3 Results
| Check | Greenfield | Brownfield (Python) |
|---|---|---|
| Stack detected | generic | python |
| Governance scaffolded (issue/PR/CODEOWNERS) | pass (10 files) | pass (10 files) |
| CI gate emitted | generic placeholder | `ci.python.yml` (ruff/mypy/pytest/codecov) |
| AGENTS.md canonical + thin CLAUDE.md | pass | pass |
| Safety: existing files untouched | n/a (empty) | pass (README kept) |
| Idempotent re-run (no diffs) | pass | pass |
| No overwrite without `--force` | pass | pass (user marker survived) |
| Generated JSON/YAML valid | pass | pass |

### 4.4 Brownfield code delivery (agent applies the standard)
Following the standard, the planted gaps were fixed and covered:
- `delete` made safe (no KeyError; returns bool) and a **regression test** added.
- Hardcoded secret moved to `os.environ`.
- 404 handling added for missing items.
- Unit tests added and run with the stdlib (`ruff`/`pytest` were not installed in the sandbox):

```
$ python3 -m unittest discover
....
Ran 4 tests in 0.000s
OK
```
`py_compile` passes; `grep` confirms no hardcoded secret remains. This is the `test` and `build`
verbs passing locally as an executable proxy for the CI gate.

### 4.5 Gaps found and fixes applied
- The generic CI file is a placeholder (not runnable) by design; the agent must bind stack commands.
  Mitigated by shipping concrete `ci.python.yml` / `ci.node.yml` starters and stack detection.
- `SKILL.md` referenced `references/ai-engineering-standards.md`, which only exists after install
  (bundled). Fixed earlier with an explicit note in `SKILL.md`.
- Scaffolder only creates files (never merges into an existing `AGENTS.md`/`settings.json`). This is a
  deliberate safety choice; deep merge is on the roadmap.

### 4.6 Reproduce
- `bash scripts/verify.sh` runs the files/JSON/dash/description checks plus installer and scaffolder
  smoke tests (create + idempotent re-run) and the hook block/allow behavior, in throwaway temp dirs.
- `bash scripts/stress.sh [out.json]` runs the full stress battery (hook guards, 7-stack scaffolder
  matrix, latency, throughput, context ratio) and writes a JSON results file to the path you pass
  (default: a temp path; results are not versioned).
- The shipped `evals/` suite runs under `claude plugin eval . --ablation with-without` (early access).

---

## 5. Measuring impact in real repos
Sandbox scores prove the package produces correct artifacts; they do not prove business impact.
For that, run a before/after or, better, a Difference-in-Differences rollout on real repos and track
**DORA** (deploy frequency, lead time, change-fail rate, recovery, rework) plus cycle time, PR review
load, defect escape rate, onboarding time-to-first-green-PR, and a governance compliance rate
(OpenSSF Scorecard). Always pair a speed metric with a stability metric, and never use self-reported
speed. ([DiD for rollouts](https://www.freecodecamp.org/news/why-ab-testing-breaks-in-ai-rollouts-and-how-to-fix-it/), [Scorecard](https://scorecard.dev/), [defect escape](https://testsigma.com/blog/defect-escape/))
