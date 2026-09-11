# Referência — Arsenal (MCP Servers & Skills)

> Pilar 4. Origem: `skills.txt` + a skill de motion do `prompts.txt` #2.
> **MCP com API key não é instalado automaticamente** — exige chave e altera a config do usuário.
> Peça confirmação e use os comandos abaixo quando decidir instalar.

## Escolha rápida
| Preciso de… | Use |
|---|---|
| Componente shadcn/ui (código real, blocks) | **shadcn-ui-mcp-server** |
| Gerar/descobrir UI nova (React/Tailwind) | **21st.dev Magic** |
| Motion correto / auditar animações | **design-motion-principles** |
| Revisar UI (a11y/UX guidelines) | **web-design-guidelines** |
| Perf/erros no browser real | **chrome-devtools-mcp** |
| Copy/docs com tom humano | **humanizer** |

## Skills (conhecimento sob demanda)
**humanizer** — `blader/humanizer`. Reescreve texto de IA p/ soar humano (25 padrões), preservando
fatos. Bom p/ copy, docs, READMEs.
```bash
/plugin marketplace add blader/humanizer && /plugin install humanizer@humanizer
# ou: npx skills add blader/humanizer --global
```
Uso: `/humanizer <texto>`; forneça 2–3 parágrafos seus p/ voice matching.

**web-design-guidelines** — `vercel-labs/agent-skills/.../web-design-guidelines`. Revisa código de UI
contra as Web Interface Guidelines (busca a versão mais recente). Gatilhos: "review my UI", "check
accessibility", "audit design".
```bash
npx skills add vercel-labs/agent-skills/skills/web-design-guidelines --global
```

**design-motion-principles** — `kylezantos/design-motion-principles`. Motion (lentes Emil/Jakub/Jhey),
modos **Create** e **Audit** (relatório HTML com demos). Base do pilar de motion.
```bash
npx skills add kylezantos/design-motion-principles
```

## MCP Servers
**21st.dev Magic** — `21st-dev/magic-mcp` (proxy do 21st MCP). 10k+ componentes React/Tailwind + geração
por IA. Key em https://21st.dev/mcp.
```bash
npx @21st-dev/cli@latest init --client claude
```
```jsonc
{ "mcpServers": { "21st": { "url": "https://21st.dev/api/mcp",
  "headers": { "x-api-key": "YOUR_21ST_API_KEY" } } } }
```
Tools: `generate`, `get_inspiration`, `search_logo`. Cheque `get_usage.aiGenerationEnabled`.

**shadcn-ui-mcp-server** — `Jpisnice/shadcn-ui-mcp-server`. Código/demos/blocks do shadcn/ui
(React/Svelte/Vue/RN). GitHub token sobe rate limit 60→5000/h.
```bash
claude mcp add shadcn -- bunx -y @jpisnice/shadcn-ui-mcp-server --github-api-key YOUR_TOKEN
# framework: --framework svelte | vue | react-native
```

**chrome-devtools-mcp** — `ChromeDevTools/chrome-devtools-mcp`. Controla Chrome real (Puppeteer):
perf (traces), debug (network/screenshots/console) e automação. Par com Playwright.
```jsonc
{ "mcpServers": { "chrome-devtools": { "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest"] } } }   // + "--slim","--headless"
```
⚠️ Expõe o conteúdo do browser ao cliente MCP — só clientes confiáveis, sem dados sensíveis.
