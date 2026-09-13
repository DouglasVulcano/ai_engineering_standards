# Reference: Quality and Testing (the CI gate)

> Pillar 3, repo-time core. Source: `prompts.txt` #3. This is the language-agnostic quality gate that
> runs on every push and PR: capability contracts, gate order, thresholds, and the testing model.
> Exact per-stack commands live in `stack-appendix.md`. Runtime observability (a separate, opt-in
> concern for deployed apps) lives in `observability.md`.

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

This gate is the authoritative enforcement point together with branch protection: the skill is
advice, CI plus branch protection are what actually block a bad merge.

## Testing model
- Pyramid: many unit, fewer integration, few E2E on the money/risk flows.
- Integration against ephemeral real dependencies (Testcontainers: Java/.NET/Go/Node/Python/Rust).
- E2E with Playwright (first-party for TS/JS/Python/Java/.NET; run as a side-service for Go/Rust) on
  critical flows; also a post-deploy smoke test on PR previews.
- Diff coverage is the required check. Any tool that emits Cobertura/LCOV works as the reporting
  sink (Codecov, Coveralls, SonarQube, or a self-hosted service); pick one, do not require a specific
  vendor. Focus the gate on diff, not absolute coverage.
- Mutation score as a confidence metric on critical packages (cadence: nightly).

## Thresholds (set per repo, record them in AGENTS.md)
- Diff coverage target (for example, at or above 80%).
- Mutation score target on critical packages.
- Policy: "arch violations fail the PR", "zero unused deps".

## Related
- `observability.md`: runtime observability (logs, metrics, traces) for deployed apps. It is opt-in
  by project type and is not part of this CI gate.
- `stack-appendix.md`: the exact command per verb for JS/TS, Python, Go, Rust, JVM, and .NET.
