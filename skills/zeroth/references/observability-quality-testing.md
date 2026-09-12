# Reference: Observability, Quality, and Testing (agnostic core)

> Pillar 3. Source: `prompts.txt` #3. This is the language-agnostic core: capability contracts,
> gate order, thresholds, and the observability baseline. Exact per-stack commands live in
> `stack-appendix.md`.

## Observability (logs, metrics, traces)
A vendor-neutral baseline that works with any backend (Sentry, Datadog, New Relic, Grafana):
1. Instrument once with the OpenTelemetry SDK or auto-instrumentation. Traces and metrics are
   required (Stable in every major SDK).
2. Export OTLP to an OpenTelemetry Collector; never point the app at a vendor SDK directly.
3. The Collector fans out to any backend, so swapping vendors is a Collector config change with zero
   app changes.
4. Logs: use OTel-native logs where Stable (Java, .NET); elsewhere (Python, JS, Go, Rust today)
   write structured JSON logs to stdout and collect them via the Collector, correlated by `trace_id`.
5. Sentry on the frontend for errors, session replay, and release health (it also ingests OTLP).
6. Propagate W3C `traceparent`; correlate logs and traces by `trace_id`; define SLIs/SLOs; RED/USE
   dashboards (p95 latency, error rate, saturation); tail sampling in the Collector; scrub PII and
   secrets.

## The CI gate = capability contracts
The gate is an ordered list of outcomes to guarantee, not a fixed tool list. Bind each verb to your
stack's idiomatic tool in `stack-appendix.md`; CI only ever calls the verbs. Fail fast: cheapest and
most local first.

`fmt -> lint -> typecheck -> arch -> deadcode -> test -> coverage -> build`

| Verb | Contract it guarantees | Policy |
|---|---|---|
| `fmt` | No formatting drift | `--check` in CI, auto-fix locally |
| `lint` | No lint violations or anti-patterns | Fail on error; track warnings |
| `typecheck` | Types are sound | JS/TS and Python only; elsewhere folded into `build` |
| `arch` | Module/layer boundaries enforced (no forbidden imports) | A violation fails the PR |
| `deadcode` | No unreachable code, no unused exports/deps | Zero unused deps |
| `test` | Unit and integration pass | Deterministic; integration via ephemeral real deps |
| `coverage` | Diff coverage at or above threshold | Required check; focus on diff, not absolute |
| `build` | Compiles/packages cleanly | Release build succeeds |

Rules that keep this true across languages:
- One tool may satisfy two stages (Ruff = fmt+lint; `go build` = typecheck).
- Compiler-intrinsic stages are marked "covered by build", never skipped silently.
- Mutation testing (test quality) runs nightly or on critical paths, never in the main gate.

## Testing model
- Pyramid: many unit, fewer integration, few E2E on the money/risk flows.
- Integration against ephemeral real dependencies (Testcontainers: Java/.NET/Go/Node/Python/Rust).
- E2E with Playwright (first-party for TS/JS/Python/Java/.NET; run as a side-service for Go/Rust) on
  critical flows; also a post-deploy smoke test on PR previews.
- Coverage aggregated by Codecov (every stack emits Cobertura/LCOV); diff coverage as the required
  check.
- Mutation score as a confidence metric on critical packages (cadence: nightly).

## Thresholds (set per repo, record them in AGENTS.md)
- Diff coverage target (for example, at or above 80%).
- Mutation score target on critical packages.
- Policy: "arch violations fail the PR", "zero unused deps".
