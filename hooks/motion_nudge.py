"""PostToolUse hook. After a Write/Edit/MultiEdit to a UI file, scan the written content for a small
set of high-signal Zeroth Pillar 2 anti-patterns and return a non-blocking advisory via
additionalContext. Silent (prints nothing) when the file is not UI, no anti-pattern is present, or on
any error. Never blocks (PostToolUse runs after the tool has already executed)."""
import json
import re
import sys

UI_EXT = (
    ".css", ".scss", ".sass", ".less", ".tsx", ".jsx", ".vue", ".svelte", ".astro",
    ".html", ".htm", ".mdx",
)

# (compiled pattern, short label, the rule to apply)
CHECKS = [
    (re.compile(r"transition(-property)?\s*:\s*all\b", re.I),
     "transition: all",
     "animate only specific compositor-friendly properties (transform, opacity), never `all`"),
    (re.compile(r"<(div|span|li)\b[^>]*\son[Cc]lick\s*=", re.I),
     "<div onClick>",
     "use a <button> for actions (keyboard and a11y), not an onClick on a div/span/li"),
]


def content_from(tool_name, ti):
    if tool_name == "Write":
        return ti.get("file_text") or ti.get("content") or ""
    if tool_name == "Edit":
        return ti.get("new_string") or ""
    if tool_name == "MultiEdit":
        return "\n".join((e or {}).get("new_string", "") for e in (ti.get("edits") or []))
    return ""


try:
    data = json.load(sys.stdin)
    ti = data.get("tool_input") or {}
    fp = ti.get("file_path", "") or ""
    if not fp.lower().endswith(UI_EXT):
        sys.exit(0)
    body = content_from(data.get("tool_name", ""), ti)
    if not body:
        sys.exit(0)
    hits = ["`%s`: %s" % (label, rule) for rx, label, rule in CHECKS if rx.search(body)]
    if not hits:
        sys.exit(0)
    msg = (
        "Zeroth Pillar 2 (motion/UI) check on %s: " % fp
        + "; ".join(hits)
        + ". Consider fixing before commit; run `/zeroth-review` for a full audit."
    )
    json.dump(
        {"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": msg}},
        sys.stdout,
    )
    sys.exit(0)
except Exception:
    sys.exit(0)  # fail-open, quiet
