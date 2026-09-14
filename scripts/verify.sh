#!/usr/bin/env bash
#
# verify.sh: self-check for this standards repo. Dogfoods pillar 3 (quality gate).
# Runs locally (`bash scripts/verify.sh`) and in CI (.github/workflows/verify.yml).
# No external dependencies beyond coreutils, grep, awk, and python3 (for JSON validation).
#
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."   # repo root, regardless of where it was called from

fail=0
err() { echo "  FAIL: $*" >&2; fail=1; }
ok()  { echo "  ok:   $*"; }
SKILL="skills/zeroth"

echo "==> Required files"
required=(
  zeroth.md install-skill.sh README.md README.pt-BR.md LICENSE
  AGENTS.md CLAUDE.md CONTRIBUTING.md CHANGELOG.md SECURITY.md
  .claude-plugin/plugin.json .claude-plugin/marketplace.json
  .github/CODEOWNERS
  commands/zeroth.md commands/scaffold.md
  "$SKILL/SKILL.md" "$SKILL/scaffold.sh"
  "$SKILL/references/workflow-github.md"
  "$SKILL/references/motion-and-ui.md"
  "$SKILL/references/quality-and-testing.md"
  "$SKILL/references/observability.md"
  "$SKILL/references/stack-appendix.md"
  "$SKILL/references/arsenal-mcp-skills.md"
  "$SKILL/assets/AGENTS.md" "$SKILL/assets/CLAUDE.md" "$SKILL/assets/settings.json"
  "$SKILL/assets/github/pull_request_template.md"
  "$SKILL/assets/github/CODEOWNERS"
  "$SKILL/assets/github/workflows/ci.yml"
  "$SKILL/assets/github/workflows/ci.node.yml"
  "$SKILL/assets/github/workflows/ci.python.yml"
  "$SKILL/assets/github/workflows/ci.go.yml"
  "$SKILL/assets/github/workflows/ci.rust.yml"
  "$SKILL/assets/github/workflows/ci.jvm.yml"
  "$SKILL/assets/github/workflows/ci.dotnet.yml"
  hooks/hooks.json hooks/guard-bash.sh hooks/guard_bash.py hooks/guard-paths.sh hooks/guard_paths.py
  evals/README.md evals/scaffold-greenfield/prompt.md scripts/stress.sh
)
for f in "${required[@]}"; do
  [[ -f "$f" ]] && ok "$f" || err "missing $f"
done

echo "==> Shell syntax"
for s in install-skill.sh scripts/verify.sh scripts/stress.sh "$SKILL/scaffold.sh" hooks/guard-bash.sh hooks/guard-paths.sh; do
  bash -n "$s" && ok "bash -n $s" || err "$s has a syntax error"
done

echo "==> JSON validity"
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json "$SKILL/assets/settings.json" hooks/hooks.json; do
  python3 -c "import json,sys;json.load(open(sys.argv[1]))" "$j" && ok "$j" || err "$j is invalid JSON"
done

echo "==> plugin.json / marketplace.json consistency"
python3 - <<'PY' || fail=1
import json
p=json.load(open(".claude-plugin/plugin.json"))
m=json.load(open(".claude-plugin/marketplace.json"))
assert p.get("name")=="zeroth", "plugin name"
assert p.get("version"), "plugin version"
names=[x.get("name") for x in m.get("plugins",[])]
assert "zeroth" in names, "marketplace lists the plugin"
print("  ok:   plugin/marketplace consistent (v%s)" % p["version"])
PY

echo "==> Version consistency (plugin.json == SKILL.md == zeroth.md)"
python3 - <<'PY2' || fail=1
import json, re, sys
pv = json.load(open(".claude-plugin/plugin.json")).get("version")
sk = open("skills/zeroth/SKILL.md").read()
m  = re.search(r'^\s*version:\s*"?([0-9]+\.[0-9]+\.[0-9]+)"?', sk, re.M)
sv = m.group(1) if m else None
zt = open("zeroth.md").read()
m2 = re.search(r'\|\s*\*\*Version\*\*\s*\|\s*([0-9]+\.[0-9]+\.[0-9]+)\s*\|', zt)
zv = m2.group(1) if m2 else None
if pv and pv == sv == zv:
    print("  ok:   all three at %s" % pv)
else:
    print("  FAIL: version drift plugin.json=%s SKILL.md=%s zeroth.md=%s" % (pv, sv, zv), file=sys.stderr)
    sys.exit(1)
PY2

echo "==> Python syntax (hooks)"
for p in hooks/guard_bash.py hooks/guard_paths.py; do
  python3 -c "import sys; compile(open(sys.argv[1],'rb').read(), sys.argv[1], 'exec')" "$p" && ok "syntax $p" || err "$p has a syntax error"
done

echo "==> Hook behavior (guards block/allow, fail-open)"
run_hook() { printf '%s' "$2" | bash "$1" >/dev/null 2>&1; echo $?; }
[ "$(run_hook hooks/guard-bash.sh '{"tool_input":{"command":"rm -rf /"}}')" = 2 ] && ok "guard-bash blocks rm -rf /" || err "guard-bash did not block rm -rf /"
[ "$(run_hook hooks/guard-bash.sh '{"tool_input":{"command":"npm test"}}')" = 0 ] && ok "guard-bash allows npm test" || err "guard-bash blocked a safe command"
[ "$(run_hook hooks/guard-bash.sh 'not-json')" = 0 ] && ok "guard-bash fail-open on bad input" || err "guard-bash not fail-open"
[ "$(run_hook hooks/guard-paths.sh '{"tool_input":{"file_path":"config/.env"}}')" = 2 ] && ok "guard-paths blocks .env" || err "guard-paths did not block .env"
[ "$(run_hook hooks/guard-paths.sh '{"tool_input":{"file_path":".env.local"}}')" = 2 ] && ok "guard-paths blocks .env.local" || err "guard-paths did not block .env.local"
[ "$(run_hook hooks/guard-paths.sh '{"tool_input":{"file_path":"src/app.ts"}}')" = 0 ] && ok "guard-paths allows source" || err "guard-paths blocked a safe path"
[ "$(run_hook hooks/guard-paths.sh '{"tool_input":{"file_path":".env.example"}}')" = 0 ] && ok "guard-paths allows .env.example (template)" || err "guard-paths blocked a safe template (.env.example)"
[ "$(run_hook hooks/guard-paths.sh '{"tool_input":{"file_path":"config/secrets.yaml"}}')" = 2 ] && ok "guard-paths blocks secrets.yaml" || err "guard-paths did not block secrets.yaml"
[ "$(run_hook hooks/guard-paths.sh '{"tool_input":{"file_path":"deploy/tls.key"}}')" = 2 ] && ok "guard-paths blocks *.key" || err "guard-paths did not block a .key file"
[ "$(run_hook hooks/guard-paths.sh '{"tool_input":{"file_path":"gcp/service-account.json"}}')" = 2 ] && ok "guard-paths blocks service-account json" || err "guard-paths did not block service-account json"

echo "==> Evals structure"
ev=1
while IFS= read -r pm; do [ -f "$pm" ] || { err "missing $pm"; ev=0; }; done < <(find evals -name prompt.md)
while IFS= read -r g; do
  if head -1 "$g" | grep -q '^---$' && grep -q '^type:' "$g"; then :; else err "grader $g malformed"; ev=0; fi
done < <(find evals -path '*/graders/*.md')
[ "$ev" = 1 ] && ok "eval cases well-formed"

echo "==> No em/en dashes in sources (docs/origin excluded)"
if grep -rn -e $'\xe2\x80\x93' -e $'\xe2\x80\x94' --include='*.md' --include='*.sh' . | grep -v '/docs/origin/'; then
  err "em/en dash found above"
else
  ok "none found"
fi

echo "==> SKILL.md frontmatter"
head -1 "$SKILL/SKILL.md" | grep -q '^---$' && ok "frontmatter opens" || err "frontmatter missing"
grep -q '^name:' "$SKILL/SKILL.md" && ok "name present" || err "name missing"
grep -q '^description:' "$SKILL/SKILL.md" && ok "description present" || err "description missing"

echo "==> SKILL.md description length (< 1024)"
desc="$(awk '
  /^description:[[:space:]]*>-?/ { grab=1; next }
  grab && /^[A-Za-z_-]+:/        { grab=0 }
  grab                           { gsub(/^[[:space:]]+/,""); printf "%s ", $0 }
' "$SKILL/SKILL.md")"
len=${#desc}
if [[ "$len" -gt 0 && "$len" -lt 1024 ]]; then ok "length = $len"; else err "length = $len (must be 1..1023)"; fi

echo "==> Installer smoke test (temporary CLAUDE_DIR)"
tmp="$(mktemp -d)"
if CLAUDE_DIR="$tmp" bash install-skill.sh >/dev/null 2>&1; then
  [[ -f "$tmp/skills/zeroth/SKILL.md" ]] && ok "produced SKILL.md" || err "no SKILL.md produced"
  [[ -f "$tmp/skills/zeroth/references/zeroth.md" ]] && ok "bundled master spec" || err "master spec not bundled"
  [[ -f "$tmp/skills/zeroth/scaffold.sh" ]] && ok "bundled scaffold.sh" || err "scaffold.sh not bundled"
  [[ -f "$tmp/skills/zeroth/assets/AGENTS.md" ]] && ok "bundled assets" || err "assets not bundled"
  [[ -f "$tmp/commands/zeroth.md" ]] && ok "created /zeroth command" || err "no /zeroth command"
  [[ -f "$tmp/commands/scaffold.md" ]] && ok "created scaffold command" || err "no scaffold command"
else
  err "installer exited non-zero"
fi
rm -rf "$tmp"

echo "==> Scaffolder smoke test (temp target, incl. idempotency)"
t2="$(mktemp -d)"
if bash "$SKILL/scaffold.sh" "$t2" >/dev/null 2>&1; then
  [[ -f "$t2/.github/pull_request_template.md" ]] && ok "scaffold created PR template" || err "scaffold missing PR template"
  [[ -f "$t2/AGENTS.md" && -f "$t2/CLAUDE.md" ]] && ok "scaffold created agent guides" || err "scaffold missing agent guides"
  before="$(cd "$t2" && find . -type f -exec sha1sum {} + | sort)"
  bash "$SKILL/scaffold.sh" "$t2" >/dev/null 2>&1
  after="$(cd "$t2" && find . -type f -exec sha1sum {} + | sort)"
  [[ "$before" == "$after" ]] && ok "scaffold is idempotent (no changes on re-run)" || err "scaffold not idempotent"
  bash "$SKILL/scaffold.sh" "$t2" --with-plugin acme/demo >/dev/null 2>&1 || true
  if grep -q '"enabledPlugins"' "$t2/.claude/settings.json" 2>/dev/null && grep -q '"deny"' "$t2/.claude/settings.json" 2>/dev/null; then
    ok "--with-plugin wires team settings (merged with deny-list)"
  else
    err "--with-plugin did not wire team settings correctly"
  fi
else
  err "scaffold exited non-zero"
fi
rm -rf "$t2"

echo "==> Scaffolder branch-protection guidance"
t3="$(mktemp -d)"
( cd "$t3" && git init -q && git remote add origin https://github.com/acme/demo.git ) >/dev/null 2>&1 || true
bp_out="$(bash "$SKILL/scaffold.sh" "$t3" 2>&1 || true)"
echo "$bp_out" | grep -q "Arm branch protection" && ok "prints branch-protection next step" || err "missing branch-protection next step"
echo "$bp_out" | grep -q "repos/acme/demo/branches" && ok "personalizes protection command from origin" || err "did not personalize protection command"
bp_dry="$(bash "$SKILL/scaffold.sh" "$t3" --protect --dry-run 2>&1 || true)"
if echo "$bp_dry" | grep -qi "dry run: would PUT" && ! echo "$bp_dry" | grep -q "done: branch protection applied"; then
  ok "--protect honors --dry-run (prints, never executes)"
else
  err "--protect did not honor --dry-run"
fi
echo "$bp_out" | grep -q "repos/acme/demo/rulesets" && ok "prints the ruleset command too" || err "missing ruleset command"
echo "$bp_out" | grep -q "NOT a status check" && ok "warns enforce_admins is not a check" || err "missing enforce_admins caveat"
rs_dry="$(bash "$SKILL/scaffold.sh" "$t3" --protect --ruleset --dry-run 2>&1 || true)"
echo "$rs_dry" | grep -qi "would POST" && ok "--protect --ruleset honors --dry-run" || err "--ruleset did not honor --dry-run"
rm -rf "$t3"

echo "==> Scaffolder stack-specific CI templates"
# Each stack marker should select its real CI template (not the always-passing placeholder), which
# in turn lets the scaffolder require the 'verify' status check. bash 3.2 safe (no assoc arrays).
check_stack_ci() { # <stack> <marker-file> <signature-in-template>
  local st="$1" mk="$2" sig="$3" ts out
  ts="$(mktemp -d)"
  : > "$ts/$mk"
  out="$(bash "$SKILL/scaffold.sh" "$ts" 2>&1 || true)"
  if grep -q "$sig" "$ts/.github/workflows/verify.yml" 2>/dev/null; then
    ok "scaffold uses the $st CI template"
  else
    err "scaffold did not use the $st CI template"
  fi
  if echo "$out" | grep -q "always passes"; then
    err "$st CI still flagged as placeholder (should be a real gate)"
  else
    ok "$st CI is a real gate (requires the verify check)"
  fi
  rm -rf "$ts"
}
check_stack_ci go     go.mod      "setup-go"
check_stack_ci rust   Cargo.toml  "cargo clippy"
check_stack_ci jvm    pom.xml     "setup-java"
check_stack_ci dotnet app.csproj  "setup-dotnet"
# Mechanism proven both ways: a generic target (no stack marker) still gets the placeholder + warning.
tgen="$(mktemp -d)"
gen_out="$(bash "$SKILL/scaffold.sh" "$tgen" 2>&1 || true)"
echo "$gen_out" | grep -q "always passes" && ok "generic stack still warns (placeholder gate)" || err "generic stack lost its placeholder warning"
rm -rf "$tgen"

echo "==> CI actions pinned to SHA (repo workflow)"
if grep -qE 'uses: [^@ ]+@[0-9a-f]{40}' .github/workflows/verify.yml; then
  ok "verify.yml pins actions to a commit SHA"
else
  err "verify.yml should pin actions to a full commit SHA"
fi

echo ""
if [[ "$fail" -eq 0 ]]; then
  echo "ALL CHECKS PASSED"
else
  echo "VERIFICATION FAILED"
fi
exit "$fail"
