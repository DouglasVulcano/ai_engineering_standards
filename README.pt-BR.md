<p align="center">
  <img alt="Zeroth" src="docs/logo.png#gh-dark-mode-only" width="320">
  <img alt="Zeroth" src="docs/icon.png#gh-light-mode-only" width="96">
</p>

<h1 align="center">Zeroth</h1>

<p align="center">
  <a href="https://douglasvulcano.github.io/zeroth-ai/pt-br/"><b>Site</b></a> · <a href="README.md">English</a> · <b>Português</b>
</p>

> Um único padrão de engenharia que seus agentes de IA de fato seguem, em todo projeto e em qualquer
> linguagem. Vem como **plugin e skill do Claude Code**, e também viaja como um **`AGENTS.md`** simples
> que qualquer agente de qualquer modelo (Claude, Cursor, Copilot, Codex) consegue ler.

![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin%20%2B%20skill-6C4BF6)
![Agnostic](https://img.shields.io/badge/stack-agnostic-success)
![Scope](https://img.shields.io/badge/scope-global%20%7C%20project%20%7C%20team-informational)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## O que é

Agentes de IA escrevem código de um jeito um pouco diferente a cada vez. O Zeroth dá a eles um mesmo
manual, para que a forma de trabalhar, construir, testar e publicar continue igual, não importa qual
agente ou modelo esteja ajudando. São três coisas:

- **Um padrão** que você instala uma vez e reusa em todo lugar (a especificação completa e legível é
  o [`zeroth.md`](zeroth.md)).
- **Uma skill** que carrega a parte certa automaticamente quando você começa, planeja ou revisa um
  trabalho.
- **Um scaffolder** que coloca a governança em qualquer repo com um comando (templates de issue/PR,
  um CI gate, `AGENTS.md`, regras de segurança).

Você não adota tudo de uma vez. Instale e o agente já começa a aplicar o padrão; rode o scaffolder
quando quiser que um repo o reforce.

## Instalação

**Para um time (recomendado)** - versionado, sem drift. No Claude Code:

```text
/plugin marketplace add DouglasVulcano/zeroth-ai
/plugin install zeroth
```

**Para você** - uma skill global na sua máquina:

```bash
git clone https://github.com/DouglasVulcano/zeroth-ai.git
cd zeroth-ai
bash install-skill.sh
```

Atualize depois com `claude plugin update` (plugin) ou `git pull && bash install-skill.sh` (skill).

## Uso

- **Automático** - é só trabalhar. A skill dispara quando o pedido casa ("crie a issue e o PR",
  "revise esta tela", "configure o CI gate", "siga os padrões").
- **Sob demanda** - rode `/zeroth` para aplicar tudo, ou foque em uma área:

  ```text
  /zeroth workflow | ui | testing | o11y | arsenal | scaffold
  ```

- **Preparar um repo** - `/zeroth scaffold` (ou previa antes com
  `bash skills/zeroth/scaffold.sh /caminho/do/repo --dry-run`) adiciona templates de issue/PR, um CI
  gate ciente do stack, `AGENTS.md` e regras de segurança. Ele detecta o stack, nunca sobrescreve sem
  `--force` e é seguro re-rodar. Use `--with-plugin DouglasVulcano/zeroth-ai` para auto-habilitar o
  plugin para todos que confiam no repo.

## O que você ganha: os 4 pilares

| # | Pilar | Em uma linha |
|---|---|---|
| 1 | **Workflow** | Issue-first, PR-driven. Toda tarefa é uma Issue; todo deploy é um PR que a fecha (`Closes #N`). Conventional Commits. |
| 2 | **Motion e UI** | Toda tela tem skeleton, lazy loading e estados suaves de entrada/saída/carregamento; respeita `prefers-reduced-motion`. |
| 3 | **Qualidade e Testes** | Um CI gate (`fmt -> lint -> typecheck -> arch -> deadcode -> test -> coverage -> build`), ligado ao seu stack. Observabilidade (OpenTelemetry) é opcional, para apps em produção. |
| 4 | **Arsenal** | A ferramenta certa por tarefa: geração de UI, performance no browser, motion, copy humanizado. |

O padrão é **agnóstico de stack**: o gate é um conjunto de contratos, e cada verbo mapeia para as
ferramentas da sua linguagem (JS/TS, Python, Go, Rust, JVM, .NET). A skill é conselho; sua **CI mais
branch protection** são o que de fato aplica.

## Saiba mais

- **[Especificação completa (`zeroth.md`)](zeroth.md)** - o padrão inteiro, legível de ponta a ponta.
- **Deep dives** (a skill carrega sob demanda):
  [workflow](skills/zeroth/references/workflow-github.md) ·
  [motion e UI](skills/zeroth/references/motion-and-ui.md) ·
  [qualidade e testes](skills/zeroth/references/quality-and-testing.md) ·
  [observabilidade](skills/zeroth/references/observability.md) ·
  [comandos por stack](skills/zeroth/references/stack-appendix.md) ·
  [arsenal](skills/zeroth/references/arsenal-mcp-skills.md).
- **[Segurança](SECURITY.md)** - modelo de ameaça, branch protection e a fronteira de confiança.
- **[Contribuir](CONTRIBUTING.md)** - como mudar o padrão e passar no gate.
- **[Pesquisa e benchmarks](docs/research-and-benchmarks.md)** - a evidência por trás do design.

## Licença

MIT. Padrões destilados da configuração do autor e dos projetos do Arsenal.
