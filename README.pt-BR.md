# AI Engineering Standards

[English](README.md) · **Português**

> Padrão único de engenharia para agentes de IA, empacotado como uma **skill centralizada do Claude
> Code**. Uma fonte da verdade, aplicada de forma consistente por qualquer agente de qualquer modelo,
> em qualquer projeto.

![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-6C4BF6)
![Scope](https://img.shields.io/badge/scope-global%20%7C%20per%20project-informational)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## O que é

Este repositório transforma uma configuração pessoal de IA (`prompts.txt` mais `skills.txt`) em um
**padrão de engenharia formal, versionável e instalável**. Ele entrega:

1. **`ai-engineering-standards.md`**: a especificação completa e legível (fonte única da verdade).
2. **Skill `engineering-standards`**: o mesmo conhecimento empacotado para o Claude Code, com
   progressive disclosure (carrega só o domínio relevante à tarefa, para máxima performance de
   contexto).
3. **`install-skill.sh`**: o comando que importa tudo como skill **centralizada** em
   `~/.claude/skills/` e registra o slash command `/standards`.

O objetivo: quando qualquer agente de IA começa, planeja ou revisa um trabalho, ele aplica
automaticamente os mesmos padrões de workflow, UI, observabilidade, qualidade e testes.

## Os 4 pilares

| # | Pilar | Resumo |
|---|---|---|
| 1 | **Workflow e Governança** | Issue first, PR driven. Toda tarefa (Correção/Melhoria/Nova função) começa numa **Issue**; todo deploy passa por um **PR que referencia a Issue** (`Closes #N`). Conventional Commits. Alimenta o `CLAUDE.md`/`AGENTS.md` do projeto. |
| 2 | **Motion e UI/UX** | Toda interface tem **skeleton, lazy loading e animações de entrada/saída/carregamento/progresso**. Honra `prefers-reduced-motion`; anima só `transform`/`opacity`. Frequency Gate mais Web Interface Guidelines. |
| 3 | **Observabilidade, Qualidade, Testes** | OpenTelemetry (base) mais Sentry/Datadog/New Relic; Biome, contratos de arquitetura, Commitlint, Knip, Stryker; unit mais integração mais E2E (Playwright) com cobertura no Codecov. |
| 4 | **Arsenal (MCP e Skills)** | A ferramenta certa por tarefa: shadcn-ui-mcp, 21st.dev Magic, chrome-devtools-mcp, design-motion-principles, web-design-guidelines, humanizer. |

## Estrutura do repositório

```
.
├── README.md                          # versão em inglês
├── README.pt-BR.md                    # este arquivo (português)
├── LICENSE                            # MIT
├── .gitignore                         # ignora artefatos de build (.tar.gz/.zip)
├── ai-engineering-standards.md        # a especificação completa (fonte única da verdade)
├── install-skill.sh                   # importador: instala a skill em ~/.claude/skills/ + /standards
├── engineering-standards/             # a skill (payload que é importado)
│   ├── SKILL.md                       # hub enxuto (dispara sozinho)
│   └── references/                    # deep dives por domínio (carregados sob demanda)
│       ├── workflow-github.md
│       ├── motion-and-ui.md
│       ├── observability-quality-testing.md
│       └── arsenal-mcp-skills.md
└── docs/origin/                       # proveniência: config original que originou o padrão
    ├── prompts.txt                    # pilares 1 a 3
    └── skills.txt                     # arsenal do pilar 4
```

## Instalação rápida

```bash
# clone onde quiser; o nome da pasta é livre
git clone https://github.com/DouglasVulcano/ai-engineering-standards.git
cd ai-engineering-standards
bash install-skill.sh
```

O instalador é **idempotente** e independente de localização (resolve o próprio caminho), então rode
a partir da raiz do repo, onde quer que você tenha clonado. Ele copia a skill para
`~/.claude/skills/engineering-standards/`, empacota a spec completa em `references/` e cria o comando
`/standards`. Reabra o Claude Code (ou rode `/skills`) e pronto.

**Escopo por projeto** (em vez de global), instalando dentro de um repo específico (rode da raiz do repo):
```bash
CLAUDE_DIR=./.claude bash install-skill.sh
```

## Como usar

- **Automático**: a skill dispara sozinha quando o seu pedido casa com os gatilhos: "crie a
  issue/PR", "revise a UI", "adicione skeleton/lazy loading", "configure observabilidade", "siga os
  padrões", e assim por diante.
- **Explícito**: o slash command:
  ```
  /standards            # aplica tudo
  /standards ui         # só motion/UI
  /standards workflow   # só Issues/PR/deploy
  /standards o11y       # só observabilidade
  /standards testing    # só qualidade/testes
  /standards arsenal    # escolher ou instalar um MCP ou skill
  ```

Ao trabalhar num repositório, a skill também garante o **bloco de bootstrap** no `CLAUDE.md`/
`AGENTS.md`, tornando o padrão self enforcing para os próximos agentes, de qualquer modelo.

## Instalar em outra máquina / outro Claude

**Claude Code (CLI/IDE)**: clone o repo e rode `install-skill.sh` (como acima). Para atualizar, a
partir da pasta do clone:
```bash
git pull && bash install-skill.sh
```

**Sem git**: gere um pacote a partir da pasta do repo (`tar -czf ai-standards.tar.gz -C <pasta-do-repo> .`),
leve para a outra máquina, extraia em qualquer pasta e rode `bash install-skill.sh` dentro dela.

**Claude Desktop / claude.ai (web)**: não usam `~/.claude`. Instale pela UI de Skills fazendo upload
da pasta `engineering-standards/` (compacte antes). O slash command `/standards` é exclusivo do
Claude Code e não se aplica lá.

> Nota: MCP servers com API key (21st.dev, shadcn, chrome-devtools) não viajam automaticamente;
> precisam ser reconfigurados na nova máquina. Comandos em
> [`engineering-standards/references/arsenal-mcp-skills.md`](engineering-standards/references/arsenal-mcp-skills.md).

## Editar e evoluir o padrão

1. Edite os arquivos-fonte no clone (o `ai-engineering-standards.md` e/ou a skill).
2. Reinstale: `bash install-skill.sh`.
3. Commit mais push. Nas outras máquinas: `git pull && bash install-skill.sh`.

Mantenha o `ai-engineering-standards.md` como a narrativa completa e as `references/*` como as
unidades operacionais enxutas (é o que preserva a performance de contexto).

## Arsenal (referências externas)

| Ferramenta | Tipo | Uso |
|---|---|---|
| [humanizer](https://github.com/blader/humanizer) | Skill | Deixar copy/docs com tom humano |
| [21st.dev Magic](https://github.com/21st-dev/magic-mcp) | MCP | Gerar/descobrir UI (React/Tailwind) |
| [shadcn-ui-mcp-server](https://github.com/Jpisnice/shadcn-ui-mcp-server) | MCP | Componentes shadcn/ui (código/blocks) |
| [web-design-guidelines](https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines) | Skill | Auditar UI (a11y/UX) |
| [chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | MCP | Perf/erros no browser real |
| [design-motion-principles](https://github.com/kylezantos/design-motion-principles) | Skill | Motion correto / auditar animações |

## O que **não** é automático (por segurança)

- A skill **orienta minhas decisões**, mas não executa ações destrutivas nem instala MCPs com API
  key sem a sua confirmação.
- Regras que precisam ser **mecanicamente obrigatórias** (rodar lint no pre commit, bloquear merge
  sem Issue) pertencem a **hooks / branch protection / CI**, não a uma skill.

## Créditos

Padrões destilados da configuração pessoal do autor e dos projetos referenciados no Arsenal.
Especificação completa em [`ai-engineering-standards.md`](ai-engineering-standards.md).

## Licença

MIT, sinta-se livre para adaptar ao seu fluxo.
