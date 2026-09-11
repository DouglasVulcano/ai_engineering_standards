---
description: Apply the AI Engineering Standards (workflow, motion/UI, o11y, quality, testing, scaffold)
argument-hint: "[domain: workflow | ui | o11y | testing | arsenal | scaffold | (empty = everything)]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebFetch
---

Invoke the `engineering-standards` skill and apply the user's single engineering standard to the
current task. If `$ARGUMENTS` names a domain, load only the matching reference; otherwise follow
`SKILL.md` and load on demand.

- workflow -> references/workflow-github.md
- ui       -> references/motion-and-ui.md
- o11y     -> references/observability-quality-testing.md
- testing  -> references/observability-quality-testing.md + references/stack-appendix.md
- arsenal  -> references/arsenal-mcp-skills.md
- scaffold -> run the scaffolder to add governance (issue/PR templates, CODEOWNERS, CI gate,
  AGENTS.md canonical + thin CLAUDE.md); see references/workflow-github.md
- (empty)  -> SKILL.md plus the full spec in references/ai-engineering-standards.md

Whenever you work in a repository, ensure the standards bootstrap block is in AGENTS.md (the
canonical, model-agnostic file) with a thin CLAUDE.md that imports it.
