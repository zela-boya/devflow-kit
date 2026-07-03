---
description: Generate HLD, MLD, and LLD drafts from an accepted BRD
argument-hint: [BRD path, BRD id, latest, or 最新 BRD]
allowed-tools: [Read, Bash, Write, Edit]
---

# /dfd:design-tree

Generate a design document tree from one accepted BRD through LLD.

## Arguments

The user invoked this command with: `$ARGUMENTS`

`$ARGUMENTS` may be:

- A BRD file path.
- A BRD ID such as `BRD-0001`.
- `latest`, `latest BRD`, or `最新 BRD`.

## Workflow

1. Read `skills/gen-design-tree/SKILL.md`.
2. Treat `$ARGUMENTS` as the BRD selector.
3. Resolve exactly one accepted BRD.
4. Read and apply:
   - `skills/gen-hld/SKILL.md`
   - `skills/gen-mld/SKILL.md`
   - `skills/gen-lld/SKILL.md`
5. Preflight the HLD, MLD, and LLD split tree before writing files.
6. Use centralized brainstorming to resolve every blocking question.
7. Generate HLD, MLD, and LLD draft files.
8. Validate with:

```bash
scripts/devflow design validate --target <target-repo>
```

9. Stop at the LLD review gate. Do not generate TCD, code, commits, or PRs.

## Summary

Report the source BRD path, generated design files, split decisions, validation result, and remaining non-blocking open questions.
