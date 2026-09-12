# Security

## Scope
This repository ships Markdown guidance plus Bash scripts (installer, scaffolder, self-check). It has
no server or runtime. The scripts read this repo and write into a target directory you choose.

## Safe by design
- The scaffolder never overwrites an existing file without `--force`, and supports `--dry-run`.
- The installer only writes under `~/.claude` (or the `CLAUDE_DIR` you set).
- No secrets are stored. The arsenal MCP servers require API keys that you provide; they are never
  installed automatically.

## Threat model and trust boundary
The repository is the trust root: installing this plugin runs its hooks on your machine and its
skill/AGENTS.md guide the agent, so a compromised repo or a merged malicious change means code
execution and prompt injection for everyone who installs. Treat the guardrails accordingly:

- Hooks and the settings deny-list are **accident prevention, not a sandbox**. They are fail-open and
  pattern-based; a determined adversary or a prompt-injected agent can bypass them. The real boundary
  is **CI, branch protection, OS permissions, and human review**, never the hooks.
- Installing any plugin executes code, so install only trusted sources. Auto-enable via a committed
  `.claude/settings.json` (`extraKnownMarketplaces` + `enabledPlugins`) is gated by Claude Code's
  workspace-trust prompt, but treat committing it as a supply-chain decision.
- This repo's own CI pins actions to a full commit SHA (with a version comment) and keeps them
  current with Dependabot (`.github/dependabot.yml`). The scaffolded CI templates default to
  major-version tags (for example `@v5`), which still receive patches; pin them to a SHA for the
  strictest supply-chain posture. Keep a lockfile and pin tool versions too.

## Repository hardening (maintainers)
Because the repo is the trust root, protect `main`:
- Require pull requests, at least one approving review, and **review from Code Owners**
  (`.github/CODEOWNERS`).
- Require the `verify` status check to pass, and enforce for admins.
- Tag releases so consumers update deliberately (plugins update only on a version bump).

Enable it in GitHub (Settings > Branches > Add rule for `main`), or via the API with a token that has
repo-admin scope:

```bash
gh api -X PUT repos/DouglasVulcano/ai_engineering_standards/branches/main/protection --input - <<'JSON'
{ "required_pull_request_reviews": { "required_approving_review_count": 1, "require_code_owner_reviews": true },
  "required_status_checks": { "strict": true, "contexts": ["verify"] },
  "enforce_admins": true, "restrictions": null }
JSON
```

## Reporting a vulnerability
Please open a private GitHub Security Advisory on the repository. Do not file a public issue with
exploit details.

## MCP note
Before enabling any MCP server, follow the vetting checklist in
`skills/engineering-standards/references/arsenal-mcp-skills.md` (audience-bound tokens, no
passthrough, least-privilege scopes, sandbox local servers, block private IP ranges).
