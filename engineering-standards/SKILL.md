---
name: engineering-standards
description: >-
  Padrão único de engenharia do usuário (workflow, UI/motion, observabilidade, qualidade, testes e
  arsenal de MCPs/skills). Use SEMPRE que for iniciar, planejar ou revisar trabalho em qualquer
  projeto — ao "criar issue/PR", "gerenciar deploy", "montar/revisar tela ou UI", "adicionar
  skeleton/lazy loading/animação", "configurar observabilidade/Sentry/OpenTelemetry", "setar
  lint/qualidade/testes/CI", "definir os padrões do projeto", ou quando o usuário disser "seguir os
  padrões", "aplicar os standards", "config de IA". Também ao alimentar CLAUDE.md/AGENTS.md.
  English: the user's central engineering standards — apply on any new/planned/reviewed work.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebFetch
metadata:
  version: "1.0.0"
  author: vulca
---

# Engineering Standards — Padrão Único

Skill **central** que consolida a configuração de IA do usuário (`~/ai_config/`) num padrão
obrigatório para **qualquer agente de qualquer modelo**. A especificação completa e legível está em
`references/ai-engineering-standards.md`; os detalhes operacionais por domínio estão nos demais
arquivos de `references/`. **Leia sob demanda** — só o domínio relevante à tarefa, não tudo de uma vez.

## Quando aplicar

Aplique proativamente em **todo** início/planejamento/review de trabalho. Se o repositório ainda não
tem os padrões no `CLAUDE.md`/`AGENTS.md`, ofereça alimentá-lo (ver `references/workflow-github.md` §
bootstrap).

## Os 4 pilares (sempre valem)

1. **Workflow — Issue-first, PR-driven.** Toda tarefa (Correção / Melhoria / Nova função) começa
   numa **Issue**; todo deploy passa por um **PR que menciona a Issue** (`Closes #N`). Conventional
   Commits. Alimente o `CLAUDE.md`/`AGENTS.md` do projeto. → `references/workflow-github.md`
2. **Motion & UI.** Toda interface tem **skeleton, lazy loading e animações suaves de entrada,
   saída, carregamento e progresso**. Honrar `prefers-reduced-motion`; animar só `transform`/
   `opacity`; nunca `transition: all`. Aplicar o Frequency Gate + Web Interface Guidelines.
   → `references/motion-and-ui.md`
3. **Observabilidade + Qualidade + Testes.** OpenTelemetry como base + Sentry/Datadog/New Relic;
   Biome, contratos de arquitetura, Commitlint, Knip, Stryker; unit + integração + E2E (Playwright)
   com cobertura no Codecov. → `references/observability-quality-testing.md`
4. **Arsenal.** Use as ferramentas certas: shadcn-ui-mcp, 21st.dev Magic, chrome-devtools-mcp,
   design-motion-principles, web-design-guidelines, humanizer. → `references/arsenal-mcp-skills.md`

## Fluxo recomendado

1. **Orientar:** identifique o tipo de trabalho e leia apenas a(s) referência(s) do(s) domínio(s)
   envolvido(s).
2. **Aplicar:** siga o pilar; para UI, garanta os cinco estados (skeleton/lazy/enter/exit/progress);
   para features, garanta o gate de CI (lint→types→arch→knip→testes→cobertura→build).
3. **Propagar:** garanta o bloco de bootstrap no `CLAUDE.md`/`AGENTS.md` do repo (self-enforcing).
4. **Fechar:** valide contra a Definition of Done em `references/ai-engineering-standards.md` §5.

## Índice de referências

| Arquivo | Carregue quando |
|---|---|
| `references/ai-engineering-standards.md` | Precisar da spec completa, DoD ou bloco de bootstrap |
| `references/workflow-github.md` | Criar Issue/PR, gerenciar deploy, alimentar CLAUDE.md |
| `references/motion-and-ui.md` | Construir/revisar qualquer tela ou animação |
| `references/observability-quality-testing.md` | Configurar o11y, lint/qualidade, testes/CI |
| `references/arsenal-mcp-skills.md` | Escolher/instalar um MCP server ou skill |
