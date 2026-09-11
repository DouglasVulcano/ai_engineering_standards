# Reference: Arsenal (MCP Servers and Skills)

> Pillar 4. Source: `skills.txt` plus the motion skill from `prompts.txt` #2.
> **An MCP with an API key is not installed automatically:** it needs a key and changes the user's
> config. Ask for confirmation and use the commands below when you decide to install.

## Quick choice
| I need to... | Use |
|---|---|
| A shadcn/ui component (real code, blocks) | **shadcn-ui-mcp-server** |
| Generate or discover new UI (React/Tailwind) | **21st.dev Magic** |
| Correct motion / audit animations | **design-motion-principles** |
| Review UI (a11y/UX guidelines) | **web-design-guidelines** |
| Perf/errors in a real browser | **chrome-devtools-mcp** |
| Copy/docs with a human tone | **humanizer** |

## Skills (knowledge on demand)
**humanizer**, `blader/humanizer`. Rewrites AI text so it reads human (25 patterns), preserving
facts. Good for copy, docs, READMEs.
```bash
/plugin marketplace add blader/humanizer && /plugin install humanizer@humanizer
# or: npx skills add blader/humanizer --global
```
Usage: `/humanizer <text>`; provide 2 to 3 of your own paragraphs for voice matching.

**web-design-guidelines**, `vercel-labs/agent-skills/.../web-design-guidelines`. Reviews UI code
against the Web Interface Guidelines (fetches the latest version). Triggers: "review my UI", "check
accessibility", "audit design".
```bash
npx skills add vercel-labs/agent-skills/skills/web-design-guidelines --global
```

**design-motion-principles**, `kylezantos/design-motion-principles`. Motion (Emil/Jakub/Jhey lenses),
two modes: **Create** and **Audit** (HTML report with demos). Basis of the motion pillar.
```bash
npx skills add kylezantos/design-motion-principles
```

## MCP Servers
**21st.dev Magic**, `21st-dev/magic-mcp` (proxy for the 21st MCP). 10k+ React/Tailwind components
plus AI generation. Key at https://21st.dev/mcp.
```bash
npx @21st-dev/cli@latest init --client claude
```
```jsonc
{ "mcpServers": { "21st": { "url": "https://21st.dev/api/mcp",
  "headers": { "x-api-key": "YOUR_21ST_API_KEY" } } } }
```
Tools: `generate`, `get_inspiration`, `search_logo`. Check `get_usage.aiGenerationEnabled`.

**shadcn-ui-mcp-server**, `Jpisnice/shadcn-ui-mcp-server`. Source/demos/blocks for shadcn/ui
(React/Svelte/Vue/React Native). A GitHub token raises the rate limit from 60 to 5000 per hour.
```bash
claude mcp add shadcn -- bunx -y @jpisnice/shadcn-ui-mcp-server --github-api-key YOUR_TOKEN
# framework: --framework svelte | vue | react-native
```

**chrome-devtools-mcp**, `ChromeDevTools/chrome-devtools-mcp`. Controls a real Chrome (Puppeteer):
perf (traces), debug (network/screenshots/console), and automation. Pairs with Playwright.
```jsonc
{ "mcpServers": { "chrome-devtools": { "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest"] } } }   // plus "--slim","--headless"
```
Warning: it exposes the browser content to the MCP client. Connect only trusted clients, no sensitive
data.
