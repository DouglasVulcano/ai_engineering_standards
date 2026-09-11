#!/usr/bin/env bash
#
# scaffold.sh: add engineering-standards governance to a target repo.
# Safe by design: never overwrites an existing file unless --force; supports --dry-run;
# re-running is idempotent (a second run makes no changes).
#
# Usage:
#   scaffold.sh [TARGET_DIR] [--dry-run] [--force]
#               [--with-plugin OWNER/REPO] [--marketplace NAME] [--plugin NAME]
#
# Defaults: TARGET_DIR = current directory; plugin NAME = engineering-standards;
#           marketplace NAME = the repo part of OWNER/REPO.
#
# Delivers: .github issue/PR templates, CODEOWNERS, a stack-aware CI gate (verify.yml),
# AGENTS.md (canonical) + a thin CLAUDE.md that imports it, and a .claude/settings.json safety
# deny-list. With --with-plugin it also wires .claude/settings.json to auto-enable the plugin for
# everyone who trusts the repo (extraKnownMarketplaces + enabledPlugins).
#
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS="$SELF_DIR/assets"

usage() { sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

TARGET="."
DRY=0
FORCE=0
WITH_PLUGIN=""
MARKETPLACE=""
PLUGIN_NAME="engineering-standards"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --force)   FORCE=1 ;;
    --with-plugin)   WITH_PLUGIN="${2:-}"; shift ;;
    --with-plugin=*) WITH_PLUGIN="${1#*=}" ;;
    --marketplace)   MARKETPLACE="${2:-}"; shift ;;
    --marketplace=*) MARKETPLACE="${1#*=}" ;;
    --plugin)        PLUGIN_NAME="${2:-}"; shift ;;
    --plugin=*)      PLUGIN_NAME="${1#*=}" ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "unknown flag: $1" >&2; exit 2 ;;
    *)         TARGET="$1" ;;
  esac
  shift
done
MARKETPLACE="${MARKETPLACE:-${WITH_PLUGIN##*/}}"

[[ -d "$ASSETS" ]] || { echo "ERROR: assets not found at $ASSETS" >&2; exit 1; }
[[ -d "$TARGET" ]] || { echo "ERROR: target '$TARGET' is not a directory" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

echo "==> Scaffolding engineering-standards governance"
echo "    target: $TARGET"
[[ "$DRY" -eq 1 ]] && echo "    mode:   DRY RUN (no writes)"

# --- stack detection (best effort) ---
stack="generic"
if   [[ -f "$TARGET/package.json" ]]; then stack="node"
elif [[ -f "$TARGET/pyproject.toml" || -f "$TARGET/requirements.txt" ]]; then stack="python"
elif [[ -f "$TARGET/go.mod" ]]; then stack="go"
elif [[ -f "$TARGET/Cargo.toml" ]]; then stack="rust"
elif [[ -f "$TARGET/pom.xml" || -f "$TARGET/build.gradle" || -f "$TARGET/build.gradle.kts" ]]; then stack="jvm"
elif ls "$TARGET"/*.csproj >/dev/null 2>&1; then stack="dotnet"
fi
echo "    stack:  $stack"
echo ""

created=0; kept=0
place() { # place <src-abs> <dest-rel>
  local src="$1" rel="$2" dest="$TARGET/$2"
  if [[ -e "$dest" && "$FORCE" -ne 1 ]]; then
    echo "    keep    $rel (exists)"; kept=$((kept+1)); return 0
  fi
  if [[ "$DRY" -eq 1 ]]; then
    echo "    would   $rel"; created=$((created+1)); return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "    create  $rel"; created=$((created+1))
}

# --- governance ---
place "$ASSETS/github/ISSUE_TEMPLATE/fix.md"          ".github/ISSUE_TEMPLATE/fix.md"
place "$ASSETS/github/ISSUE_TEMPLATE/improvement.md"  ".github/ISSUE_TEMPLATE/improvement.md"
place "$ASSETS/github/ISSUE_TEMPLATE/feature.md"      ".github/ISSUE_TEMPLATE/feature.md"
place "$ASSETS/github/ISSUE_TEMPLATE/config.yml"      ".github/ISSUE_TEMPLATE/config.yml"
place "$ASSETS/github/pull_request_template.md"       ".github/pull_request_template.md"
place "$ASSETS/github/CODEOWNERS"                      ".github/CODEOWNERS"

# --- CI gate (stack-specific when available, else generic) ---
ci_src="$ASSETS/github/workflows/ci.yml"
[[ -f "$ASSETS/github/workflows/ci.$stack.yml" ]] && ci_src="$ASSETS/github/workflows/ci.$stack.yml"
place "$ci_src" ".github/workflows/verify.yml"

# --- agent guides ---
place "$ASSETS/AGENTS.md" "AGENTS.md"
place "$ASSETS/CLAUDE.md" "CLAUDE.md"

# --- safety rails (deny-list) ---
place "$ASSETS/settings.json" ".claude/settings.json"

# --- optional: wire team auto-enable of the plugin (merges into .claude/settings.json) ---
if [[ -n "$WITH_PLUGIN" ]]; then
  dest="$TARGET/.claude/settings.json"
  if [[ "$DRY" -eq 1 ]]; then
    echo "    would   .claude/settings.json (+ marketplace '$MARKETPLACE' + enable '$PLUGIN_NAME@$MARKETPLACE')"
  elif command -v python3 >/dev/null 2>&1; then
    mkdir -p "$(dirname "$dest")"
    DEST="$dest" WP="$WITH_PLUGIN" MK="$MARKETPLACE" PN="$PLUGIN_NAME" python3 - <<'PY'
import json, os
dest, wp, mk, pn = os.environ["DEST"], os.environ["WP"], os.environ["MK"], os.environ["PN"]
try:
    data = json.load(open(dest))
    if not isinstance(data, dict):
        data = {}
except (FileNotFoundError, ValueError):
    data = {}
data.setdefault("extraKnownMarketplaces", {})[mk] = {"source": {"source": "github", "repo": wp}}
data.setdefault("enabledPlugins", {})[f"{pn}@{mk}"] = True
with open(dest, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
    echo "    team    .claude/settings.json (auto-enable $PLUGIN_NAME@$MARKETPLACE from $WITH_PLUGIN)"
  else
    echo "    WARN: python3 not found; add to .claude/settings.json by hand:" >&2
    echo "          extraKnownMarketplaces.$MARKETPLACE.source = {source: github, repo: $WITH_PLUGIN}" >&2
    echo "          enabledPlugins[\"$PLUGIN_NAME@$MARKETPLACE\"] = true" >&2
  fi
fi

echo ""
echo "Summary: created/would-create=$created, kept=$kept, stack=$stack"
echo "Next steps:"
echo "  1. Fill AGENTS.md: stack + the gate commands for '$stack' (see the stack-appendix)."
echo "  2. Set real owners in .github/CODEOWNERS."
echo "  3. Complete .github/workflows/verify.yml for your stack."
[[ -z "$WITH_PLUGIN" ]] && echo "  4. To auto-enable the plugin for the whole team: re-run with --with-plugin OWNER/REPO."
[[ "$DRY" -eq 1 ]] && echo "(dry run: nothing was written)"
exit 0
