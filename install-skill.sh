#!/usr/bin/env bash
#
# install-skill.sh — Importa o markdown de padrões como uma SKILL CENTRALIZADA do Claude Code.
#
# O que faz (idempotente):
#   1. Copia a skill `engineering-standards/` para ~/.claude/skills/  (escopo global = centralizado)
#   2. Empacota o markdown mestre `ai-engineering-standards.md` em references/ da skill
#   3. Instala o slash command `/standards` em ~/.claude/commands/
#   4. Verifica a instalação e imprime os próximos passos
#
# Uso:
#   bash ~/ai_config/install-skill.sh            # instala/atualiza (global, ~/.claude)
#   CLAUDE_DIR=./.claude bash install-skill.sh   # instala no projeto atual (escopo local)
#
set -euo pipefail

# --- Resolve caminhos ---------------------------------------------------------
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # onde este script vive (~/ai_config)
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"                 # override p/ escopo de projeto
SKILL_NAME="engineering-standards"
SKILL_DEST="$CLAUDE_DIR/skills/$SKILL_NAME"
CMD_DEST="$CLAUDE_DIR/commands"
MASTER_MD="$SRC_DIR/ai-engineering-standards.md"

echo "==> Importando skill '$SKILL_NAME'"
echo "    origem : $SRC_DIR"
echo "    destino: $SKILL_DEST"

# --- Pré-checagens ------------------------------------------------------------
if [[ ! -f "$SRC_DIR/$SKILL_NAME/SKILL.md" ]]; then
  echo "ERRO: não encontrei '$SRC_DIR/$SKILL_NAME/SKILL.md'." >&2
  echo "      Rode este script a partir do diretório ~/ai_config." >&2
  exit 1
fi
if [[ ! -f "$MASTER_MD" ]]; then
  echo "ERRO: não encontrei o markdown mestre '$MASTER_MD'." >&2
  exit 1
fi

# --- 1+2. Copia a skill e empacota o markdown mestre --------------------------
mkdir -p "$SKILL_DEST/references"
cp -f "$SRC_DIR/$SKILL_NAME/SKILL.md" "$SKILL_DEST/SKILL.md"
cp -f "$SRC_DIR/$SKILL_NAME/references/"*.md "$SKILL_DEST/references/"
cp -f "$MASTER_MD" "$SKILL_DEST/references/ai-engineering-standards.md"

# --- 3. Slash command /standards ---------------------------------------------
mkdir -p "$CMD_DEST"
cat > "$CMD_DEST/standards.md" <<'CMD'
---
description: Aplica os AI Engineering Standards (workflow, motion/UI, o11y, qualidade, testes)
argument-hint: "[domínio: workflow | ui | o11y | testes | arsenal | (vazio = tudo)]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebFetch
---

Invoque a skill `engineering-standards` e aplique o padrão único de engenharia do usuário à tarefa
atual. Se `$ARGUMENTS` indicar um domínio, carregue só a referência correspondente; caso contrário,
oriente-se pelo `SKILL.md` e carregue sob demanda.

- workflow → references/workflow-github.md
- ui       → references/motion-and-ui.md
- o11y     → references/observability-quality-testing.md
- testes   → references/observability-quality-testing.md
- arsenal  → references/arsenal-mcp-skills.md
- (vazio)  → SKILL.md + spec completa em references/ai-engineering-standards.md

Sempre que trabalhar num repositório, garanta o bloco de bootstrap dos padrões no CLAUDE.md/AGENTS.md.
CMD

# --- 4. Verificação -----------------------------------------------------------
echo ""
echo "==> Instalado:"
find "$SKILL_DEST" -type f | sed "s|^|    |"
echo "    $CMD_DEST/standards.md"

echo ""
echo "OK. Skill '$SKILL_NAME' importada de forma centralizada em $CLAUDE_DIR/skills/"
echo ""
echo "Próximos passos:"
echo "  • Reabra o Claude Code (ou rode /skills) para carregar a skill."
echo "  • Use naturalmente ('siga os padrões', 'crie a issue/PR', 'revise a UI') — a skill dispara sozinha."
echo "  • Ou invoque o slash command:  /standards         (tudo)"
echo "                                 /standards ui       (só motion/UI)"
echo "  • Em cada repo, deixe o agente alimentar CLAUDE.md/AGENTS.md com o bootstrap (ver workflow-github.md)."
echo "  • Opcional: instale os MCP servers/skills do arsenal (exigem API keys) — ver references/arsenal-mcp-skills.md."
