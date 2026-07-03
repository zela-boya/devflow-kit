---
description: Generate one or more LLD drafts from an accepted MLD
argument-hint: [MLD path, MLD id, latest, or 最新 MLD]
allowed-tools: [Read, Bash, Write, Edit]
---

# /dfd:lld

Generate one or more Low-Level Design drafts from an accepted MLD.

## Arguments

The user invoked this command with: `$ARGUMENTS`

`$ARGUMENTS` may be:

- An MLD file path.
- An MLD ID such as `MLD-0001`.
- `latest`, `latest MLD`, or `最新 MLD`.

## Workflow

1. Read `skills/gen-lld/SKILL.md`.
2. Treat `$ARGUMENTS` as the MLD selector.
3. Resolve exactly one accepted MLD.
4. Generate LLD draft files under the same BRD-scoped design tree.
5. Validate with:

```bash
scripts/devflow design validate --target <target-repo>
```

6. Stop at the LLD review gate. Do not generate TCD, code, commits, or PRs.

## Summary

Report the source MLD path, generated LLD files, validation result, and remaining open questions.
