"""PreToolUse(Write|Edit) guard. Blocks writes to files that look like secrets/credentials.
Exit 2 blocks (stderr is the reason), exit 0 allows. Fail-open on any error."""
import json
import re
import sys

try:
    data = json.load(sys.stdin)
    fp = (data.get("tool_input") or {}).get("file_path", "") or ""
except Exception:
    sys.exit(0)  # fail-open

SENSITIVE = [
    r"(^|/)\.env(\.|$)",
    r"\.pem$",
    r"\.p12$",
    r"(^|/)id_rsa",
    r"(^|/)\.npmrc$",
    r"(^|/)\.git-credentials$",
    r"(^|/)credentials(\.json)?$",
    r"(^|/)\.aws/credentials$",
]

for pattern in SENSITIVE:
    if re.search(pattern, fp):
        sys.stderr.write(
            "Blocked by engineering-standards guard: '%s' looks like a secrets/credentials file. "
            "Edit it yourself if that is intended.\n" % fp
        )
        sys.exit(2)

sys.exit(0)
