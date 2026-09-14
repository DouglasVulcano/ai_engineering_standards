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
  current with Dependabot (`.github/dependabot.yml`). The scaffolded CI templates now do the same:
  every `actions/*` is SHA-pinned, and the scaffolder writes a `.github/dependabot.yml` so the pins
  stay current downstream (a moved tag can smuggle in code; a SHA cannot). Keep a lockfile and pin
  tool versions too.

## Repository hardening (maintainers)
Because the repo is the trust root, protect `main`:
- Require pull requests, at least one approving review, and **review from Code Owners**
  (`.github/CODEOWNERS`).
- Require the `verify` status check to pass, and enforce for admins.
- Tag releases so consumers update deliberately (plugins update only on a version bump).

Enable it in GitHub (Settings > Branches > Add rule for `main`), or via the API with a token that has
repo-admin scope:

```bash
gh api -X PUT repos/DouglasVulcano/zeroth-ai/branches/main/protection --input - <<'JSON'
{ "required_pull_request_reviews": { "required_approving_review_count": 1, "require_code_owner_reviews": true },
  "required_status_checks": { "strict": true, "contexts": ["verify"] },
  "enforce_admins": true, "restrictions": null }
JSON
```

On a **Ruleset** (Settings > Rules > Rulesets, GitHub's newer model) the shape differs: there is no
`enforce_admins` field (an empty `bypass_actors` list applies the rule to admins too), and the
required check is a `required_status_checks` rule whose context is the **job name** (here `verify`).
Never put `enforce_admins` in the status-check list: nothing reports it, so the merge box stays on
"Expected - Waiting for status to be reported". The scaffolder prints both commands, and
`scaffold.sh --protect --ruleset` applies the ruleset for you.

## Opt-in posture (advanced)
These are opt-in and not scaffolded by default (they are repo- or org-specific). Add them when a
project warrants it:

- **OpenSSF Scorecard** scores your repository's security health and can upload SARIF to code scanning.
  Public repos work out of the box; a private repo needs a PAT. Pin the actions to a SHA, as the CI
  templates do:
  ```yaml
  # .github/workflows/scorecard.yml  (weekly + on push to the default branch)
  permissions: read-all
  jobs:
    analysis:
      runs-on: ubuntu-latest
      permissions:
        security-events: write
        id-token: write
      steps:
        - uses: actions/checkout@fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09 # v5
        - uses: ossf/scorecard-action@2d1146689b8cda280b9bc96326124645441f03bc # v2.4.4
          with:
            results_file: results.sarif
            results_format: sarif
            publish_results: true
        - uses: github/codeql-action/upload-sarif@faaca9a8f6edddba5725ffe5adefdab6669a2eca # v3
          with:
            sarif_file: results.sarif
  ```
- **reviewdog** posts linter or scanner findings as inline PR annotations from any tool that emits
  SARIF or checkstyle. Wire it into the CI `lint` step to turn pass/fail into in-diff review.
- **Allstar** (OpenSSF) is a GitHub App installed at the ORG level; it watches for policy drift
  (missing branch protection, no CODEOWNERS) and opens issues or fix PRs. Install it on the org.

## Reporting a vulnerability
Please open a private GitHub Security Advisory on the repository. Do not file a public issue with
exploit details.

## MCP note
Before enabling any MCP server, follow the vetting checklist in
`skills/zeroth/references/arsenal-mcp-skills.md` (audience-bound tokens, no
passthrough, least-privilege scopes, sandbox local servers, block private IP ranges).
