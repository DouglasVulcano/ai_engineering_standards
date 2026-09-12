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

# Template/placeholder files carry no real secret and exist to be committed
# (.env.example, credentials.json.sample, config.php.dist, ...). Allow them even when
# the name resembles a secret. Checked BEFORE the block list.
ALLOW = [
    r"\.(example|sample|template|dist)$",
]

SENSITIVE = [
    r"(^|/)\.env(\.|$)",
    r"\.pem$",
    r"\.p12$",
    r"\.pfx$",
    r"\.key$",
    r"(^|/)id_(rsa|dsa|ecdsa|ed25519)\b",
    r"(^|/)\.npmrc$",
    r"(^|/)\.pypirc$",
    r"(^|/)\.git-credentials$",
    r"(^|/)credentials(\.json)?$",
    r"(^|/)\.aws/credentials$",
    r"(^|/)secrets?\.(ya?ml|json)$",
    r"(^|/)service-account[^/]*\.json$",
]

for pattern in ALLOW:
    if re.search(pattern, fp):
        sys.exit(0)  # safe template/placeholder, not a real secret

for pattern in SENSITIVE:
    if re.search(pattern, fp):
        sys.stderr.write(
            "Blocked by zeroth guard: '%s' looks like a secrets/credentials file. "
            "Edit it yourself if that is intended.\n" % fp
        )
        sys.exit(2)

sys.exit(0)
