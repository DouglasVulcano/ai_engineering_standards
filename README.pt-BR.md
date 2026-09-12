<p align="center">
  <img src="docs/logo.svg" alt="AI Engineering Standards" width="96" height="96">
</p>

<h1 align="center">AI Engineering Standards</h1>

<p align="center">
  <a href="https://douglasvulcano.github.io/ai_engineering_standards/pt-br/"><b>Site</b></a> · <a href="README.md">English</a> · <b>Português</b>
</p>

> Um padrão único e agnóstico de stack para agentes de IA, empacotado como **plugin e skill do Claude
> Code**, com um **scaffolder de governança**. Uma fonte da verdade, aplicada de forma consistente por
> qualquer agente de qualquer modelo, em qualquer projeto e linguagem.

![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin%20%2B%20skill-6C4BF6)
![Agnostic](https://img.shields.io/badge/stack-agnostic-success)
![Scope](https://img.shields.io/badge/scope-global%20%7C%20project%20%7C%20team-informational)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## O que é

Um padrão distribuível que transforma configuração de IA solta em um pacote **formal, versionado e
instalável**. Entrega:

1. **`ai-engineering-standards.md`** a especificação completa e legível (fonte única da verdade).
2. **A skill `engineering-standards`** o mesmo conhecimento com progressive disclosure (carrega só o
   domínio relevante) mais um **scaffolder** e os **assets** de governança.
3. **Empacotamento de plugin** (`.claude-plugin/`) para distribuição versionada em time, e
   **`install-skill.sh`** para instalação pessoal global.

Objetivo: quando qualquer agente de IA começa, planeja ou revisa um trabalho, ele aplica o mesmo
padrão de workflow, UI, observabilidade, qualidade e testes, e pode fazer o scaffold da governança
que o reforça.

## Quickstart: o caminho de ouro

O padrão compensa quando o caminho inteiro está no lugar, não só a skill. De zero à governança
aplicada:

**1. Faça o scaffold da governança** (templates de issue/PR, CODEOWNERS, um CI gate, `AGENTS.md` +
um `CLAUDE.md` fino, um deny-list de segurança em `.claude`). Previa, depois aplique:

```bash
bash skills/engineering-standards/scaffold.sh /caminho/do/repo --dry-run
bash skills/engineering-standards/scaffold.sh /caminho/do/repo
```

**2. Preencha o `AGENTS.md`** com seu stack e os comandos do gate (veja o apêndice de stack), e
**3. defina owners reais** em `.github/CODEOWNERS` (as duas coisas que o scaffolder não adivinha).

**4. Arme a branch protection** no seu branch default, o gate autoritativo. Re-rode o scaffolder com
`--protect`, ou aplique você mesmo (API clássica de branch protection):

```bash
gh api -X PUT repos/OWNER/REPO/branches/main/protection --input - <<'JSON'
{ "required_pull_request_reviews": { "required_approving_review_count": 1, "require_code_owner_reviews": true },
  "required_status_checks": { "strict": true, "contexts": ["verify"] },
  "enforce_admins": true, "restrictions": null }
JSON
```

> Usando um **Ruleset** (o modelo mais novo do GitHub)? O formato muda: `enforce_admins` não é um
> status check (ele vira a bypass list), e o `contexts` do check exigido é o nome do job (aqui
> `verify`). Não jogue os campos da API clássica na lista de status-checks de um ruleset, senão a
> caixa de merge trava em "Expected - Waiting for status to be reported".

A skill é conselho; **CI mais branch protection são o que realmente aplica**. Só a skill dá o menor
retorno; o scaffolder mais um `AGENTS.md` preenchido mais o gate armado é onde está o valor.

> **Este repo roda no próprio padrão:** o `AGENTS.md`, o `.github/workflows/verify.yml` e o ruleset
> no `main` (exigindo o check `verify` mais review) são o mesmo setup que o scaffolder produz. É uma
> referência viva; veja [`docs/research-and-benchmarks.md`](docs/research-and-benchmarks.md) para as
> fixtures greenfield/brownfield verificadas ponta a ponta.

## Os 4 pilares

| # | Pilar | Resumo |
|---|---|---|
| 1 | **Workflow e Governança** | Issue-first, PR-driven. Toda tarefa é uma **Issue**; todo deploy é um **PR que a referencia** (`Closes #N`). Conventional Commits. Alimenta o **AGENTS.md** (canônico) com um **CLAUDE.md** fino que o importa. |
| 2 | **Motion e UI/UX** | Skeleton, lazy loading, animações de entrada/saída/carregamento/progresso; `prefers-reduced-motion`; anima só `transform`/`opacity`. Frequency Gate + Web Interface Guidelines. |
| 3 | **Observabilidade, Qualidade, Testes (agnóstico)** | OpenTelemetry para um Collector OTLP para qualquer backend; um gate de contratos de capacidade (`fmt, lint, typecheck, arch, deadcode, test, coverage, build`); Testcontainers + Playwright + Codecov. Comandos por stack no apêndice. |
| 4 | **Arsenal (MCP e Skills)** | A ferramenta certa por tarefa: shadcn-ui-mcp, 21st.dev Magic, chrome-devtools-mcp, design-motion-principles, web-design-guidelines, humanizer. |

## Estrutura do repositório

```
.
├── README.md / README.pt-BR.md        # docs (EN / PT)
├── AGENTS.md / CLAUDE.md              # guia do próprio repo (canônico + import fino)
├── CONTRIBUTING.md / CHANGELOG.md / SECURITY.md / LICENSE
├── ai-engineering-standards.md        # a especificação completa (fonte única da verdade)
├── install-skill.sh                   # instalador da skill global (+ comando /standards)
├── .claude-plugin/                    # plugin.json + marketplace.json (distribuição em time)
├── commands/standards.md              # o slash command /standards
├── scripts/verify.sh                  # self-check do repo (dogfood do pilar 3)
├── hooks/                             # guards PreToolUse do plugin (bloqueia Bash destrutivo / edição de segredos)
├── evals/                             # suíte claude plugin eval (braço de controle with/without)
├── skills/engineering-standards/       # a skill (payload instalado)
│   ├── SKILL.md                       # router enxuto (dispara sozinho)
│   ├── references/                    # deep dives por domínio (sob demanda)
│   │   ├── workflow-github.md · motion-and-ui.md
│   │   ├── observability-quality-testing.md · stack-appendix.md
│   │   └── arsenal-mcp-skills.md
│   ├── scaffold.sh                    # scaffolder de governança (seguro, idempotente)
│   └── assets/                        # templates de issue/PR, CODEOWNERS, CI gate, AGENTS/CLAUDE, settings
├── .github/workflows/verify.yml       # CI self-check
└── docs/                              # origin/ (proveniência) + research-and-benchmarks.md
```

## Instalação

**Plugin (recomendado para times; versionado, sem drift):**
```text
/plugin marketplace add DouglasVulcano/ai_engineering_standards
/plugin install engineering-standards
```
Atualize depois com `claude plugin update`.

**Skill global (pessoal):**
```bash
git clone https://github.com/DouglasVulcano/ai_engineering_standards.git
cd ai_engineering_standards
bash install-skill.sh
```
O instalador é idempotente e independente de localização; copia a skill (com o scaffolder e os
assets) para `~/.claude/skills/` e registra `/standards`. Escopo por projeto:
`CLAUDE_DIR=./.claude bash install-skill.sh`.

**Time / projeto inteiro (auto-habilitar para todos).** Commite um `.claude/settings.json` para que
qualquer pessoa que confie no repo receba o plugin automaticamente, sem passos manuais:
```json
{
  "extraKnownMarketplaces": {
    "ai_engineering_standards": { "source": { "source": "github", "repo": "DouglasVulcano/ai_engineering_standards" } }
  },
  "enabledPlugins": { "engineering-standards@ai_engineering_standards": true }
}
```
O scaffolder escreve isso para você:
`scaffold.sh <repo> --with-plugin DouglasVulcano/ai_engineering_standards`.

## Uso

- **Automático**: a skill dispara quando o pedido casa ("crie a issue/PR", "revise a UI", "configure
  observabilidade", "siga os padrões").
- **Explícito**: `/standards` (tudo) ou `/standards ui | workflow | o11y | testing | arsenal |
  scaffold`.

## Scaffold de governança em um repo

A feature de maior alavancagem. Cria templates de issue/PR, `CODEOWNERS`, um CI gate ciente do stack,
**AGENTS.md** (canônico) + um **CLAUDE.md** fino, e um deny-list de segurança em
`.claude/settings.json`. Ele **detecta o stack**, é **idempotente** e **nunca sobrescreve** um arquivo
sem `--force`.

```bash
# previa, depois aplica (o caminho assume o diretório atual)
bash skills/engineering-standards/scaffold.sh /caminho/do/repo --dry-run
bash skills/engineering-standards/scaffold.sh /caminho/do/repo
```
Adicione `--with-plugin OWNER/REPO` para também gravar o `.claude/settings.json` do projeto e
auto-habilitar o plugin para o time inteiro. Após instalar globalmente, o mesmo script vive em
`~/.claude/skills/engineering-standards/scaffold.sh`. Depois preencha o `AGENTS.md` com os comandos do
gate do seu stack (veja o apêndice) e defina owners reais em `.github/CODEOWNERS`.

## Agnóstico por design

O Pilar 3 é um conjunto de **contratos de capacidade** (os 8 verbos), não um toolset fixo. O comando
exato por verbo para JS/TS, Python, Go, Rust, JVM e .NET vive em
`skills/engineering-standards/references/stack-appendix.md`. O toolset original JS/TS (Biome, Knip,
Stryker, Playwright, Codecov) é apenas uma coluna desse apêndice.

## Instalar em outra máquina ou outro Claude

- **Claude Code**: instale o plugin, ou clone e rode `install-skill.sh`. Atualize com
  `git pull && bash install-skill.sh`.
- **Claude Desktop / claude.ai (web)**: suba a pasta `skills/engineering-standards/` pela UI de
  Skills (o comando `/standards` é exclusivo do Claude Code).
- MCP servers com API key (21st.dev, shadcn, chrome-devtools) não viajam sozinhos; veja
  `references/arsenal-mcp-skills.md`.

## Editar e evoluir

1. Edite as fontes.
2. `bash scripts/verify.sh` (precisa passar; a CI roda isso).
3. `bash install-skill.sh` para sincronizar a skill local.
4. Bump de `version` em `.claude-plugin/plugin.json` e `SKILL.md`; adicione entrada no `CHANGELOG.md`;
   commite.

## Pesquisa e benchmarks

O design é baseado em evidências. Veja
[`docs/research-and-benchmarks.md`](docs/research-and-benchmarks.md) para a síntese da pesquisa (com
fontes) e o auto-benchmark (fixtures greenfield + brownfield, pontuados por artefatos, com o
scaffolder e um projeto de amostra corrigido e verificado de ponta a ponta).

## Arsenal (referências externas)

| Ferramenta | Tipo | Uso |
|---|---|---|
| [humanizer](https://github.com/blader/humanizer) | Skill | Copy/docs com tom humano |
| [21st.dev Magic](https://github.com/21st-dev/magic-mcp) | MCP | Gerar/descobrir UI (React/Tailwind) |
| [shadcn-ui-mcp-server](https://github.com/Jpisnice/shadcn-ui-mcp-server) | MCP | Componentes shadcn/ui |
| [web-design-guidelines](https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines) | Skill | Auditar UI (a11y/UX) |
| [chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | MCP | Perf/erros no browser real |
| [design-motion-principles](https://github.com/kylezantos/design-motion-principles) | Skill | Motion correto / auditar animações |

## O que não é automático (por segurança)

- A skill orienta decisões; não executa ações destrutivas nem instala MCPs com API key sem
  confirmação. O scaffolder nunca sobrescreve sem `--force`.
- Enforcement mecânico (lint no pre-commit, bloquear merge sem Issue) pertence a **CI, hooks e branch
  protection**, não a uma skill. A skill é conselho; a CI é o portão autoritativo.
- Como plugin, ele traz **hooks conservadores** (fail-open) que bloqueiam Bash claramente destrutivo e
  edição de segredos, um guard determinístico em sessão junto do deny-list. Uma suíte `evals/`
  versionada auto-testa o pacote (`claude plugin eval`, braço with/without).

## Créditos e Licença

Padrões destilados da configuração do autor e dos projetos do Arsenal. Licença MIT. Especificação
completa em [`ai-engineering-standards.md`](ai-engineering-standards.md).
