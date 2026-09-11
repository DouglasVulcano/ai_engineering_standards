# Referência — Workflow de Engenharia & Governança (GitHub)

> Pilar 1. Origem: `prompts.txt` #1. Princípio: **Issue-first, PR-driven.**
> Nenhum trabalho começa sem Issue; nenhum código vai a produção sem PR.

## Fluxo canônico
`Issue → Branch → Commits (Conventional) → PR (menciona a Issue) → Review/Checks → Merge → Deploy`

## Taxonomia de Issues (label obrigatória)
| Categoria | Label | Branch | Commit |
|---|---|---|---|
| Correção (bug) | `type: fix` | `fix/<issue>-<slug>` | `fix:` |
| Melhoria (refactor/perf/DX) | `type: improvement` | `refactor/<issue>-<slug>` | `refactor:`/`perf:`/`chore:` |
| Nova função (feature) | `type: feature` | `feat/<issue>-<slug>` | `feat:` |

Apoio: `priority: p0..p3`, `area: <domínio>`, `status: in-progress`.

## Template de Issue
```markdown
## Contexto
<problema/oportunidade>
## Objetivo / Critério de aceite
- [ ] <condição verificável>
## Escopo
- Inclui: ... / Não inclui: ...
## Notas técnicas
<arquivos, riscos, dependências, telas>
```
```bash
gh issue create --title "feat: <resumo>" --label "type: feature,priority: p2" --body-file .github/ISSUE_TEMPLATE/feature.md
```

## Commits & Branches
- **Uma branch por Issue**; nome `<tipo>/<numero>-<slug>`.
- **Conventional Commits** (`feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`, `ci`, `chore`)
  — alimenta commitlint e semver/changelog. `Refs #N` no corpo quando útil.

## Pull Requests = unidade de deploy
- **Toda descrição menciona a Issue** com closing keyword: `Closes #N` / `Fixes #N` / `Resolves #N`.
- PR pequeno (< ~400 linhas), 1 PR = 1 Issue. Branch protection com checks: lint, types, testes,
  cobertura, build.

Template `.github/pull_request_template.md`:
```markdown
## Resumo
<o que muda e por quê>
## Issue
Closes #<numero>
## Tipo
- [ ] Correção  - [ ] Melhoria  - [ ] Nova função
## Como testar
1. ...
## Checklist
- [ ] Segue os AI Engineering Standards
- [ ] Testes (unit/integração/e2e) atualizados
- [ ] Observabilidade instrumentada em novos fluxos
- [ ] prefers-reduced-motion respeitado em novas animações
- [ ] Sem regressão de lint/types/knip
```
```bash
gh pr create --fill --base main --title "feat: <resumo>" --body "Closes #142

## Resumo
..."
```

## Deploy & rollback
- Trunk-based: `main` sempre deployável; **preview por PR** → staging (opcional) → produção (merge).
- Rollback = reverter o PR (`git revert`/`gh pr revert`) — nunca hotfix direto sem Issue+PR.

## Propagação (regra-chave)
> **Alimente o `CLAUDE.md`/`AGENTS.md` do projeto** para que qualquer agente de qualquer modelo siga
> o padrão. Se não existir, criar; se existir, fazer merge sem apagar. Bloco de bootstrap:

```markdown
## AI Engineering Standards (obrigatório)
1. Issue-first, PR-driven (toda tarefa = Issue; todo deploy = PR que menciona a Issue). Conventional Commits.
2. UI: skeleton, lazy loading, animações de entrada/saída/carregamento/progresso; prefers-reduced-motion; só transform/opacity.
3. Observabilidade: OpenTelemetry base + Sentry + Datadog/New Relic.
4. Qualidade: Biome, contratos de arquitetura, Commitlint, Knip, Stryker.
5. Testes: unit + integração + E2E (Playwright), cobertura no Codecov.
```
