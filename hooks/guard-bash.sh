#!/usr/bin/env bash
# PreToolUse(Bash) guard: block a small set of clearly catastrophic commands.
# Fail-open by design: if anything is off (no python3, parse error), it allows the command.
# Deterministic safety net that complements the settings.json deny-list.
command -v python3 >/dev/null 2>&1 || exit 0
exec python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/guard_bash.py"
