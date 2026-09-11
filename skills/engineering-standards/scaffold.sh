#!/usr/bin/env bash
#
# scaffold.sh: add engineering-standards governance to a target repo.
# Safe by design: never overwrites an existing file unless --force; supports --dry-run;
# re-running is idempotent (a second run makes no changes).
#
# Usage:
#   scaffold.sh [TARGET_DIR] [--dry-run] [--force]
# Defaults: TARGET_DIR = current directory.
#
# Delivers: .github issue/PR templates, CODEOWNERS, a stack-aware CI gate (verify.yml),
# AGENTS.md (canonical) + a thin CLAUDE.md that imports it, and a .claude/settings.json safety
# deny-list. Then tells you what to finish (stack commands, real owners).
#
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS="$SELF_DIR/assets"

TARGET="."
DRY=0
FORCE=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --force)   FORCE=1 ;;
    -h|--help) sed -n '2,20p' "${BASH_SOURCE[0]}"; exit 0 ;;
    -*)        echo "unknown flag: $a" >&2; exit 2 ;;
    *)         TARGET="$a" ;;
  esac
done

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

# --- safety rails ---
place "$ASSETS/settings.json" ".claude/settings.json"

echo ""
echo "Summary: created/would-create=$created, kept=$kept, stack=$stack"
echo "Next steps:"
echo "  1. Fill AGENTS.md: stack + the gate commands for '$stack' (see the stack-appendix)."
echo "  2. Set real owners in .github/CODEOWNERS."
echo "  3. Complete .github/workflows/verify.yml for your stack."
[[ "$DRY" -eq 1 ]] && echo "(dry run: nothing was written)"
exit 0
