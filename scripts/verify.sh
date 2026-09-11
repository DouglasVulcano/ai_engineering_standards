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
SKILL="skills/engineering-standards"

echo "==> Required files"
required=(
  ai-engineering-standards.md install-skill.sh README.md README.pt-BR.md LICENSE
  AGENTS.md CLAUDE.md CONTRIBUTING.md CHANGELOG.md SECURITY.md
  .claude-plugin/plugin.json .claude-plugin/marketplace.json
  commands/standards.md commands/scaffold.md
  "$SKILL/SKILL.md" "$SKILL/scaffold.sh"
  "$SKILL/references/workflow-github.md"
  "$SKILL/references/motion-and-ui.md"
  "$SKILL/references/observability-quality-testing.md"
  "$SKILL/references/stack-appendix.md"
  "$SKILL/references/arsenal-mcp-skills.md"
  "$SKILL/assets/AGENTS.md" "$SKILL/assets/CLAUDE.md" "$SKILL/assets/settings.json"
  "$SKILL/assets/github/pull_request_template.md"
  "$SKILL/assets/github/CODEOWNERS"
  "$SKILL/assets/github/workflows/ci.yml"
  hooks/hooks.json hooks/guard-bash.sh hooks/guard_bash.py hooks/guard-paths.sh hooks/guard_paths.py
  evals/README.md evals/scaffold-greenfield/prompt.md
)
for f in "${required[@]}"; do
  [[ -f "$f" ]] && ok "$f" || err "missing $f"
done

echo "==> Shell syntax"
for s in install-skill.sh scripts/verify.sh "$SKILL/scaffold.sh" hooks/guard-bash.sh hooks/guard-paths.sh; do
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
assert p.get("name")=="engineering-standards", "plugin name"
assert p.get("version"), "plugin version"
names=[x.get("name") for x in m.get("plugins",[])]
assert "engineering-standards" in names, "marketplace lists the plugin"
print("  ok:   plugin/marketplace consistent (v%s)" % p["version"])
PY

echo "==> Python syntax (hooks)"
for p in hooks/guard_bash.py hooks/guard_paths.py; do
  python3 -m py_compile "$p" && ok "py_compile $p" || err "$p has a syntax error"
done

echo "==> Hook behavior (guards block/allow, fail-open)"
run_hook() { printf '%s' "$2" | bash "$1" >/dev/null 2>&1; echo $?; }
[ "$(run_hook hooks/guard-bash.sh '{"tool_input":{"command":"rm -rf /"}}')" = 2 ] && ok "guard-bash blocks rm -rf /" || err "guard-bash did not block rm -rf /"
[ "$(run_hook hooks/guard-bash.sh '{"tool_input":{"command":"npm test"}}')" = 0 ] && ok "guard-bash allows npm test" || err "guard-bash blocked a safe command"
[ "$(run_hook hooks/guard-bash.sh 'not-json')" = 0 ] && ok "guard-bash fail-open on bad input" || err "guard-bash not fail-open"
[ "$(run_hook hooks/guard-paths.sh '{"tool_input":{"file_path":"config/.env"}}')" = 2 ] && ok "guard-paths blocks .env" || err "guard-paths did not block .env"
[ "$(run_hook hooks/guard-paths.sh '{"tool_input":{"file_path":"src/app.ts"}}')" = 0 ] && ok "guard-paths allows source" || err "guard-paths blocked a safe path"

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
  [[ -f "$tmp/skills/engineering-standards/SKILL.md" ]] && ok "produced SKILL.md" || err "no SKILL.md produced"
  [[ -f "$tmp/skills/engineering-standards/references/ai-engineering-standards.md" ]] && ok "bundled master spec" || err "master spec not bundled"
  [[ -f "$tmp/skills/engineering-standards/scaffold.sh" ]] && ok "bundled scaffold.sh" || err "scaffold.sh not bundled"
  [[ -f "$tmp/skills/engineering-standards/assets/AGENTS.md" ]] && ok "bundled assets" || err "assets not bundled"
  [[ -f "$tmp/commands/standards.md" ]] && ok "created /standards command" || err "no /standards command"
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

echo ""
if [[ "$fail" -eq 0 ]]; then
  echo "ALL CHECKS PASSED"
else
  echo "VERIFICATION FAILED"
fi
exit "$fail"
