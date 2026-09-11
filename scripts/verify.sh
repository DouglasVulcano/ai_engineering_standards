#!/usr/bin/env bash
#
# verify.sh: self-check for this standards repo. Dogfoods pillar 3 (quality gate).
# Runs locally (`bash scripts/verify.sh`) and in CI (.github/workflows/verify.yml).
# No external dependencies beyond coreutils, grep, and awk.
#
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."   # repo root, regardless of where it was called from

fail=0
err() { echo "  FAIL: $*" >&2; fail=1; }
ok()  { echo "  ok:   $*"; }

echo "==> Required files"
required=(
  ai-engineering-standards.md install-skill.sh README.md README.pt-BR.md LICENSE
  engineering-standards/SKILL.md
  engineering-standards/references/workflow-github.md
  engineering-standards/references/motion-and-ui.md
  engineering-standards/references/observability-quality-testing.md
  engineering-standards/references/arsenal-mcp-skills.md
)
for f in "${required[@]}"; do
  [[ -f "$f" ]] && ok "$f" || err "missing $f"
done

echo "==> install-skill.sh syntax"
if bash -n install-skill.sh; then ok "bash -n"; else err "install-skill.sh has a syntax error"; fi

echo "==> No em/en dashes in sources (docs/origin excluded)"
# en dash U+2013 = E2 80 93, em dash U+2014 = E2 80 94 (matched as raw UTF-8 bytes for portability)
if grep -rn -e $'\xe2\x80\x93' -e $'\xe2\x80\x94' --include='*.md' --include='*.sh' . | grep -v '/docs/origin/'; then
  err "em/en dash found above"
else
  ok "none found"
fi

echo "==> SKILL.md frontmatter"
head -1 engineering-standards/SKILL.md | grep -q '^---$' && ok "frontmatter opens" || err "frontmatter missing"
grep -q '^name:' engineering-standards/SKILL.md && ok "name present" || err "name missing"
grep -q '^description:' engineering-standards/SKILL.md && ok "description present" || err "description missing"

echo "==> SKILL.md description length (< 1024)"
desc="$(awk '
  /^description:[[:space:]]*>-?/ { grab=1; next }
  grab && /^[A-Za-z_-]+:/        { grab=0 }
  grab                           { gsub(/^[[:space:]]+/,""); printf "%s ", $0 }
' engineering-standards/SKILL.md)"
len=${#desc}
if [[ "$len" -gt 0 && "$len" -lt 1024 ]]; then ok "length = $len"; else err "length = $len (must be 1..1023)"; fi

echo "==> Installer smoke test (temporary CLAUDE_DIR)"
tmp="$(mktemp -d)"
if CLAUDE_DIR="$tmp" bash install-skill.sh >/dev/null 2>&1; then
  [[ -f "$tmp/skills/engineering-standards/SKILL.md" ]] && ok "produced SKILL.md" || err "no SKILL.md produced"
  [[ -f "$tmp/skills/engineering-standards/references/ai-engineering-standards.md" ]] && ok "bundled master spec" || err "master spec not bundled"
  [[ -f "$tmp/commands/standards.md" ]] && ok "created /standards command" || err "no /standards command"
else
  err "installer exited non-zero"
fi
rm -rf "$tmp"

echo ""
if [[ "$fail" -eq 0 ]]; then
  echo "ALL CHECKS PASSED"
else
  echo "VERIFICATION FAILED"
fi
exit "$fail"
