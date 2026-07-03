---
description: Generate one or more BRD drafts from business input
argument-hint: [business text or source document path]
allowed-tools: [Read, Bash, Write, Edit]
---

# /dfd:brd

Generate one or more Business Requirement Document drafts from raw business input.

## Arguments

The user invoked this command with: `$ARGUMENTS`

`$ARGUMENTS` may be:

- A short business request.
- A longer business description.
- A local file path containing business requirements.

## Workflow

1. Read `skills/dfd-gen-brd/SKILL.md`.
2. Treat `$ARGUMENTS` as the source input.
3. If `$ARGUMENTS` is a readable file path, read that file before analysis.
4. Use the skill's conservative/draft strategy:
   - Ask one clarifying question when core BRD information is missing.
   - Generate a draft when only non-core details are missing.
5. If multiple independent BRDs are detected, summarize the proposed split and ask for confirmation before writing files.
6. Resolve the Devflow script path using the script resolution rules below.
7. Generate BRD files with the resolved Devflow script.
8. Validate generated BRDs with the resolved Devflow script.
9. Stop at the BRD review gate. Do not generate HLD, MLD, LLD, TCD, code, commits, or PRs.

## Script Resolution

The target repository usually does not contain `scripts/devflow`. Resolve the Devflow script from the plugin install instead of assuming the current working directory is this plugin repository.

Use the first executable path that exists:

```bash
./scripts/devflow
$HOME/plugins/dfd/scripts/devflow
$HOME/.codex/plugins/cache/local-devflow/dfd/0.1.0/scripts/devflow
```

If none exists, report that Devflow Kit is not installed or the local plugin cache is missing, and ask the user to run this plugin's `install.sh`.

## Commands

Use the resolved Devflow script path:

```bash
"<devflow-script>" design gen-brd --target <target-repo> --title "<title>" --context "<context>" --scope "<scope>" --requirement "<requirement>"
"<devflow-script>" design validate --target <target-repo>
```

## Summary

Report generated file paths, validation result, and open questions needing user review.
