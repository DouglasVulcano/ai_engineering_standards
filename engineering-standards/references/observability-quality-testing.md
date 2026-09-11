# Reference: Observability, Quality, and Testing

> Pillar 3. Source: `prompts.txt` #3.

## Observability (logs, metrics, traces)
| Tool | Role |
|---|---|
| **OpenTelemetry** | **Vendor neutral base.** Instrument traces/metrics/logs (OTel SDK) and export via OTLP. |
| **Sentry** | Errors plus performance plus session replay (ideal on the frontend); source maps, release health. |
| **Datadog** | APM plus metrics plus logs plus dashboards (receives OTLP via the Collector). |
| **New Relic** | APM plus metrics (alternative/complement; receives OTLP). |

**Practices:** one OTel layer feeding multiple exporters through the **OpenTelemetry Collector**;
Sentry for UX errors. Propagate **trace context** using W3C `traceparent`; correlate logs and traces
by `trace_id`. Define **SLIs/SLOs** and actionable alerts; a minimal dashboard (p95 latency, error
rate, saturation). Cost aware sampling (`tracesSampleRate`, tail sampling). Never log PII or secrets
(scrubbing).

## Quality and Lint
| Tool | What it does |
|---|---|
| **Architecture contracts** ("Arch-contract") | Enforce boundaries between modules/layers. Tools: **dependency-cruiser**, **eslint-plugin-boundaries**, **ts-arch**. Fail the PR on a violation. |
| **Biome** | Formatter plus linter (Rust) that replaces ESLint plus Prettier. `biome check --write` in pre commit and CI. |
| **Commitlint** | Validates Conventional Commits in the `commit-msg` hook (husky/lefthook). Enables semver/changelog. |
| **Knip** | Detects unused files/exports/deps/types. `knip` in CI. |
| **Stryker** | Mutation testing, measures the **quality** of tests (mutation score); run nightly or per critical area. |

**CI gate (fail fast):** `format -> lint (biome) -> typecheck -> arch-contract -> knip -> tests ->
coverage -> build`.

## Testing and Coverage
| Level | Tool | Target |
|---|---|---|
| Unit | Vitest/Jest | logic, utils, hooks, isolated components |
| Integration | Vitest/Jest plus Testing Library / supertest | modules together, API routes, DB (containers) |
| E2E | **Playwright** | critical flows in the browser (login/checkout); cross browser; `data-testid` |
| Coverage | **Codecov** | report on the PR; status check / diff coverage |
| Test quality | **Stryker** | mutation score |

**Practices:** the testing pyramid (many unit, few E2E covering risky paths); E2E as a smoke test
after deploy on PR previews; coverage threshold as a required check focused on diff coverage;
deterministic tests (no flakiness) with isolated data, mocked clock/network, and controlled retries.
