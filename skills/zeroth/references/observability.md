# Reference: Observability in production (opt-in)

> Pillar 3, runtime companion. Source: `prompts.txt` #3. This is a **production** practice: it watches
> a deployed app or service while real users use it. It is **not** part of the CI gate in
> `quality-and-testing.md`, and it does not run on push or PR.

## When this applies (and when it does not)
Adopt observability when you have (or are about to have) a **deployed app or service with real
traffic**. Skip it, for now, when the project is a **library, CLI, plugin, script, or a small app
not yet in production**. Instrumenting nothing that is running yet is wasted setup; add it when there
is something worth observing.

Nothing here is mandatory for the standard to apply. A repo can pass the full Pillar 3 CI gate with
no observability at all; this page is what you reach for once the app is live.

## Adopt in tiers (cheapest first)
1. **Structured logs to stdout (day one, trivial).** Emit JSON logs to stdout with a `trace_id`
   field. Costs nothing to run, works in any environment, and is enough for a small service.
2. **Traces and metrics (when you have production traffic).** Instrument once with the OpenTelemetry
   (OTel) SDK or auto-instrumentation; traces and metrics are Stable in every major SDK. Export OTLP
   to an OpenTelemetry Collector; never point the app at a vendor SDK directly.
3. **SLOs, alerts, and dashboards (as the service matters more).** Define SLIs/SLOs; RED/USE
   dashboards (p95 latency, error rate, saturation); actionable alerts.

## The recommended shape (once you do instrument)
- **One OTel layer, pluggable backend.** Instrument once and let the Collector fan out, so swapping
  vendors is a Collector config change with zero app changes. Common backends: Sentry, Datadog, New
  Relic, Grafana, or whatever your team already runs. Use your existing stack; do not migrate to a
  specific vendor just to satisfy this standard.
- **Logs:** use OTel-native logs where Stable (Java, .NET); elsewhere (Python, JS, Go, Rust today)
  write structured JSON logs to stdout and collect them via the Collector, correlated by `trace_id`.
- **Frontend:** Sentry is a common choice for errors, session replay, and release health (it also
  ingests OTLP).
- Propagate W3C `traceparent`; correlate logs and traces by `trace_id`; cost-aware sampling
  (`tracesSampleRate`, tail sampling in the Collector); scrub PII and secrets in the SDK/Collector.

## Language maturity note
OTel traces and metrics are Stable everywhere. OTel-native logs are Stable in Java/.NET, Beta in
Go/Rust, and in development in Python/JS, so use structured stdout logs plus the Collector where
native logs are not Stable yet (see `stack-appendix.md`).
