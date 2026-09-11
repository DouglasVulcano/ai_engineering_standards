---
name: engineering-standards
description: >-
  The user's central engineering standard (workflow, UI/motion, observability, quality, testing, and
  an arsenal of MCPs and skills). Use it whenever you start, plan, or review work on any project: when
  "creating an issue/PR", "managing a deploy", "building or reviewing a screen or UI", "adding
  skeleton/lazy loading/animation", "setting up observability (Sentry, OpenTelemetry)", "configuring
  lint/quality/tests/CI", "defining the project standards", or when the user says "follow the
  standards" / "apply the standards" / "config de IA". Also when feeding CLAUDE.md/AGENTS.md. PT-BR:
  use ao "criar issue/PR", "gerenciar deploy", "revisar a UI", "configurar observabilidade", "setar
  lint/testes", "seguir os padrões", "aplicar os standards".
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebFetch
metadata:
  version: "1.0.0"
  author: DouglasVulcano
---

# Engineering Standards

Central skill that consolidates the user's AI configuration into a single standard that is mandatory
for any agent of any model. The full, readable specification lives in
`references/ai-engineering-standards.md`; the operational deep dives per domain live in the other
files under `references/`. **Read on demand:** load only the domain relevant to the task, not
everything at once.

## When to apply

Apply proactively on every start, plan, or review of work. If the repository does not yet carry the
standard in its `CLAUDE.md`/`AGENTS.md`, offer to feed it (see the bootstrap section in
`references/workflow-github.md`).

## The 4 pillars (always in force)

1. **Workflow, Issue first and PR driven.** Every task (Fix, Improvement, or New feature) starts as
   an **Issue**; every deploy goes through a **PR that references the Issue** (`Closes #N`).
   Conventional Commits. Feed the project's `CLAUDE.md`/`AGENTS.md`.
   See `references/workflow-github.md`.
2. **Motion and UI.** Every interface has **skeleton, lazy loading, and smooth animations for enter,
   exit, loading, and progress**. Honor `prefers-reduced-motion`; animate only `transform` and
   `opacity`; never `transition: all`. Apply the Frequency Gate and the Web Interface Guidelines.
   See `references/motion-and-ui.md`.
3. **Observability, Quality, and Testing.** OpenTelemetry as the base plus Sentry, Datadog, or New
   Relic; Biome, architecture contracts, Commitlint, Knip, Stryker; unit, integration, and E2E
   (Playwright) with coverage on Codecov. See `references/observability-quality-testing.md`.
4. **Arsenal.** Use the right tools: shadcn-ui-mcp, 21st.dev Magic, chrome-devtools-mcp,
   design-motion-principles, web-design-guidelines, humanizer.
   See `references/arsenal-mcp-skills.md`.

## Recommended flow

1. **Orient:** identify the kind of work and read only the reference for the domain(s) involved.
2. **Apply:** follow the pillar; for UI, guarantee the five states (skeleton, lazy, enter, exit,
   progress); for features, guarantee the CI gate (lint, types, arch, knip, tests, coverage, build).
3. **Propagate:** ensure the bootstrap block is in the repo's `CLAUDE.md`/`AGENTS.md` (self
   enforcing).
4. **Close:** validate against the Definition of Done in `references/ai-engineering-standards.md` §5.

## Reference index

| File | Load when |
|---|---|
| `references/ai-engineering-standards.md` | You need the full spec, the DoD, or the bootstrap block |
| `references/workflow-github.md` | Creating an Issue/PR, managing a deploy, feeding CLAUDE.md |
| `references/motion-and-ui.md` | Building or reviewing any screen or animation |
| `references/observability-quality-testing.md` | Setting up observability, lint/quality, tests/CI |
| `references/arsenal-mcp-skills.md` | Choosing or installing an MCP server or skill |
