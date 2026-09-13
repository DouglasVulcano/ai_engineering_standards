# AGENTS.md

> Canonical, model-agnostic guide for AI agents in this repo. Keep it short and repo-specific
> (aim under 150 lines). Read by Claude Code (via the CLAUDE.md import), Codex, Cursor, Copilot, and
> other agent tools. Fill the placeholders; delete what does not apply.

## Project
<one line: what this is>

## Stack
<language + framework + package manager + versions>

## Commands (gate verbs)
- fmt:       <cmd>
- lint:      <cmd>
- typecheck: <cmd>   # compiled languages: covered by build
- arch:      <cmd>
- deadcode:  <cmd>
- test:      <cmd>
- coverage:  <cmd>
- build:     <cmd>
- run/dev:   <cmd>

## Conventions
- Workflow: Issue-first, PR-driven. Every task is an Issue; every deploy is a PR that references it
  (`Closes #N`). Conventional Commits.
- Repo-specific rules (only what is non-obvious): <...>

## Zeroth (mandatory)
This repo follows the `zeroth` skill. Apply the 4 pillars before any task:
1. Workflow (Issue-first, PR-driven).
2. Motion and UI (skeleton, lazy loading, enter/exit/loading/progress; `prefers-reduced-motion`).
3. Quality + Testing (the `fmt -> ... -> build` CI gate; diff coverage). Observability
   (OpenTelemetry or your existing stack) is opt-in: add it only when you ship a deployed app/service.
4. Arsenal (shadcn-ui-mcp, 21st.dev Magic, chrome-devtools-mcp, design-motion-principles,
   web-design-guidelines, humanizer).
Full spec: the `zeroth` skill (`references/zeroth.md`).
