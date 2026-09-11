# Security

## Scope
This repository ships Markdown guidance plus Bash scripts (installer, scaffolder, self-check). It has
no server or runtime. The scripts read this repo and write into a target directory you choose.

## Safe by design
- The scaffolder never overwrites an existing file without `--force`, and supports `--dry-run`.
- The installer only writes under `~/.claude` (or the `CLAUDE_DIR` you set).
- No secrets are stored. The arsenal MCP servers require API keys that you provide; they are never
  installed automatically.

## Reporting a vulnerability
Please open a private GitHub Security Advisory on the repository. Do not file a public issue with
exploit details.

## MCP note
Before enabling any MCP server, follow the vetting checklist in
`skills/engineering-standards/references/arsenal-mcp-skills.md` (audience-bound tokens, no
passthrough, least-privilege scopes, sandbox local servers, block private IP ranges).
