"""SessionStart hook. When the working directory is a git repo that does not yet carry the Zeroth
bootstrap in AGENTS.md/CLAUDE.md, inject a one-line suggestion to scaffold it. Non-blocking and quiet:
prints nothing (and never blocks) when the bootstrap is present, when the directory is not a project,
or on any error."""
import json
import os
import sys


def emit(context):
    json.dump(
        {"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": context}},
        sys.stdout,
    )
    sys.exit(0)


try:
    data = json.load(sys.stdin)
    cwd = data.get("cwd") or os.getcwd()
    # Do not re-inject on compaction or fork; the context already carries it.
    if data.get("startup_reason") in ("compact", "fork"):
        sys.exit(0)
    # Only speak inside a project (a git working tree).
    if not os.path.isdir(os.path.join(cwd, ".git")):
        sys.exit(0)
    # Already bootstrapped? Look for the Zeroth marker in AGENTS.md / CLAUDE.md.
    for name in ("AGENTS.md", "CLAUDE.md"):
        try:
            with open(os.path.join(cwd, name), "r", encoding="utf-8", errors="ignore") as fh:
                if "zeroth" in fh.read().lower():
                    sys.exit(0)
        except OSError:
            continue
    emit(
        "This repository does not yet carry the Zeroth standard. To add governance (issue/PR "
        "templates, CODEOWNERS, a CI gate, AGENTS.md plus a thin CLAUDE.md), run `/zeroth scaffold`. "
        "To apply the standard to the current task, use `/zeroth`. This is a one-time suggestion; it "
        "stops once the bootstrap is in AGENTS.md."
    )
except Exception:
    sys.exit(0)  # fail-open, quiet
