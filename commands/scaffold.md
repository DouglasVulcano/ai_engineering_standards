---
description: Scaffold zeroth governance into a repo (issue/PR templates, CODEOWNERS, CI gate, AGENTS.md + thin CLAUDE.md, safety deny-list)
argument-hint: "[target dir] [--dry-run] [--with-plugin owner/repo]"
allowed-tools: Read, Bash, Glob, Grep
---

Run the bundled scaffolder against the target (default: the current directory), resolving its path
from the skill or plugin root and passing `$ARGUMENTS` through:

```bash
bash "${CLAUDE_SKILL_DIR:-${CLAUDE_PLUGIN_ROOT:-.}/skills/zeroth}/scaffold.sh" $ARGUMENTS
```

It is safe and idempotent (never overwrites without `--force`; supports `--dry-run`). Afterwards: fill
`AGENTS.md` with the stack's gate commands (see `references/stack-appendix.md`) and set real owners in
`.github/CODEOWNERS`. To auto-enable this plugin for a whole team, add `--with-plugin OWNER/REPO`
(writes the project's `.claude/settings.json`).
