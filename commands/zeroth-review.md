---
description: Audit the current changes against the Zeroth standard (delegates to the zeroth-reviewer subagent)
argument-hint: "[PR number | base branch | empty = working-tree changes]"
allowed-tools: Read, Grep, Glob, Bash, Agent
---

Audit the current change set against the Zeroth engineering standard, then report. This is an advisory
pre-PR check; CI plus branch protection remain the authoritative gate. Do not edit any files.

Delegate to the `zeroth-reviewer` subagent and have it review:
- if `$ARGUMENTS` is a PR number, that PR (`gh pr diff $ARGUMENTS`);
- if `$ARGUMENTS` is a branch name, `git diff $ARGUMENTS...HEAD`;
- otherwise the working-tree changes (`git diff` plus `git diff --staged`).

If the `zeroth-reviewer` subagent is not available (for example a global-skill install without the
plugin), do the same review inline and read-only: load the relevant `references/`, get the diff, audit
it against the 4 pillars, and return the same structured findings report. Never edit, stage, or commit.
