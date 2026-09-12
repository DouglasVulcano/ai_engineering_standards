#!/usr/bin/env bash
#
# scaffold.sh: add zeroth governance to a target repo.
# Safe by design: never overwrites an existing file unless --force; supports --dry-run;
# re-running is idempotent (a second run makes no changes).
#
# Usage:
#   scaffold.sh [TARGET_DIR] [--dry-run] [--force] [--protect] [--ruleset]
#               [--with-plugin OWNER/REPO] [--marketplace NAME] [--plugin NAME]
#
# Defaults: TARGET_DIR = current directory; plugin NAME = zeroth;
#           marketplace NAME = the repo part of OWNER/REPO.
#
# Delivers: .github issue/PR templates, CODEOWNERS, a stack-aware CI gate (verify.yml),
# AGENTS.md (canonical) + a thin CLAUDE.md that imports it, and a .claude/settings.json safety
# deny-list. With --with-plugin it also wires .claude/settings.json to auto-enable the plugin for
# everyone who trusts the repo (extraKnownMarketplaces + enabledPlugins). With --protect it arms
# branch protection on the target's default branch via the GitHub API (needs gh + a repo-admin
# token; add --ruleset to apply a Ruleset instead). Otherwise it prints the commands to run.
#
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS="$SELF_DIR/assets"

usage() { sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

TARGET="."
DRY=0
FORCE=0
PROTECT=0
RULESET=0
WITH_PLUGIN=""
MARKETPLACE=""
PLUGIN_NAME="zeroth"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --force)   FORCE=1 ;;
    --protect) PROTECT=1 ;;
    --ruleset) RULESET=1 ;;
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

echo "==> Scaffolding zeroth governance"
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
ci_is_placeholder=1
if [[ -f "$ASSETS/github/workflows/ci.$stack.yml" ]]; then
  ci_src="$ASSETS/github/workflows/ci.$stack.yml"; ci_is_placeholder=0
fi
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

# --- branch protection (the authoritative gate the standard depends on) ---
origin_url="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
repo_slug=""
[[ -n "$origin_url" ]] && repo_slug="$(printf '%s' "$origin_url" | sed -E 's#^git@[^:]+:##; s#^https?://[^/]+/##; s#\.git$##')"
# prefer the remote's default branch (protection targets main, not whatever is checked out)
branch="$(git -C "$TARGET" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || true)"
[[ -z "$branch" ]] && branch="$(git -C "$TARGET" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
[[ -z "$branch" ]] && branch="main"
slug_disp="${repo_slug:-<owner>/<repo>}"
# Two dialects: the classic branch-protection API (enforce_admins is a field) and Rulesets (the
# newer model; enforce_admins maps to an empty bypass_actors list, never a status check).
if [[ "$ci_is_placeholder" -eq 1 ]]; then
  checks_json='"required_status_checks": null'
  rs_check_rule=''
else
  checks_json='"required_status_checks": { "strict": true, "contexts": ["verify"] }'
  rs_check_rule=', { "type": "required_status_checks", "parameters": { "strict_required_status_checks_policy": true, "required_status_checks": [ { "context": "verify" } ] } }'
fi
prot_json="{ \"required_pull_request_reviews\": { \"required_approving_review_count\": 1, \"require_code_owner_reviews\": true }, $checks_json, \"enforce_admins\": true, \"restrictions\": null }"
rs_json="{ \"name\": \"main-protection\", \"target\": \"branch\", \"enforcement\": \"active\", \"conditions\": { \"ref_name\": { \"include\": [\"~DEFAULT_BRANCH\"], \"exclude\": [] } }, \"rules\": [ { \"type\": \"pull_request\", \"parameters\": { \"required_approving_review_count\": 1, \"require_code_owner_review\": true, \"dismiss_stale_reviews_on_push\": false, \"require_last_push_approval\": false, \"required_review_thread_resolution\": false } }$rs_check_rule, { \"type\": \"non_fast_forward\" }, { \"type\": \"deletion\" } ], \"bypass_actors\": [] }"

echo ""
echo "Summary: created/would-create=$created, kept=$kept, stack=$stack"
if [[ "$ci_is_placeholder" -eq 1 ]]; then
  echo ""
  echo "WARNING: the generated .github/workflows/verify.yml is a placeholder that always passes."
  echo "         Fill the gate for '$stack' BEFORE requiring the 'verify' check below, or you would"
  echo "         enforce a check that verifies nothing (the command leaves status checks unset)."
fi
echo ""
echo "Next steps:"
echo "  1. Fill AGENTS.md: stack + the gate commands for '$stack' (see the stack-appendix)."
echo "  2. Set real owners in .github/CODEOWNERS."
echo "  3. Complete .github/workflows/verify.yml for your stack."
echo "  4. Arm branch protection on '$branch' (the authoritative gate). Review, then run ONE of:"
echo "     - Classic branch-protection API:"
echo "       gh api -X PUT repos/$slug_disp/branches/$branch/protection --input - <<'JSON'"
echo "       $prot_json"
echo "       JSON"
echo "     - Ruleset (GitHub's newer model; targets the default branch):"
echo "       gh api -X POST repos/$slug_disp/rulesets --input - <<'JSON'"
echo "       $rs_json"
echo "       JSON"
echo "     Note: 'enforce_admins' is NOT a status check. Classic uses the enforce_admins field; a"
echo "     ruleset uses bypass_actors (empty = applies to admins too). Putting it in a check list"
echo "     hangs the merge on 'Expected - Waiting for status to be reported'."
echo "     Or re-run with --protect (add --ruleset to apply a Ruleset instead of the classic API)."
[[ -z "$WITH_PLUGIN" ]] && echo "  5. To auto-enable the plugin for the whole team: re-run with --with-plugin OWNER/REPO."

if [[ "$PROTECT" -eq 1 ]]; then
  if [[ "$RULESET" -eq 1 ]]; then method="ruleset"; else method="classic branch protection"; fi
  echo ""
  echo "==> --protect: applying $method on '$branch'"
  if [[ "$DRY" -eq 1 ]]; then
    if [[ "$RULESET" -eq 1 ]]; then
      echo "    dry run: would POST repos/$slug_disp/rulesets (nothing sent)"
    else
      echo "    dry run: would PUT repos/$slug_disp/branches/$branch/protection (nothing sent)"
    fi
  elif [[ -z "$repo_slug" ]]; then
    echo "    SKIP: no 'origin' remote in $TARGET; set one and re-run, or apply the command above." >&2
  elif ! command -v gh >/dev/null 2>&1; then
    echo "    SKIP: gh CLI not found; apply the command above with a repo-admin token." >&2
  elif ! gh auth status >/dev/null 2>&1; then
    echo "    SKIP: gh is not authenticated ('gh auth login'); apply the command above." >&2
  else
    apply=1
    if [[ -t 0 ]]; then
      printf '    Apply %s to %s on %s? [y/N] ' "$method" "$repo_slug" "$branch"
      read -r ans || ans=""
      [[ "$ans" =~ ^[Yy]$ ]] || apply=0
    fi
    if [[ "$apply" -eq 1 ]]; then
      if [[ "$RULESET" -eq 1 ]]; then
        if printf '%s' "$rs_json" | gh api -X POST "repos/$repo_slug/rulesets" --input - >/dev/null 2>&1; then
          echo "    done: ruleset 'main-protection' created on $repo_slug (edit or delete it in Settings > Rules)."
        else
          echo "    ERROR: gh api POST rulesets failed (needs a repo-admin token; a ruleset named 'main-protection' may already exist)." >&2
        fi
      else
        if printf '%s' "$prot_json" | gh api -X PUT "repos/$repo_slug/branches/$branch/protection" --input - >/dev/null 2>&1; then
          echo "    done: branch protection applied to $repo_slug@$branch"
        else
          echo "    ERROR: gh api PUT failed (needs a repo-admin token: classic 'repo' scope or fine-grained Administration:write)." >&2
        fi
      fi
    else
      echo "    cancelled (no changes)."
    fi
  fi
fi

[[ "$DRY" -eq 1 ]] && echo "(dry run: nothing was written)"
exit 0
