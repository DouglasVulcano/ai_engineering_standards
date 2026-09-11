#!/usr/bin/env bash
# PreToolUse(Write|Edit|MultiEdit) guard: block edits to files that look like secrets/credentials.
# Fail-open by design: if anything is off (no python3, parse error), it allows the edit.
command -v python3 >/dev/null 2>&1 || exit 0
exec python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/guard_paths.py"
