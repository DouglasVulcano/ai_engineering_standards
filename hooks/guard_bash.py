"""PreToolUse(Bash) guard. Reads the hook JSON on stdin; exit 2 blocks the command
(stderr becomes the reason shown to the model), exit 0 allows. Fail-open on any error."""
import json
import re
import sys

try:
    data = json.load(sys.stdin)
    cmd = (data.get("tool_input") or {}).get("command", "") or ""
except Exception:
    sys.exit(0)  # fail-open: never break the session

RULES = [
    (r"\brm\b(?:\s+-[a-zA-Z]+)+\s+(?:/|~|\$HOME)(?:[*/]|\s|$)", "recursive rm targeting / or home"),
    (r"\bgit\s+push\s+(?:--force\b|-f\b)", "git push --force"),
    (r"\bmkfs(?:\.\w+)?\b", "mkfs (formats a filesystem)"),
    (r"\bdd\b[^\n]*\bof=/dev/", "dd writing directly to a device"),
    (r":\s*\(\s*\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;\s*:", "fork bomb"),
    (r"\bchmod\b\s+-R\s+0*777\s+/", "chmod -R 777 on /"),
    (r">\s*/dev/sd[a-z]\b", "writing to a raw disk device"),
]

for pattern, why in RULES:
    if re.search(pattern, cmd):
        sys.stderr.write(
            "Blocked by engineering-standards guard: %s. "
            "This looks destructive; run it yourself if it is truly intended.\n" % why
        )
        sys.exit(2)

sys.exit(0)
