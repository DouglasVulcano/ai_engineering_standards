#!/usr/bin/env bash
#
# install-skill.sh: imports the standards markdown as a CENTRAL Claude Code SKILL.
# (For versioned team distribution, prefer the plugin: /plugin marketplace add
#  DouglasVulcano/ai-engineering-standards && /plugin install engineering-standards. See README.)
#
# What it does (idempotent):
#   1. Copies skills/engineering-standards/ (SKILL.md + references + scaffold.sh + assets) into
#      ~/.claude/skills/ (global scope = central)
#   2. Bundles the master markdown ai-engineering-standards.md into the skill's references/
#   3. Installs the /standards slash command into ~/.claude/commands/
#   4. Verifies the install and prints the next steps
#
# Usage:
#   bash install-skill.sh                        # install/update (global, ~/.claude), from the repo root
#   CLAUDE_DIR=./.claude bash install-skill.sh   # install into the current project (local scope)
#
set -euo pipefail

# --- Resolve paths ------------------------------------------------------------
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # repo root, wherever it was cloned
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"                 # override for project scope
SKILL_NAME="engineering-standards"
SKILL_SRC="$SRC_DIR/skills/$SKILL_NAME"
SKILL_DEST="$CLAUDE_DIR/skills/$SKILL_NAME"
CMD_DEST="$CLAUDE_DIR/commands"
MASTER_MD="$SRC_DIR/ai-engineering-standards.md"

echo "==> Importing skill '$SKILL_NAME'"
echo "    source: $SKILL_SRC"
echo "    target: $SKILL_DEST"

# --- Pre-checks ---------------------------------------------------------------
if [[ ! -f "$SKILL_SRC/SKILL.md" ]]; then
  echo "ERROR: could not find '$SKILL_SRC/SKILL.md'." >&2
  echo "       Run it from the repository root, or pass the full path: bash /path/to/repo/install-skill.sh." >&2
  exit 1
fi
if [[ ! -f "$MASTER_MD" ]]; then
  echo "ERROR: could not find the master markdown '$MASTER_MD'." >&2
  exit 1
fi

# --- 1+2. Copy the whole skill payload and bundle the master markdown ---------
# Prune the destination first so renamed/removed files never linger (fully idempotent).
# Guarded so the rm can only ever touch this skill's own directory.
if [[ "$SKILL_DEST" == */skills/"$SKILL_NAME" && -d "$SKILL_DEST" ]]; then
  rm -rf "$SKILL_DEST"
fi
mkdir -p "$SKILL_DEST"
cp -R "$SKILL_SRC/." "$SKILL_DEST/"
cp -f "$MASTER_MD" "$SKILL_DEST/references/ai-engineering-standards.md"
[[ -f "$SKILL_DEST/scaffold.sh" ]] && chmod +x "$SKILL_DEST/scaffold.sh"

# --- 3. /standards slash command ----------------------------------------------
mkdir -p "$CMD_DEST"
cp -f "$SRC_DIR/commands/"*.md "$CMD_DEST/"

# --- 4. Verification ----------------------------------------------------------
echo ""
echo "==> Installed:"
find "$SKILL_DEST" -type f | sort | sed "s|^|    |"
for c in "$SRC_DIR/commands/"*.md; do echo "    $CMD_DEST/$(basename "$c")"; done

echo ""
echo "OK. Skill '$SKILL_NAME' imported centrally into $CLAUDE_DIR/skills/"
echo ""
echo "Next steps:"
echo "  * Reopen Claude Code (or run /skills) to load the skill."
echo "  * Use it naturally ('follow the standards', 'create the issue/PR', 'review the UI'); it triggers on its own."
echo "  * Slash command:  /standards            (everything)"
echo "                    /standards scaffold    (add governance to the current repo)"
echo "  * Scaffold a repo directly:  bash $SKILL_DEST/scaffold.sh /path/to/repo   (--dry-run to preview)"
echo "  * Optional: install the arsenal MCP servers/skills (they need API keys); see references/arsenal-mcp-skills.md."
