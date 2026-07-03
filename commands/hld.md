---
description: Generate one or more HLD drafts from an accepted BRD
argument-hint: [BRD path, BRD id, latest, or 最新 BRD]
allowed-tools: [Read, Bash, Write, Edit]
---

# /dfd:hld

Generate one or more High-Level Design drafts from an accepted BRD.

## Arguments

The user invoked this command with: `$ARGUMENTS`

`$ARGUMENTS` may be:

- A BRD file path.
- A BRD ID such as `BRD-0001`.
- `latest`, `latest BRD`, or `最新 BRD`.

## Workflow

1. Read `skills/gen-hld/SKILL.md`.
2. Treat `$ARGUMENTS` as the BRD selector.
3. Resolve exactly one accepted BRD.
4. Generate HLD draft files under the BRD-scoped design tree.
5. Validate with:

```bash
scripts/devflow design validate --target <target-repo>
```

6. Stop at the HLD review gate. Do not generate MLD, LLD, TCD, code, commits, or PRs.

## Summary

Report the source BRD path, generated HLD files, validation result, and remaining open questions.
