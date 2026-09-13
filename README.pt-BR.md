<div align="center">

<img src="docs/icon.png" alt="Zeroth" width="84" height="84">

<h1>Zeroth</h1>

<p><b>Um único padrão de engenharia que seus agentes de IA de fato seguem.</b><br>
Em todo projeto, em qualquer linguagem.</p>

<p>
  <img alt="Release" src="https://img.shields.io/github/v/release/DouglasVulcano/zeroth-ai?style=flat-square&labelColor=141417&color=ffd700&label=release">
  <img alt="Plugin e skill do Claude Code" src="https://img.shields.io/badge/Claude_Code-plugin_%2B_skill-e4e4e7?style=flat-square&labelColor=141417">
  <img alt="Agnostico de stack" src="https://img.shields.io/badge/stack-agn%C3%B3stico-43b581?style=flat-square&labelColor=141417">
  <img alt="Licenca" src="https://img.shields.io/github/license/DouglasVulcano/zeroth-ai?style=flat-square&labelColor=141417&color=8e8e98">
</p>

<img src="docs/readme-hero.svg" alt="Instalando o Zeroth no Claude Code" width="760">

<p>
  <a href="https://douglasvulcano.github.io/zeroth-ai/pt-br/"><b>Site</b></a>
  &nbsp;&#183;&nbsp; <a href="README.md">English</a>
  &nbsp;&#183;&nbsp; <b>Português</b>
</p>

</div>

---

## 🧭 O que é

Agentes de IA escrevem código de um jeito um pouco diferente a cada vez. O Zeroth dá a eles um mesmo
manual, para que a forma de trabalhar, construir, testar e publicar continue igual, não importa qual
agente ou modelo esteja ajudando. São três coisas:

- **Um padrão** que você instala uma vez e reusa em todo lugar (a especificação completa e legível é
  o [`zeroth.md`](zeroth.md)).
- **Uma skill** que carrega a parte certa automaticamente quando você começa, planeja ou revisa um
  trabalho.
- **Um scaffolder** que coloca a governança em qualquer repo com um comando (templates de issue/PR,
  um CI gate, `AGENTS.md`, regras de segurança).

> [!TIP]
> Você não adota tudo de uma vez. Instale e o agente já começa a aplicar o padrão; rode o scaffolder
> depois, quando quiser que um repo realmente o reforce.

## 🚀 Instalação

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

## 🤝 Usa outro agente? Você também está coberto

A casa do Zeroth é o **Claude Code**, onde ele instala como plugin e dispara sozinho. Mas o padrão em
si é **agnóstico de modelo**: ele vive em um arquivo [`AGENTS.md`](https://agents.md) simples, o
formato aberto que Cursor, GitHub Copilot, OpenAI Codex, Windsurf, Gemini CLI, Aider e outros já leem.
Aponte o Zeroth para o seu repo uma vez, e todo agente do time segue o mesmo manual - sem plugin
nenhum.

| Seu agente | Como ele pega o Zeroth |
|---|---|
| **Claude Code** | Plugin/skill (automático), ou `AGENTS.md` |
| **Cursor, Copilot, Codex, Windsurf, Gemini CLI, Aider, ...** | Lê o `AGENTS.md` que o scaffolder escreve |

```bash
# Fora do Claude Code? Clone e deixe o scaffolder escrever o AGENTS.md no seu repo:
git clone https://github.com/DouglasVulcano/zeroth-ai.git
bash zeroth-ai/skills/zeroth/scaffold.sh /caminho/do/seu/repo
```

<details>
<summary><b>Ou cole o bloco de bootstrap no seu <code>AGENTS.md</code> na mão</b></summary>

```markdown
## Zeroth (padrão do projeto)
1. Workflow: Issue-first, PR-driven. Toda tarefa é uma Issue; todo deploy é um PR que a fecha
   (`Closes #N`). Conventional Commits.
2. Motion e UI: toda tela tem skeleton, lazy loading e estados suaves de entrada/saída/carregamento;
   respeite `prefers-reduced-motion`; anime só `transform`/`opacity`.
3. Qualidade e Testes: o CI gate `fmt -> lint -> typecheck -> arch -> deadcode -> test -> coverage ->
   build`; ligue cada verbo ao stack. Enforcement é CI mais branch protection; a skill é conselho.
4. Observabilidade (opcional, apps em produção): instrumente com OpenTelemetry (ou sua stack atual) só
   quando publicar um serviço com tráfego real.
Spec completa: https://github.com/DouglasVulcano/zeroth-ai/blob/main/zeroth.md
```

</details>

## ⌨️ Uso

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

## 🏛️ O que você ganha: os 4 pilares

| # | Pilar | Em uma linha |
|:-:|---|---|
| **1** | 🔁 **Workflow** | Issue-first, PR-driven. Toda tarefa é uma Issue; todo deploy é um PR que a fecha (`Closes #N`). Conventional Commits. |
| **2** | 🎬 **Motion e UI** | Toda tela tem skeleton, lazy loading e estados suaves de entrada/saída/carregamento; respeita `prefers-reduced-motion`. |
| **3** | ✅ **Qualidade e Testes** | Um CI gate (`fmt -> lint -> typecheck -> arch -> deadcode -> test -> coverage -> build`), ligado ao seu stack. Observabilidade (OpenTelemetry) é opcional, para apps em produção. |
| **4** | 🧰 **Arsenal** | A ferramenta certa por tarefa: geração de UI, performance no browser, motion, copy humanizado. |

O padrão é **agnóstico de stack**: o gate é um conjunto de contratos, e cada verbo mapeia para as
ferramentas da sua linguagem (JS/TS, Python, Go, Rust, JVM, .NET). A skill é conselho; sua **CI mais
branch protection** são o que de fato aplica.

## 📚 Saiba mais

- **[Especificação completa (`zeroth.md`)](zeroth.md)** - o padrão inteiro, legível de ponta a ponta.
- **[Segurança](SECURITY.md)** - modelo de ameaça, branch protection e a fronteira de confiança.
- **[Contribuir](CONTRIBUTING.md)** - como mudar o padrão e passar no gate.
- **[Pesquisa e benchmarks](docs/research-and-benchmarks.md)** - a evidência por trás do design.

<details>
<summary><b>Deep dives por domínio</b> (a skill carrega sob demanda)</summary>

- [Workflow e governança](skills/zeroth/references/workflow-github.md)
- [Motion e UI](skills/zeroth/references/motion-and-ui.md)
- [Qualidade e testes (o CI gate)](skills/zeroth/references/quality-and-testing.md)
- [Observabilidade (apps em produção, opcional)](skills/zeroth/references/observability.md)
- [Comandos por stack](skills/zeroth/references/stack-appendix.md)
- [Arsenal (MCP servers e skills)](skills/zeroth/references/arsenal-mcp-skills.md)

</details>

## 📄 Licença

MIT. Padrões destilados da configuração do autor e dos projetos do Arsenal.
