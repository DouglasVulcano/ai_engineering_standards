#!/usr/bin/env bash
# SessionStart hook: when the repo lacks the Zeroth bootstrap, suggest scaffolding it.
# Advisory and non-blocking. Fail-open: if anything is off (no python3, parse error), print nothing.
command -v python3 >/dev/null 2>&1 || exit 0
exec python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/session_bootstrap.py"
