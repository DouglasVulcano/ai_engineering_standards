# AI Engineering Standards — Padrão Único de Trabalho

> **Fonte única da verdade** para qualquer agente de IA (qualquer modelo) que trabalhe nos
> projetos do usuário. Consolida e formaliza a configuração pessoal em `~/ai_config/prompts.txt`
> e `~/ai_config/skills.txt`, enriquecida com as melhores práticas dos recursos referenciados.
>
> **Como usar:** este documento é a versão completa e legível. A versão operacional e
> "carregada sob demanda" vive na skill `engineering-standards` (`~/.claude/skills/`).
> Para tornar o padrão obrigatório em um projeto, copie o bloco de bootstrap da §6 para o
> `CLAUDE.md` / `AGENTS.md` do repositório.

| | |
|---|---|
| **Versão** | 1.0.0 |
| **Autor** | vulca |
| **Data** | 2026-09-11 |
| **Escopo** | Global — aplica-se a todos os projetos, salvo override explícito do repositório |

---

## 0. Sumário

1. [Workflow de Engenharia & Governança](#1-workflow-de-engenharia--governança) — *(prompts.txt #1)*
2. [Motion & UI/UX](#2-motion--uiux) — *(prompts.txt #2 + design-motion-principles + web-interface-guidelines)*
3. [Observabilidade, Qualidade & Testes](#3-observabilidade-qualidade--testes) — *(prompts.txt #3)*
4. [Arsenal: MCP Servers & Skills](#4-arsenal-mcp-servers--skills) — *(skills.txt)*
5. [Definition of Done (checklists)](#5-definition-of-done-checklists)
6. [Bootstrap: tornar o padrão obrigatório](#6-bootstrap-tornar-o-padrão-obrigatório)
7. [Apêndice: rastreabilidade com os arquivos originais](#7-apêndice-rastreabilidade)

---

## 1. Workflow de Engenharia & Governança

> **Origem:** `prompts.txt` #1 — "Crie Issues no GitHub para todas as Tarefas (Correção, Melhoria
> ou Nova função) que faremos e trabalhe com PRs para gerenciar os Deploys. Lembre de Mencionar a
> Issue na descrição do PR. Alimente o arquivo.md do projeto com essas instruções para que qualquer
> agente de qualquer modelo considere esse padrão."

### 1.1 Princípio central — *Issue-first, PR-driven*

**Nenhum trabalho começa sem uma Issue. Nenhum código chega em produção sem um PR.** Toda
mudança é rastreável de ponta a ponta: `Issue → Branch → PR → Review → Merge → Deploy`.

### 1.2 Taxonomia de Issues

Toda tarefa é classificada em uma das três categorias (labels obrigatórias):

| Categoria | Label | Prefixo de branch | Prefixo de commit |
|---|---|---|---|
| **Correção** (bug) | `type: fix` | `fix/<issue>-<slug>` | `fix:` |
| **Melhoria** (refactor/perf/DX) | `type: improvement` | `chore/` ou `refactor/<issue>-<slug>` | `refactor:` / `perf:` / `chore:` |
| **Nova função** (feature) | `type: feature` | `feat/<issue>-<slug>` | `feat:` |

Labels de apoio recomendadas: `priority: p0..p3`, `area: <domínio>`, `status: in-progress`.

### 1.3 Template de Issue

```markdown
## Contexto
<por que isso existe — problema, oportunidade ou dor>

## Objetivo / Critério de aceite
- [ ] <condição verificável 1>
- [ ] <condição verificável 2>

## Escopo
- Inclui: ...
- Não inclui: ...

## Notas técnicas
<arquivos prováveis, riscos, dependências, telas afetadas>
```

Criação via CLI:
```bash
gh issue create --title "feat: <resumo>" --label "type: feature,priority: p2" \
  --body-file .github/ISSUE_TEMPLATE/feature.md
```

### 1.4 Branches & Commits

- **Uma branch por Issue.** Nome: `<tipo>/<numero-da-issue>-<slug-curto>` — ex.: `feat/142-login-otp`.
- **Conventional Commits** obrigatórios: `feat:`, `fix:`, `refactor:`, `perf:`, `docs:`, `test:`,
  `build:`, `ci:`, `chore:`. Isso alimenta o `commitlint` (§3.2) e o changelog/semver automático.
- Referencie a Issue no corpo do commit quando fizer sentido: `Refs #142`.

### 1.5 Pull Requests — gestão de deploy

- **O PR é a unidade de deploy.** Merge na branch de release/produção = deploy.
- **Toda descrição de PR menciona a Issue** com uma *closing keyword* para fechá-la no merge:
  `Closes #142`, `Fixes #143`, `Resolves #144`.
- PR pequeno e focado (idealmente < 400 linhas de diff). Um PR = uma Issue.
- Checks obrigatórios antes do merge (branch protection): lint, types, testes, cobertura, build.

**Template de PR** (`.github/pull_request_template.md`):
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
- [ ] Segue os AI Engineering Standards (workflow, motion/UI, o11y/qualidade/testes)
- [ ] Testes adicionados/atualizados (unit/integração/e2e conforme aplicável)
- [ ] Observabilidade instrumentada (erros/spans) quando houver novo fluxo
- [ ] `prefers-reduced-motion` respeitado em novas animações
- [ ] Sem regressão de lint/types/knip
```

Criação via CLI:
```bash
gh pr create --fill --base main \
  --title "feat: <resumo>" \
  --body "Closes #142

## Resumo
..."
```

### 1.6 Estratégia de branches / deploy

Padrão recomendado (ajustar por projeto e documentar no `CLAUDE.md`):

- **Trunk-based** com `main` sempre deployável; feature branches curtas; merge via PR (squash).
- Ambientes: **preview por PR** (ex.: Vercel/Netlify) → **staging** (opcional) → **production** (merge em `main`/`release`).
- Rollback = reverter o PR (`gh pr revert` / `git revert`) — nunca hotfix direto em produção sem Issue+PR.

### 1.7 Regra de propagação (o ponto mais importante)

> **Alimente o `arquivo.md` do projeto** para que *qualquer agente de qualquer modelo* siga o padrão.

Em **todo** repositório, o agente deve garantir que exista um `CLAUDE.md` (e/ou `AGENTS.md`)
contendo o **bloco de bootstrap da §6**. Se o arquivo não existir, criá-lo; se existir, fazer
merge sem apagar conteúdo. Isso torna o padrão *self-enforcing*: o próximo agente lê o arquivo e
já segue as regras, independentemente do modelo.

---

## 2. Motion & UI/UX

> **Origem:** `prompts.txt` #2 — "Utilize a Skill Motion Principles (github.com/kylezantos/design-
> motion-principles) e garanta que toda interface do sistema tem skeleton, lazy loading, smooth
> animation de entrada, saída, carregamento, progresso em todos os elementos."
>
> Enriquecido com **design-motion-principles** (Emil Kowalski / Jakub Krehel / Jhey Tompkins) e
> as **Web Interface Guidelines** da Vercel (`vercel-labs/web-interface-guidelines`).

### 2.1 Estados obrigatórios em TODO elemento assíncrono ou dinâmico

Nenhuma tela vai para review sem os cinco estados abaixo cobertos:

1. **Skeleton / placeholder** — enquanto dados carregam (nunca "tela branca" ou layout shift).
2. **Lazy loading** — imagens abaixo da dobra (`loading="lazy"`), rotas e componentes pesados via
   `code-splitting` / `React.lazy` + `Suspense`; listas grandes virtualizadas (§3, perf).
3. **Animação de entrada** (enter) — aparecimento suave de conteúdo/rotas/modais.
4. **Animação de saída** (exit) — desmontagem suave (`AnimatePresence` ou equivalente) — nunca
   "sumir" abruptamente.
5. **Carregamento & progresso** — spinners/estados de loading em ações; barras/indicadores de
   progresso em operações longas ou multi-etapa; botões de submit mostram estado de envio.

### 2.2 Princípios de Motion (design-motion-principles)

**The Frequency Gate** — decida *se* deve animar antes de *como*:

| Frequência do gatilho | Recomendação |
|---|---|
| Raro (mensal) | Motion expressivo/deleitoso é bem-vindo |
| Ocasional (diário) | Motion sutil e rápido |
| Frequente (centenas/dia) | Sem animação ou transição instantânea |
| Iniciado por teclado | **Nunca animar** |

**Durações** (dependentes de contexto — não universalizar):

| Contexto | Guia |
|---|---|
| UI de produtividade (lente Emil) | < 300ms; **180ms ideal** |
| Polish de produção (lente Jakub) | 200–500ms |
| Criativo / infantil / lúdico (lente Jhey) | a duração serve ao efeito |

**Regras de ouro:**
- *"A melhor animação é a que passa despercebida."* Se usuários elogiam a animação com
  frequência, provavelmente está proeminente demais para produção (exceção: apps lúdicos/infantis).
- **Acessibilidade é obrigatória:** toda animação respeita `prefers-reduced-motion` — sem exceções.
- Animar **apenas `transform` e `opacity`** (compositor-friendly). Nunca `transition: all`.
- Animações devem ser **interrompíveis** — responder à entrada do usuário no meio.
- **Motion Gap Analysis:** procure ativamente mudanças condicionais de UI sem animação
  (renders condicionais sem `AnimatePresence`, estilos dinâmicos sem `transition`).

**Ponderação por tipo de projeto** (qual lente priorizar):

| Projeto | Primária | Secundária | Seletiva |
|---|---|---|---|
| Ferramenta de produtividade / SaaS dashboard | Emil (velocidade) | Jakub (polish) | Jhey (onboarding/empty states) |
| App infantil / educacional / portfólio criativo | Jakub | Jhey | Emil (alta frequência) |
| Landing / marketing | Jakub | Jhey | Emil (forms, nav) |
| Mobile / e-commerce | Jakub | Emil | Jhey (delighters/showcase) |

### 2.3 Web Interface Guidelines (checklist de review de UI)

Aplicar em toda revisão de UI (fonte: `vercel-labs/web-interface-guidelines`, buscar versão mais
recente via a skill `web-design-guidelines` quando disponível).

**Acessibilidade**
- Botões só-ícone precisam de `aria-label`; controles de form precisam de `<label>`/`aria-label`.
- Elementos interativos precisam de handlers de teclado; use `<button>` para ações e `<a>`/`<Link>`
  para navegação (nunca `<div onClick>`).
- Imagens com `alt` (ou `alt=""` se decorativa); ícones decorativos com `aria-hidden="true"`.
- Atualizações assíncronas (toasts, validação) com `aria-live="polite"`. Prefira HTML semântico a ARIA.
- Headings hierárquicos (`h1`–`h6`) + skip link; âncoras com `scroll-margin-top`.

**Foco**
- Foco visível em todo interativo (`focus-visible:ring-*`); nunca `outline-none` sem substituto.
- Prefira `:focus-visible`; use `:focus-within` para controles compostos.
- Headers/overlays sticky não podem obscurecer o elemento focado.

**Forms**
- Inputs com `autocomplete` e `name` significativos; `type`/`inputmode` corretos
  (`email`, `tel`, `url`, `number`).
- Nunca bloquear colar (`onPaste` + `preventDefault`); labels clicáveis (`htmlFor`/wrapping).
- `spellCheck={false}` em email/código/username; erros inline ao lado do campo; focar o 1º erro no submit.
- Submit habilitado até o request começar; mostrar spinner durante o request.
- Placeholders terminam em `…` e mostram um exemplo; avisar antes de sair com mudanças não salvas.

**Animação** — ver §2.2 (honrar reduced-motion; só `transform`/`opacity`; interrompível;
`transform-origin` correto; loops decorativos param sob reduced-motion).

**Tipografia**
- Reticências `…` (não `...`); aspas curvas `" "`; `&nbsp;` em `10&nbsp;MB`, `⌘&nbsp;K`, marcas.
- Estados de loading terminam em `…`; `font-variant-numeric: tabular-nums` em colunas de números;
  `text-wrap: balance`/`text-pretty` em headings.

**Conteúdo & layout**
- `truncate`/`line-clamp-*`/`break-words` para textos longos; filhos flex com `min-w-0`.
- Tratar **estados vazios** (não renderizar UI quebrada para arrays/strings vazias).
- Antecipar inputs curtos, médios e muito longos.

**Imagens & performance** — ver §3.3 (dimensões explícitas para evitar CLS, `loading="lazy"`,
`priority`/`fetchpriority`, virtualização de listas > 50 itens, `preconnect`/`preload` de fontes).

**Navegação & estado**
- URL reflete o estado (filtros, tabs, paginação, painéis) via query params — deep-link tudo (nuqs
  ou similar). Links reais permitem Cmd/Ctrl+click e middle-click.
- Ações destrutivas exigem confirmação **ou** janela de undo — nunca imediatas.

**Touch, dark mode, i18n, hidratação** — `touch-action: manipulation`,
`overscroll-behavior: contain` em modais; `color-scheme` + `theme-color` para dark mode;
`Intl.DateTimeFormat`/`Intl.NumberFormat` (nunca formatos hardcoded); guardar render de datas
contra mismatch de hidratação.

**Copy**
- Voz ativa; Title Case em headings/botões; numerais para contagens ("8 deployments").
- Labels específicos ("Save API Key", não "Continue"); mensagens de erro incluem o próximo passo.

---

## 3. Observabilidade, Qualidade & Testes

> **Origem:** `prompts.txt` #3 — "Garanta que o sistema tenha: Observabilidade (Sentry, Datadog,
> NewRelic, OpenTelemetry); Qualidade e Lint de Código (Arch-contract, Biome, Commitlint, Knip,
> Stryker); Testes unitários e integração e end-to-end (Codecov, Playwright)."

### 3.1 Observabilidade (os três pilares: logs, métricas, traces)

| Ferramenta | Papel | Uso recomendado |
|---|---|---|
| **OpenTelemetry (OTel)** | Padrão vendor-neutral de instrumentação | **Base de tudo.** Instrumente traces/metrics/logs com OTel SDK e exporte via OTLP para o backend escolhido. Evita lock-in. |
| **Sentry** | Erros + performance + session replay (front e back) | Captura de exceções, source maps, `tracesSampleRate`, release health, alertas. Ideal no frontend. |
| **Datadog** | APM + métricas + logs + dashboards | Backend/infra; receber OTLP do OTel Collector; RUM opcional. |
| **New Relic** | APM + métricas | Alternativa/complemento ao Datadog; também recebe OTLP. |

**Melhores práticas**
- **Uma camada OTel, múltiplos exportadores.** Instrumente uma vez; direcione para Datadog/New Relic
  via **OpenTelemetry Collector** (OTLP). Sentry para erros de UX/frontend.
- Propague **trace context** ponta a ponta (W3C `traceparent`); correlacione logs↔traces por `trace_id`.
- Defina **SLIs/SLOs**, alertas acionáveis e um dashboard mínimo por serviço (latência p95, erro %, saturação).
- Sampling consciente de custo (`tracesSampleRate`, tail sampling no Collector).
- Nunca logar PII/segredos; scrubbing no SDK/Collector.

### 3.2 Qualidade & Lint de Código

| Ferramenta | Categoria | O que faz / melhores práticas |
|---|---|---|
| **Contratos de arquitetura** *("Arch-contract")* | Regras de dependência | Impõe fronteiras entre camadas/módulos (proibir imports cruzados). Ferramentas: **dependency-cruiser**, **eslint-plugin-boundaries**, **ts-arch**. Rode em CI e falhe o PR na violação. |
| **Biome** | Formatter + Linter (Rust) | Substitui ESLint+Prettier com um binário rápido. `biome check --write`; rode em pre-commit e CI. |
| **Commitlint** | Convenção de commits | Valida **Conventional Commits** (§1.4) via hook `commit-msg` (**husky**/**lefthook**). Habilita changelog/semver automático. |
| **Knip** | Dead code | Detecta arquivos, exports, deps e types não usados. `knip` em CI para manter o repo enxuto. |
| **Stryker** | Mutation testing | Mede a **qualidade** dos testes injetando mutações. Alvo de *mutation score* por pacote crítico; não precisa rodar em todo PR (nightly/por área). |

**Ordem de gates em CI (falha rápida):** `format → lint (biome) → typecheck → arch-contract → knip → testes → cobertura → build`.

### 3.3 Testes & Cobertura

| Nível | Ferramenta | Alvo |
|---|---|---|
| **Unitário** | Vitest / Jest | Lógica pura, utils, hooks, componentes isolados. |
| **Integração** | Vitest/Jest + Testing Library / supertest | Módulos falando entre si, rotas de API, DB (containers de teste). |
| **End-to-end (E2E)** | **Playwright** | Fluxos críticos reais no browser (login, checkout, etc.); rodar cross-browser; usar `data-testid`. |
| **Cobertura** | **Codecov** | Publicar relatório de cobertura no CI e no PR; definir *status checks*/threshold; comentar diff coverage. |
| **Qualidade dos testes** | **Stryker** | Mutation score como métrica de confiança (§3.2). |

**Melhores práticas**
- **Pirâmide de testes:** muitos unitários, menos integração, poucos E2E (mas E2E cobrindo os
  caminhos de dinheiro/risco).
- E2E do Playwright também serve de smoke test pós-deploy nos previews de PR.
- Threshold de cobertura no Codecov como *required check* (não bloquear em números irreais; foco em
  diff coverage).
- Testes determinísticos (sem flaky): retries controlados, dados isolados, relógio/rede mockados.

---

## 4. Arsenal: MCP Servers & Skills

> **Origem:** `skills.txt` (5 recursos) + a skill de motion do `prompts.txt` #2. Instale por
> projeto ou globalmente conforme o uso. **MCP servers com API key não são instalados
> automaticamente** — exigem chave e alteram sua config; use os comandos abaixo quando decidir.

### 4.1 Skills (conhecimento carregado sob demanda)

**humanizer** — `github.com/blader/humanizer`
Reescreve texto gerado por IA para soar humano (25 padrões: vocabulário genérico, ritmo artificial,
inflação de significância, etc.), preservando fatos. Use em copy, docs, READMEs, posts.
```bash
# Claude Code (plugin)
/plugin marketplace add blader/humanizer
/plugin install humanizer@humanizer
# ou, para qualquer agente (skills CLI)
npx skills add blader/humanizer --global
```
Uso: `/humanizer <texto>` ou "humanize a prosa em docs/launch-post.md". Dica: forneça 2–3 parágrafos
seus para *voice matching*.

**web-design-guidelines** — `github.com/vercel-labs/agent-skills/.../web-design-guidelines`
Revisa código de UI contra as **Web Interface Guidelines** (§2.3). Busca a versão mais recente das
regras de `vercel-labs/web-interface-guidelines`. Gatilhos: "review my UI", "check accessibility",
"audit design".
```bash
npx skills add vercel-labs/agent-skills/skills/web-design-guidelines --global
```

**design-motion-principles** — `github.com/kylezantos/design-motion-principles`
Especialista em motion (lentes Emil Kowalski / Jakub Krehel / Jhey Tompkins), dois modos:
**Create** (construir com motion proposital) e **Audit** (revisar animações e caçar "AI-slop",
gerando relatório HTML com demos). Base da §2.2.
```bash
npx skills add kylezantos/design-motion-principles
```

### 4.2 MCP Servers

**21st.dev Magic** *(antigo `21st-dev/magic-mcp`, hoje proxy do 21st MCP)* — `github.com/21st-dev/magic-mcp`
Busca 10.000+ componentes React/Tailwind, gera UI com IA e publica os seus, direto do editor.
Requer API key de https://21st.dev/mcp.
```bash
# CLI recomendada
npx @21st-dev/cli@latest init --client claude
```
```jsonc
// Configuração manual (HTTP MCP)
{ "mcpServers": { "21st": {
  "url": "https://21st.dev/api/mcp",
  "headers": { "x-api-key": "YOUR_21ST_API_KEY" }
} } }
```
Tools: `generate`, `get_inspiration`, `search_logo` (nomes legados `21st_magic_component_*` ainda
funcionam). Verifique `get_usage.aiGenerationEnabled` antes de gerar.

**shadcn-ui-mcp-server** — `github.com/Jpisnice/shadcn-ui-mcp-server`
Dá ao agente o código-fonte, demos e *blocks* dos componentes shadcn/ui (React/Svelte/Vue/React
Native). Use um **GitHub token** para subir o rate limit de 60 → 5.000 req/h.
```bash
claude mcp add shadcn -- bunx -y @jpisnice/shadcn-ui-mcp-server --github-api-key YOUR_TOKEN
# framework alternativo:
npx @jpisnice/shadcn-ui-mcp-server --framework svelte   # | vue | react-native
```

**chrome-devtools-mcp** — `github.com/ChromeDevTools/chrome-devtools-mcp`
Controla e inspeciona um Chrome real (Puppeteer): análise de performance (traces do DevTools),
debug (network, screenshots, console com stack maps) e automação de browser. Ótimo par com o
Playwright (§3.3) para investigar regressões de UI/perf.
```jsonc
{ "mcpServers": { "chrome-devtools": {
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest"]      // + "--slim", "--headless" p/ tarefas simples
} } }
```
⚠️ Expõe o conteúdo do browser ao cliente MCP — conecte só a clientes confiáveis, sem dados sensíveis.

### 4.3 Quando usar o quê

| Preciso de… | Use |
|---|---|
| Componente shadcn/ui (código real, blocks) | **shadcn-ui-mcp-server** |
| Gerar/descobrir UI nova (React/Tailwind) | **21st.dev Magic** |
| Garantir motion correto / auditar animações | **design-motion-principles** |
| Revisar UI contra guidelines de acessibilidade/UX | **web-design-guidelines** |
| Investigar performance/erros no browser real | **chrome-devtools-mcp** |
| Deixar copy/docs com tom humano | **humanizer** |

---

## 5. Definition of Done (checklists)

**Toda tarefa (§1)**
- [ ] Existe Issue classificada (Correção/Melhoria/Nova função) com critério de aceite.
- [ ] Branch nomeada por convenção; commits em Conventional Commits.
- [ ] PR aberto mencionando a Issue (`Closes #`); PR pequeno e focado.
- [ ] `CLAUDE.md`/`AGENTS.md` do projeto contém o bootstrap dos padrões.

**Toda UI (§2)**
- [ ] Skeleton + lazy loading + enter/exit + loading/progress cobertos.
- [ ] `prefers-reduced-motion` honrado; só `transform`/`opacity`; sem `transition: all`.
- [ ] Frequency Gate aplicado; durações no alvo do contexto.
- [ ] Checklist de Web Interface Guidelines revisado (a11y, foco, forms, tipografia, estados vazios).

**Todo serviço/feature (§3)**
- [ ] Observabilidade: erros (Sentry) + traces/metrics (OTel → Datadog/New Relic) no novo fluxo.
- [ ] Qualidade: passa em biome, typecheck, arch-contract, knip; commitlint no hook.
- [ ] Testes: unit + integração; E2E (Playwright) nos fluxos críticos; cobertura publicada (Codecov).

---

## 6. Bootstrap: tornar o padrão obrigatório

Cole este bloco no `CLAUDE.md` (e/ou `AGENTS.md`) de **cada** repositório. É o que torna o padrão
*self-enforcing* para qualquer agente de qualquer modelo (§1.7).

```markdown
## AI Engineering Standards (obrigatório)

Este projeto segue os **AI Engineering Standards** do usuário. Antes de qualquer tarefa, aplique-os
(skill `engineering-standards`; fonte completa em `~/ai_config/ai-engineering-standards.md`):

1. **Workflow:** Issue-first, PR-driven. Toda tarefa (Correção/Melhoria/Nova função) começa numa
   Issue; todo deploy passa por PR que menciona a Issue (`Closes #`). Conventional Commits.
2. **Motion & UI:** toda interface tem skeleton, lazy loading e animações suaves de entrada, saída,
   carregamento e progresso. Honrar `prefers-reduced-motion`; animar só `transform`/`opacity`.
   Seguir as Web Interface Guidelines (a11y, foco, forms, tipografia).
3. **Observabilidade:** OpenTelemetry como base; Sentry (erros) + Datadog/New Relic (APM).
4. **Qualidade:** Biome, contratos de arquitetura, Commitlint, Knip, Stryker.
5. **Testes:** unit + integração + E2E (Playwright), cobertura no Codecov.

Ferramentas disponíveis: shadcn-ui-mcp, 21st.dev Magic, chrome-devtools-mcp, design-motion-principles,
web-design-guidelines, humanizer.
```

---

## 7. Apêndice: rastreabilidade

| Arquivo original | Item | Onde virou padrão |
|---|---|---|
| `prompts.txt` | #1 Issues/PRs/Deploys + alimentar `.md` | §1 (todo) + §6 bootstrap |
| `prompts.txt` | #2 Motion Principles + skeleton/lazy/animações | §2 (todo) |
| `prompts.txt` | #3 Observabilidade/Qualidade/Testes | §3 (todo) |
| `skills.txt` | humanizer | §4.1 |
| `skills.txt` | 21st-dev/magic-mcp | §4.2 |
| `skills.txt` | shadcn-ui-mcp-server | §4.2 |
| `skills.txt` | web-design-guidelines | §4.1 + §2.3 |
| `skills.txt` | chrome-devtools-mcp | §4.2 |

**Correções aplicadas ao interpretar os originais:** `kylezantos/design-principles` →
`kylezantos/design-motion-principles`; "Comilint" → **Commitlint**; "Stryke" → **Stryker**;
"Arch-contract" → **contratos de arquitetura** (dependency-cruiser / eslint-plugin-boundaries / ts-arch).
