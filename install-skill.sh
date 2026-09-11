#!/usr/bin/env bash
#
# install-skill.sh: imports the standards markdown as a CENTRAL Claude Code SKILL.
#
# What it does (idempotent):
#   1. Copies the `engineering-standards/` skill into ~/.claude/skills/ (global scope = central)
#   2. Bundles the master markdown `ai-engineering-standards.md` into the skill's references/
#   3. Installs the `/standards` slash command into ~/.claude/commands/
#   4. Verifies the install and prints the next steps
#
# Usage:
#   bash ~/ai_config/install-skill.sh            # install/update (global, ~/.claude)
#   CLAUDE_DIR=./.claude bash install-skill.sh   # install into the current project (local scope)
#
set -euo pipefail

# --- Resolve paths ------------------------------------------------------------
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # where this script lives (~/ai_config)
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"                 # override for project scope
SKILL_NAME="engineering-standards"
SKILL_DEST="$CLAUDE_DIR/skills/$SKILL_NAME"
CMD_DEST="$CLAUDE_DIR/commands"
MASTER_MD="$SRC_DIR/ai-engineering-standards.md"

echo "==> Importing skill '$SKILL_NAME'"
echo "    source: $SRC_DIR"
echo "    target: $SKILL_DEST"

# --- Pre-checks ---------------------------------------------------------------
if [[ ! -f "$SRC_DIR/$SKILL_NAME/SKILL.md" ]]; then
  echo "ERROR: could not find '$SRC_DIR/$SKILL_NAME/SKILL.md'." >&2
  echo "       Run this script from the ~/ai_config directory." >&2
  exit 1
fi
if [[ ! -f "$MASTER_MD" ]]; then
  echo "ERROR: could not find the master markdown '$MASTER_MD'." >&2
  exit 1
fi

# --- 1+2. Copy the skill and bundle the master markdown -----------------------
mkdir -p "$SKILL_DEST/references"
cp -f "$SRC_DIR/$SKILL_NAME/SKILL.md" "$SKILL_DEST/SKILL.md"
cp -f "$SRC_DIR/$SKILL_NAME/references/"*.md "$SKILL_DEST/references/"
cp -f "$MASTER_MD" "$SKILL_DEST/references/ai-engineering-standards.md"

# --- 3. /standards slash command ----------------------------------------------
mkdir -p "$CMD_DEST"
cat > "$CMD_DEST/standards.md" <<'CMD'
---
description: Apply the AI Engineering Standards (workflow, motion/UI, o11y, quality, testing)
argument-hint: "[domain: workflow | ui | o11y | testing | arsenal | (empty = everything)]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebFetch
---

Invoke the `engineering-standards` skill and apply the user's single engineering standard to the
current task. If `$ARGUMENTS` names a domain, load only the matching reference; otherwise follow
`SKILL.md` and load on demand.

- workflow -> references/workflow-github.md
- ui       -> references/motion-and-ui.md
- o11y     -> references/observability-quality-testing.md
- testing  -> references/observability-quality-testing.md
- arsenal  -> references/arsenal-mcp-skills.md
- (empty)  -> SKILL.md plus the full spec in references/ai-engineering-standards.md

Whenever you work in a repository, ensure the standards bootstrap block is in CLAUDE.md/AGENTS.md.
CMD

# --- 4. Verification ----------------------------------------------------------
echo ""
echo "==> Installed:"
find "$SKILL_DEST" -type f | sed "s|^|    |"
echo "    $CMD_DEST/standards.md"

echo ""
echo "OK. Skill '$SKILL_NAME' imported centrally into $CLAUDE_DIR/skills/"
echo ""
echo "Next steps:"
echo "  * Reopen Claude Code (or run /skills) to load the skill."
echo "  * Use it naturally ('follow the standards', 'create the issue/PR', 'review the UI'); it triggers on its own."
echo "  * Or invoke the slash command:  /standards         (everything)"
echo "                                  /standards ui       (motion/UI only)"
echo "  * In each repo, let the agent feed CLAUDE.md/AGENTS.md with the bootstrap (see workflow-github.md)."
echo "  * Optional: install the arsenal MCP servers/skills (they need API keys); see references/arsenal-mcp-skills.md."
