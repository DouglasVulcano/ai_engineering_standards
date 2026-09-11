# AI Engineering Standards, a Single Way of Working

> **Single source of truth** for any AI agent (any model) working on the user's projects. It
> consolidates and formalizes the personal configuration in `docs/origin/prompts.txt` and
> `docs/origin/skills.txt`, enriched with best practices from the referenced resources.
>
> **How to use:** this document is the complete, readable version. The operational, load on demand
> version lives in the `engineering-standards` skill (`~/.claude/skills/`). To make the standard
> mandatory in a project, copy the bootstrap block from §6 into the repository's
> `CLAUDE.md`/`AGENTS.md`.

| | |
|---|---|
| **Version** | 1.1.0 |
| **Author** | DouglasVulcano |
| **Scope** | Global, applies to all projects unless the repository explicitly overrides it |

---

## 0. Contents

1. [Engineering Workflow and Governance](#1-engineering-workflow-and-governance) (from prompts.txt #1)
2. [Motion and UI/UX](#2-motion-and-uiux) (from prompts.txt #2 plus design-motion-principles plus web-interface-guidelines)
3. [Observability, Quality, and Testing](#3-observability-quality-and-testing) (from prompts.txt #3)
4. [Arsenal: MCP Servers and Skills](#4-arsenal-mcp-servers-and-skills) (from skills.txt)
5. [Definition of Done (checklists)](#5-definition-of-done-checklists)
6. [Bootstrap: make the standard mandatory](#6-bootstrap-make-the-standard-mandatory)
7. [Appendix: traceability to the original files](#7-appendix-traceability)

---

## 1. Engineering Workflow and Governance

> **Source:** `prompts.txt` #1. Create GitHub Issues for every task (Fix, Improvement, or New
> feature); work with PRs to manage deploys; reference the Issue in the PR description; feed the
> project's `.md` file so any agent of any model follows the standard.

### 1.1 Core principle, Issue first and PR driven

**No work starts without an Issue. No code reaches production without a PR.** Every change is
traceable end to end: `Issue -> Branch -> PR -> Review -> Merge -> Deploy`.

### 1.2 Issue taxonomy

Every task falls into one of three categories (labels are mandatory):

| Category | Label | Branch prefix | Commit prefix |
|---|---|---|---|
| **Fix** (bug) | `type: fix` | `fix/<issue>-<slug>` | `fix:` |
| **Improvement** (refactor/perf/DX) | `type: improvement` | `chore/` or `refactor/<issue>-<slug>` | `refactor:` / `perf:` / `chore:` |
| **New feature** | `type: feature` | `feat/<issue>-<slug>` | `feat:` |

Recommended supporting labels: `priority: p0..p3`, `area: <domain>`, `status: in-progress`.

### 1.3 Issue template

```markdown
## Context
<why this exists: problem, opportunity, or pain>

## Goal / Acceptance criteria
- [ ] <verifiable condition 1>
- [ ] <verifiable condition 2>

## Scope
- Includes: ...
- Excludes: ...

## Technical notes
<likely files, risks, dependencies, affected screens>
```

Create via CLI:
```bash
gh issue create --title "feat: <summary>" --label "type: feature,priority: p2" \
  --body-file .github/ISSUE_TEMPLATE/feature.md
```

### 1.4 Branches and Commits

- **One branch per Issue.** Name: `<type>/<issue-number>-<short-slug>`, for example
  `feat/142-login-otp`.
- **Conventional Commits** are mandatory: `feat:`, `fix:`, `refactor:`, `perf:`, `docs:`, `test:`,
  `build:`, `ci:`, `chore:`. This feeds `commitlint` (§3.2) and automatic changelog/semver.
- Reference the Issue in the commit body when it helps: `Refs #142`.

### 1.5 Pull Requests, deploy management

- **The PR is the unit of deploy.** Merging into the release/production branch means a deploy.
- **Every PR description references the Issue** with a closing keyword so it closes on merge:
  `Closes #142`, `Fixes #143`, `Resolves #144`.
- Keep the PR small and focused (ideally under 400 lines of diff). One PR equals one Issue.
- Required checks before merge (branch protection): lint, types, tests, coverage, build.

**PR template** (`.github/pull_request_template.md`):
```markdown
## Summary
<what changes and why>

## Issue
Closes #<number>

## Type
- [ ] Fix  - [ ] Improvement  - [ ] New feature

## How to test
1. ...

## Checklist
- [ ] Follows the AI Engineering Standards (workflow, motion/UI, o11y/quality/testing)
- [ ] Tests added/updated (unit/integration/e2e as applicable)
- [ ] Observability instrumented (errors/spans) when there is a new flow
- [ ] prefers-reduced-motion respected in new animations
- [ ] No lint/types/knip regression
```

Create via CLI:
```bash
gh pr create --fill --base main \
  --title "feat: <summary>" \
  --body "Closes #142

## Summary
..."
```

### 1.6 Branch and deploy strategy

Recommended default (adjust per project and document it in `CLAUDE.md`):

- **Trunk based** with `main` always deployable; short feature branches; merge via PR (squash).
- Environments: **preview per PR** (for example Vercel/Netlify), then **staging** (optional), then
  **production** (merge into `main`/`release`).
- Rollback means reverting the PR (`gh pr revert` / `git revert`), never a hotfix straight to
  production without an Issue and a PR.

### 1.7 Propagation rule (the most important point)

> **Feed the project's `.md` file** so that any agent of any model follows the standard.

In **every** repository, the agent must ensure a `CLAUDE.md` (and/or `AGENTS.md`) exists containing
the **bootstrap block from §6**. If the file does not exist, create it; if it exists, merge without
deleting content. This makes the standard self enforcing: the next agent reads the file and already
follows the rules, regardless of the model.

---

## 2. Motion and UI/UX

> **Source:** `prompts.txt` #2. Use the Motion Principles skill
> (github.com/kylezantos/design-motion-principles) and make sure every interface has skeleton, lazy
> loading, and smooth animations for enter, exit, loading, and progress on all elements.
>
> Enriched with **design-motion-principles** (Emil Kowalski / Jakub Krehel / Jhey Tompkins) and the
> Vercel **Web Interface Guidelines** (`vercel-labs/web-interface-guidelines`).

### 2.1 Mandatory states on every async or dynamic element

No screen goes to review without covering the five states below:

1. **Skeleton/placeholder** while data loads (never a blank screen or layout shift).
2. **Lazy loading** for images below the fold (`loading="lazy"`), routes and heavy components via
   code splitting / `React.lazy` plus `Suspense`, large lists virtualized (§3, perf).
3. **Enter animation**, smooth appearance of content/routes/modals.
4. **Exit animation**, smooth unmount (`AnimatePresence` or equivalent), never a hard disappear.
5. **Loading and progress**, spinners/loading states on actions; bars/indicators on long or
   multi step operations; submit buttons show their sending state.

### 2.2 Motion principles (design-motion-principles)

**The Frequency Gate**, decide *whether* to animate before *how*:

| Trigger frequency | Recommendation |
|---|---|
| Rare (monthly) | Expressive, delightful motion is welcome |
| Occasional (daily) | Subtle, fast motion |
| Frequent (hundreds/day) | No animation or instant transition |
| Keyboard initiated | **Never animate** |

**Durations** (context dependent, do not universalize):

| Context | Guideline |
|---|---|
| Productivity UI (Emil lens) | Under 300ms; **180ms ideal** |
| Production polish (Jakub lens) | 200ms to 500ms |
| Creative / kids / playful (Jhey lens) | the duration serves the effect |

**Golden rules:**
- "The best animation is the one that goes unnoticed." If users often praise the animation, it is
  probably too prominent for production (exception: playful/kids apps).
- **Accessibility is mandatory:** every animation honors `prefers-reduced-motion`, no exceptions.
- Animate **only `transform` and `opacity`** (compositor friendly). Never `transition: all`.
- Animations must be **interruptible**, responding to user input in the middle.
- **Motion Gap Analysis:** actively look for conditional UI changes without animation (conditional
  renders without `AnimatePresence`, dynamic styles without `transition`).

**Weighting by project type** (which lens to prioritize):

| Project | Primary | Secondary | Selective |
|---|---|---|---|
| Productivity tool / SaaS dashboard | Emil (speed) | Jakub (polish) | Jhey (onboarding/empty states) |
| Kids app / educational / creative portfolio | Jakub | Jhey | Emil (high frequency) |
| Landing / marketing | Jakub | Jhey | Emil (forms, nav) |
| Mobile / e-commerce | Jakub | Emil | Jhey (delighters/showcase) |

### 2.3 Web Interface Guidelines (UI review checklist)

Apply on every UI review (source: `vercel-labs/web-interface-guidelines`, fetch the latest version
via the `web-design-guidelines` skill when available).

**Accessibility**
- Icon only buttons need `aria-label`; form controls need `<label>`/`aria-label`.
- Interactive elements need keyboard handlers; use `<button>` for actions and `<a>`/`<Link>` for
  navigation (never `<div onClick>`).
- Images need `alt` (or `alt=""` if decorative); decorative icons need `aria-hidden="true"`.
- Async updates (toasts, validation) need `aria-live="polite"`. Prefer semantic HTML over ARIA.
- Hierarchical headings (`h1` to `h6`) plus a skip link; anchors with `scroll-margin-top`.

**Focus**
- Visible focus on everything interactive (`focus-visible:ring-*`); never `outline-none` without a
  replacement.
- Prefer `:focus-visible`; use `:focus-within` for compound controls.
- Sticky headers/overlays must not obscure the focused element.

**Forms**
- Inputs need meaningful `autocomplete` and `name`; correct `type`/`inputmode` (`email`, `tel`,
  `url`, `number`).
- Never block paste (`onPaste` plus `preventDefault`); labels must be clickable (`htmlFor`/wrapping).
- `spellCheck={false}` on email/code/username; inline errors next to the field; focus the first error
  on submit.
- Submit stays enabled until the request starts; show a spinner during the request.
- Placeholders end with an ellipsis and show an example; warn before leaving with unsaved changes.

**Animation**, see §2.2 (honor reduced motion; only `transform`/`opacity`; interruptible; correct
`transform-origin`; decorative loops stop under reduced motion).

**Typography**
- Use the ellipsis character (not three dots); curly quotes; non breaking spaces in `10&nbsp;MB`,
  `⌘&nbsp;K`, brand names.
- Loading states end with an ellipsis; `font-variant-numeric: tabular-nums` in number columns;
  `text-wrap: balance`/`text-pretty` on headings.

**Content and layout**
- `truncate`/`line-clamp-*`/`break-words` for long text; flex children with `min-w-0`.
- Handle **empty states** (do not render broken UI for empty arrays/strings).
- Anticipate short, average, and very long inputs.

**Images and performance**, see §3.3 (explicit dimensions to avoid CLS, `loading="lazy"`,
`priority`/`fetchpriority`, virtualize lists over 50 items, `preconnect`/`preload` for fonts).

**Navigation and state**
- The URL reflects state (filters, tabs, pagination, panels) via query params, deep link everything
  (nuqs or similar). Real links allow Cmd/Ctrl click and middle click.
- Destructive actions require confirmation **or** an undo window, never immediate.

**Touch, dark mode, i18n, hydration**, `touch-action: manipulation`,
`overscroll-behavior: contain` in modals; `color-scheme` plus `theme-color` for dark mode;
`Intl.DateTimeFormat`/`Intl.NumberFormat` (never hardcoded formats); guard date rendering against
hydration mismatch.

**Copy**
- Active voice; Title Case for headings/buttons; numerals for counts ("8 deployments").
- Specific labels ("Save API Key", not "Continue"); error messages include the next step.

---

## 3. Observability, Quality, and Testing

> **Source:** `prompts.txt` #3. Make sure the system has Observability (Sentry, Datadog, New Relic,
> OpenTelemetry); Code Quality and Lint (architecture contracts, Biome, Commitlint, Knip, Stryker);
> unit, integration, and end to end tests (Codecov, Playwright).

### 3.1 Observability (the three pillars: logs, metrics, traces)

| Tool | Role | Recommended use |
|---|---|---|
| **OpenTelemetry (OTel)** | Vendor neutral instrumentation standard | **The base of everything.** Instrument traces/metrics/logs with the OTel SDK and export via OTLP to the chosen backend. Avoids lock in. |
| **Sentry** | Errors plus performance plus session replay (front and back) | Exception capture, source maps, `tracesSampleRate`, release health, alerts. Ideal on the frontend. |
| **Datadog** | APM plus metrics plus logs plus dashboards | Backend/infra; receives OTLP from the OTel Collector; optional RUM. |
| **New Relic** | APM plus metrics | Alternative/complement to Datadog; also receives OTLP. |

**Best practices**
- **One OTel layer, multiple exporters.** Instrument once; route to Datadog/New Relic through the
  **OpenTelemetry Collector** (OTLP). Sentry for UX/frontend errors.
- Traces and metrics are Stable in every major SDK; OTel-native logs are Stable in Java/.NET and
  maturing elsewhere, so where not Stable, emit structured JSON logs to stdout and collect them via
  the Collector.
- Propagate **trace context** end to end (W3C `traceparent`); correlate logs and traces by
  `trace_id`.
- Define **SLIs/SLOs**, actionable alerts, and a minimal dashboard per service (p95 latency, error
  rate, saturation).
- Cost aware sampling (`tracesSampleRate`, tail sampling in the Collector).
- Never log PII or secrets; scrub in the SDK/Collector.

### 3.2 Quality and Testing as a capability gate (agnostic core)

The gate is an ordered list of outcomes to guarantee, not a fixed tool list. Bind each verb to your
stack's idiomatic tool (exact commands in §3.4 and the `stack-appendix` reference); CI only ever
calls the verbs. Fail fast: cheapest and most local first.

`fmt -> lint -> typecheck -> arch -> deadcode -> test -> coverage -> build`

| Verb | Contract it guarantees | Policy |
|---|---|---|
| `fmt` | No formatting drift | `--check` in CI, auto-fix locally |
| `lint` | No lint violations or anti-patterns | Fail on error |
| `typecheck` | Types are sound | JS/TS and Python only; elsewhere folded into `build` |
| `arch` | Module/layer boundaries enforced (no forbidden imports) | A violation fails the PR |
| `deadcode` | No unreachable code, no unused exports/deps | Zero unused deps |
| `test` | Unit and integration pass | Deterministic; integration via ephemeral real deps (Testcontainers) |
| `coverage` | Diff coverage at or above threshold | Required check; focus on diff |
| `build` | Compiles/packages cleanly | Release build succeeds |

Rules that keep this true across languages: one tool may satisfy two stages (Ruff = fmt+lint,
`go build` = typecheck); compiler-intrinsic stages are marked "covered by build", never skipped;
mutation testing (test quality) runs nightly or on critical paths, never in the main gate.

**Enforcement vs advice.** This standard and the skill are advice; the authoritative gate is
**CI plus branch protection plus hooks**. Conventional Commits (§1.4) are validated by a `commit-msg`
hook locally and by CI on merge.

### 3.3 Testing model
- Pyramid: many unit, fewer integration, few E2E on the money/risk flows.
- Integration against ephemeral real dependencies (Testcontainers: Java/.NET/Go/Node/Python/Rust).
- E2E with Playwright (first-party for TS/JS/Python/Java/.NET; a side-service for Go/Rust) on
  critical flows; also a post-deploy smoke test on PR previews.
- Coverage aggregated by Codecov (every stack emits Cobertura/LCOV); diff coverage as the required
  check.
- Mutation score as a confidence metric on critical packages (nightly).

### 3.4 Per-stack bindings
The exact tool and command for each verb, per ecosystem (JS/TS, Python, Go, Rust, JVM, .NET), plus
adopt-with-caution flags, live in the skill's `references/stack-appendix.md`. One instantiation
(JS/TS): `biome check -> biome/eslint -> tsc --noEmit -> dependency-cruiser -> knip -> vitest ->
codecov -> vite build`. The original JS/TS toolset (Biome, Commitlint, Knip, Stryker, Playwright,
Codecov) is exactly one column of that appendix.

---

## 4. Arsenal: MCP Servers and Skills

> **Source:** `skills.txt` (5 resources) plus the motion skill from `prompts.txt` #2. Install per
> project or globally depending on use. **MCP servers with an API key are not installed
> automatically:** they need a key and change your config; use the commands below when you decide.

### 4.1 Skills (knowledge loaded on demand)

**humanizer**, `github.com/blader/humanizer`
Rewrites AI generated text so it reads human (25 patterns: generic vocabulary, artificial rhythm,
inflated significance, and so on), preserving facts. Use for copy, docs, READMEs, posts.
```bash
# Claude Code (plugin)
/plugin marketplace add blader/humanizer
/plugin install humanizer@humanizer
# or, for any agent (skills CLI)
npx skills add blader/humanizer --global
```
Usage: `/humanizer <text>` or "humanize the prose in docs/launch-post.md". Tip: provide 2 to 3 of
your own paragraphs for voice matching.

**web-design-guidelines**, `github.com/vercel-labs/agent-skills/.../web-design-guidelines`
Reviews UI code against the **Web Interface Guidelines** (§2.3). Fetches the latest version of the
rules from `vercel-labs/web-interface-guidelines`. Triggers: "review my UI", "check accessibility",
"audit design".
```bash
npx skills add vercel-labs/agent-skills/skills/web-design-guidelines --global
```

**design-motion-principles**, `github.com/kylezantos/design-motion-principles`
Motion specialist (Emil Kowalski / Jakub Krehel / Jhey Tompkins lenses), two modes: **Create**
(build with purposeful motion) and **Audit** (review animations and hunt AI slop, producing an HTML
report with demos). Basis of §2.2.
```bash
npx skills add kylezantos/design-motion-principles
```

### 4.2 MCP Servers

**21st.dev Magic** (formerly `21st-dev/magic-mcp`, now a proxy for the 21st MCP),
`github.com/21st-dev/magic-mcp`
Searches 10,000+ React/Tailwind components, generates UI with AI, and publishes your own straight
from the editor. Needs an API key from https://21st.dev/mcp.
```bash
# recommended CLI
npx @21st-dev/cli@latest init --client claude
```
```jsonc
// Manual configuration (HTTP MCP)
{ "mcpServers": { "21st": {
  "url": "https://21st.dev/api/mcp",
  "headers": { "x-api-key": "YOUR_21ST_API_KEY" }
} } }
```
Tools: `generate`, `get_inspiration`, `search_logo` (legacy names `21st_magic_component_*` still
work). Check `get_usage.aiGenerationEnabled` before generating.

**shadcn-ui-mcp-server**, `github.com/Jpisnice/shadcn-ui-mcp-server`
Gives the agent the source, demos, and blocks of shadcn/ui components (React/Svelte/Vue/React
Native). Use a **GitHub token** to raise the rate limit from 60 to 5000 per hour.
```bash
claude mcp add shadcn -- bunx -y @jpisnice/shadcn-ui-mcp-server --github-api-key YOUR_TOKEN
# alternative framework:
npx @jpisnice/shadcn-ui-mcp-server --framework svelte   # | vue | react-native
```

**chrome-devtools-mcp**, `github.com/ChromeDevTools/chrome-devtools-mcp`
Controls and inspects a real Chrome (Puppeteer): performance analysis (DevTools traces), debugging
(network, screenshots, console with stack maps), and browser automation. A great pair with Playwright
(§3.3) to investigate UI/perf regressions.
```jsonc
{ "mcpServers": { "chrome-devtools": {
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest"]      // plus "--slim", "--headless" for simple tasks
} } }
```
Warning: it exposes the browser content to the MCP client. Connect only trusted clients, no sensitive
data.

### 4.3 When to use what

| I need to... | Use |
|---|---|
| A shadcn/ui component (real code, blocks) | **shadcn-ui-mcp-server** |
| Generate or discover new UI (React/Tailwind) | **21st.dev Magic** |
| Guarantee correct motion / audit animations | **design-motion-principles** |
| Review UI against accessibility/UX guidelines | **web-design-guidelines** |
| Investigate performance/errors in a real browser | **chrome-devtools-mcp** |
| Make copy/docs read human | **humanizer** |

---

## 5. Definition of Done (checklists)

**Every task (§1)**
- [ ] There is a classified Issue (Fix/Improvement/New feature) with acceptance criteria.
- [ ] Branch named by convention; commits in Conventional Commits.
- [ ] PR opened referencing the Issue (`Closes #`); PR small and focused.
- [ ] The project's `CLAUDE.md`/`AGENTS.md` contains the standards bootstrap.

**Every UI (§2)**
- [ ] Skeleton plus lazy loading plus enter/exit plus loading/progress covered.
- [ ] `prefers-reduced-motion` honored; only `transform`/`opacity`; no `transition: all`.
- [ ] Frequency Gate applied; durations within the context target.
- [ ] Web Interface Guidelines checklist reviewed (a11y, focus, forms, typography, empty states).

**Every service/feature (§3)**
- [ ] Observability: errors (Sentry) plus traces/metrics (OTel to Datadog/New Relic) in the new flow.
- [ ] Quality/gate: passes fmt, lint, typecheck, arch, deadcode, test, coverage, build; commitlint on the hook.
- [ ] Testing: unit plus integration; E2E (Playwright) on critical flows; coverage published
  (Codecov).

---

## 6. Bootstrap and distribution

**Distribution.** Two ways to install (see the README):
- **Plugin (recommended for teams):** `/plugin marketplace add DouglasVulcano/ai_engineering_standards`
  then `/plugin install engineering-standards`. Versioned, updated with `claude plugin update`, no drift.
- **Global skill:** `bash install-skill.sh` copies the skill into `~/.claude/skills/`.

**Make it mandatory per repo.** Run the scaffolder to create `AGENTS.md` (canonical), a thin
`CLAUDE.md` that imports it, `.github` governance, and a stack-aware CI gate:
```bash
bash "${CLAUDE_SKILL_DIR}/scaffold.sh" .   # safe, idempotent; --dry-run to preview
```

The bootstrap block below is written into **AGENTS.md** (canonical, model-agnostic; read by Claude
Code via the CLAUDE.md import and by Codex/Cursor/Copilot directly). It makes the standard self
enforcing for any agent of any model (§1.7).

```markdown
## AI Engineering Standards (mandatory)

This project follows the **AI Engineering Standards** (skill `engineering-standards`; full spec at
`~/.claude/skills/engineering-standards/references/ai-engineering-standards.md`). Before any task:

1. **Workflow:** Issue first, PR driven. Every task (Fix/Improvement/New feature) starts as an Issue;
   every deploy goes through a PR that references the Issue (`Closes #`). Conventional Commits.
2. **Motion and UI:** every interface has skeleton, lazy loading, and smooth animations for enter,
   exit, loading, and progress. Honor `prefers-reduced-motion`; animate only `transform`/`opacity`.
   Follow the Web Interface Guidelines (a11y, focus, forms, typography).
3. **Observability:** OpenTelemetry to an OTLP Collector to any backend (Sentry/Datadog/New Relic).
4. **Quality and Testing:** the `fmt -> lint -> typecheck -> arch -> deadcode -> test -> coverage ->
   build` gate; bind each verb to the stack (stack-appendix). Enforcement is CI plus branch
   protection plus hooks; the skill is advice.

Tools: shadcn-ui-mcp, 21st.dev Magic, chrome-devtools-mcp, design-motion-principles,
web-design-guidelines, humanizer.
```

CLAUDE.md then stays thin:
```markdown
See @AGENTS.md for the canonical project guide and the AI Engineering Standards.
```

---

## 7. Appendix: traceability

| Original file | Item | Where it became a standard |
|---|---|---|
| `prompts.txt` | #1 Issues/PRs/Deploys plus feeding the `.md` | §1 (all) plus §6 bootstrap |
| `prompts.txt` | #2 Motion Principles plus skeleton/lazy/animations | §2 (all) |
| `prompts.txt` | #3 Observability/Quality/Testing | §3 (all) |
| `skills.txt` | humanizer | §4.1 |
| `skills.txt` | 21st-dev/magic-mcp | §4.2 |
| `skills.txt` | shadcn-ui-mcp-server | §4.2 |
| `skills.txt` | web-design-guidelines | §4.1 plus §2.3 |
| `skills.txt` | chrome-devtools-mcp | §4.2 |

**Corrections applied while interpreting the originals:** `kylezantos/design-principles` became
`kylezantos/design-motion-principles`; "Comilint" became **Commitlint**; "Stryke" became
**Stryker**; "Arch-contract" became **architecture contracts** (dependency-cruiser /
eslint-plugin-boundaries / ts-arch).
