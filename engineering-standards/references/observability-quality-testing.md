# Referência — Observabilidade, Qualidade & Testes

> Pilar 3. Origem: `prompts.txt` #3.

## Observabilidade (logs, métricas, traces)
| Ferramenta | Papel |
|---|---|
| **OpenTelemetry** | **Base vendor-neutral.** Instrumente traces/metrics/logs (OTel SDK) e exporte via OTLP. |
| **Sentry** | Erros + performance + session replay (ideal no frontend); source maps, release health. |
| **Datadog** | APM + métricas + logs + dashboards (recebe OTLP via Collector). |
| **New Relic** | APM + métricas (alternativa/complemento; recebe OTLP). |

**Práticas:** uma camada OTel → múltiplos exportadores via **OpenTelemetry Collector**; Sentry p/
erros de UX. Propague **trace context** W3C (`traceparent`); correlacione logs↔traces por `trace_id`.
Defina **SLIs/SLOs** e alertas acionáveis; dashboard mínimo (latência p95, erro %, saturação).
Sampling consciente de custo (`tracesSampleRate`, tail sampling). Nunca logar PII/segredos (scrubbing).

## Qualidade & Lint
| Ferramenta | O que faz |
|---|---|
| **Contratos de arquitetura** ("Arch-contract") | Impõe fronteiras entre módulos/camadas. Tools: **dependency-cruiser**, **eslint-plugin-boundaries**, **ts-arch**. Falha o PR na violação. |
| **Biome** | Formatter+linter (Rust) que substitui ESLint+Prettier. `biome check --write` em pre-commit e CI. |
| **Commitlint** | Valida Conventional Commits no hook `commit-msg` (husky/lefthook). Habilita semver/changelog. |
| **Knip** | Detecta arquivos/exports/deps/types não usados. `knip` em CI. |
| **Stryker** | Mutation testing — mede a **qualidade** dos testes (mutation score); rodar nightly/por área crítica. |

**Gate de CI (falha rápido):** `format → lint(biome) → typecheck → arch-contract → knip → testes →
cobertura → build`.

## Testes & Cobertura
| Nível | Ferramenta | Alvo |
|---|---|---|
| Unitário | Vitest/Jest | lógica, utils, hooks, componentes isolados |
| Integração | Vitest/Jest + Testing Library / supertest | módulos juntos, rotas de API, DB (containers) |
| E2E | **Playwright** | fluxos críticos no browser (login/checkout); cross-browser; `data-testid` |
| Cobertura | **Codecov** | relatório no PR; status check / diff coverage |
| Qualidade dos testes | **Stryker** | mutation score |

**Práticas:** pirâmide de testes (muitos unit, poucos E2E cobrindo caminhos de risco); E2E como smoke
pós-deploy nos previews; threshold de cobertura como *required check* focado em diff coverage; testes
determinísticos (sem flaky) — dados isolados, relógio/rede mockados, retries controlados.
