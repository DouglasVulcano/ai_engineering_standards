#!/usr/bin/env bash
# PostToolUse(Write|Edit|MultiEdit) hook: flag Zeroth Pillar 2 motion anti-patterns in UI files.
# Advisory and non-blocking. Fail-open: prints nothing on clean writes, non-UI files, or any error.
command -v python3 >/dev/null 2>&1 || exit 0
exec python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/motion_nudge.py"
