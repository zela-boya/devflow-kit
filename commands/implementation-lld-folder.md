---
description: Serially implement every accepted LLD in one folder
argument-hint: [LLD folder path]
allowed-tools: [Read, Bash, Write, Edit]
---

# /dfi:lld-folder

Serially implement every accepted LLD in one `lld/` folder and stop at the code review gate.

## Arguments

The user invoked this command with: `$ARGUMENTS`

`$ARGUMENTS` must be one readable LLD folder path containing files named:

```text
LLD-[0-9][0-9][0-9][0-9]-*.md
```

## Workflow

1. Read `skills/implement-lld-folder/SKILL.md`.
2. Treat `$ARGUMENTS` as the LLD folder selector.
3. Discover matching LLD files and sort them by filename.
4. Read and apply:
   - `skills/implement-lld/SKILL.md`
   - `skills/write-plan/SKILL.md`
   - `skills/implement-from-plan/SKILL.md`
   - `skills/test-changes/SKILL.md`
5. Preflight the folder and each LLD before code edits.
6. Use centralized brainstorming to resolve every blocking folder or LLD question.
7. Generate or update a batch-level `docs/devflow/implementation-plan.md`.
8. Serially implement each LLD in filename order.
9. Generate one TCD per LLD.
10. Run planned verification commands.
11. Write a batch-level `docs/devflow/test-report.md`.
12. Fail fast on the first blocked or failed LLD.
13. Stop at the code review gate. Do not generate code review artifacts, commit, push, or open a PR.

## Summary

Report the source folder, LLD execution order, completed LLDs, failed or blocked LLD if any, remaining LLDs, generated TCD paths, verification results, test report path, and remaining risks.
