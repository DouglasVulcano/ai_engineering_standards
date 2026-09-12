# Evals

A self-test suite for the `zeroth` plugin, run with `claude plugin eval` (early
access). It proves the package changes behavior and catches regressions in CI.

## Cases
- `scaffold-greenfield/` a fresh repo gets governance scaffolded (file_exists: PR template, AGENTS.md,
  CLAUDE.md).
- `skill-activation/` a realistic request activates the skill (tool_used).
- `agents-md-quality/` the generated AGENTS.md is repo-specific, not a generic template (llm).

## Run
```bash
# from the repo root; --ablation with-without runs each case with AND without the plugin (control arm)
claude plugin eval . \
  --ablation with-without \
  --runs 3 \
  --threshold 0.8 \
  --allow-tools Read Glob Grep Write Edit 'Bash(bash:*)' \
  --json ./eval-run.json
```
Exit 0 = all cases at or above threshold; 1 = a case below threshold; 2 = cost ceiling hit. Read the
with/without delta: a case that already passes "without" the plugin means the package added nothing
there (a gap to fix).

## Notes
- `claude plugin eval` is early access; if it is not enabled for your org the command prints a notice.
  Until then, `scripts/verify.sh` provides the deterministic smoke tests (installer, scaffolder,
  hooks).
- The `tool_used` matcher in `skill-activation` targets the skill name `zeroth`. If a
  run records skill activation under the generic `Skill` tool instead, change the grader to
  `tool_name: Skill` (optionally with an `input_match`). Confirm on the first live run.
- `scaffold-greenfield` needs Bash + Write allowed so the agent can run the scaffolder; the
  `--allow-tools` list above covers it.
