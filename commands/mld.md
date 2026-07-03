---
description: Generate one or more MLD drafts from an accepted HLD
argument-hint: [HLD path, HLD id, latest, or 最新 HLD]
allowed-tools: [Read, Bash, Write, Edit]
---

# /dfd:mld

Generate one or more Medium-Level Design drafts from an accepted HLD.

## Arguments

The user invoked this command with: `$ARGUMENTS`

`$ARGUMENTS` may be:

- An HLD file path.
- An HLD ID such as `HLD-0001`.
- `latest`, `latest HLD`, or `最新 HLD`.

## Workflow

1. Read `skills/gen-mld/SKILL.md`.
2. Treat `$ARGUMENTS` as the HLD selector.
3. Resolve exactly one accepted HLD.
4. Generate MLD draft files under the same BRD-scoped design tree.
5. Validate with:

```bash
scripts/devflow design validate --target <target-repo>
```

6. Stop at the MLD review gate. Do not generate LLD, TCD, code, commits, or PRs.

## Summary

Report the source HLD path, generated MLD files, validation result, and remaining open questions.
