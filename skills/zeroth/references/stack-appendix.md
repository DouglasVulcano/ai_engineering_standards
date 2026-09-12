# Reference: Per-Stack Appendix (verb to command)

> Thin binding layer for Pillar 3. Nothing normative lives here: it maps the agnostic gate verbs
> (see `observability-quality-testing.md`) to the idiomatic tool and command per stack. Pick your
> column. Verified September 2026.

## Contents
- Verb to command matrix
- Adopt-with-caution flags
- Fully-agnostic cells

## Verb to command
Idiomatic default shown; `( )` means the step is covered by the compiler/build, not a separate tool.

| Verb | JS/TS | Python | Go | Rust | JVM | .NET |
|---|---|---|---|---|---|---|
| `fmt` | biome check | ruff format --check | gofmt -l | cargo fmt --check | spotless:check | dotnet format --verify-no-changes |
| `lint` | biome / eslint / oxlint | ruff check | golangci-lint run | cargo clippy -D warnings | checkstyle / detekt | dotnet build (Roslyn) |
| `typecheck` | tsc --noEmit | mypy / pyright | (go build) | (cargo check) | (javac) | (dotnet build) |
| `arch` | dependency-cruiser | import-linter | go-arch-lint / depguard | cargo-deny + module visibility | ArchUnit | NetArchTest |
| `deadcode` | knip | vulture + deptry | deadcode ./... | cargo-machete | mvn dependency:analyze | Roslyn IDE0051 |
| `test` | vitest run | pytest | go test ./... | cargo nextest run | gradle test | dotnet test |
| `coverage` | vitest --coverage | pytest-cov | go test -cover | cargo-llvm-cov | JaCoCo / Kover | coverlet |
| `build` | vite build / tsup | uv build | go build ./... | cargo build --release | gradle build | dotnet publish |
| mutation (nightly) | StrykerJS | mutmut / cosmic-ray | Gremlins | cargo-mutants | PIT (pitest) | Stryker.NET |
| commit-convention | commitlint | commitizen | cocogitto | cocogitto | commitlint | commitlint |
| build/monorepo | pnpm + Turborepo/Nx | uv (+ workspaces) | go workspaces | cargo workspaces | Gradle | MSBuild + Central Package Mgmt |

All coverage tools emit Cobertura/LCOV, so Codecov stays the single reporting layer. Language-agnostic
hook runners: Lefthook or pre-commit.

## Adopt-with-caution (dated, September 2026)
- Python type-checker: use mypy or pyright today; `ty` (Astral, Rust) is beta, adopt at 1.0.
- TypeScript 7 native compiler (`tsgo`) is GA but has no stable plugin API until 7.1; keep
  typescript-eslint on the classic `tsc` path.
- OTel logs: Stable in Java/.NET; Beta in Go/Rust; in-development in Python/JS, so use structured
  stdout plus the Collector there.
- Rust internal architecture boundaries lean on the module/visibility system plus emerging tools
  (cargo-modules, Modou); cargo-deny governs external dependency policy.

## Fully-agnostic cells (same across every stack)
Conventional Commits, OpenTelemetry (OTLP to Collector), Testcontainers (integration), Playwright
(E2E), and Codecov (coverage sink) are cross-language standards and belong in the core almost
verbatim. Type-checking is a separate verb only in JS/TS and Python; everywhere else it is part of
`build`.
