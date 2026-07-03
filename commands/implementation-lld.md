---
description: Implement one accepted LLD with plan, TCD, code changes, and test report
argument-hint: [LLD path or LLD id]
allowed-tools: [Read, Bash, Write, Edit]
---

# /dfi:lld

Implement exactly one accepted LLD and stop at the code review gate.

## Arguments

The user invoked this command with: `$ARGUMENTS`

`$ARGUMENTS` may be:

- An LLD file path.
- A unique LLD ID such as `LLD-0001`.

`latest` is intentionally not accepted for implementation.

## Workflow

1. Read `skills/implement-lld/SKILL.md`.
2. Treat `$ARGUMENTS` as the LLD selector.
3. Resolve exactly one LLD.
4. Read and apply:
   - `skills/write-plan/SKILL.md`
   - `skills/implement-from-plan/SKILL.md`
   - `skills/test-changes/SKILL.md`
5. Check LLD implementation readiness.
6. Use centralized brainstorming to resolve every blocking implementation question.
7. Generate or update `docs/devflow/implementation-plan.md`.
8. Generate one TCD under the BRD design tree.
9. Make code changes according to the LLD and implementation plan.
10. Run planned verification commands.
11. Write `docs/devflow/test-report.md`.
12. Stop at the code review gate. Do not generate code review artifacts, commit, push, or open a PR.

## Summary

Report the source LLD path, implementation plan path, TCD path, changed code areas, verification results, test report path, and remaining risks.
