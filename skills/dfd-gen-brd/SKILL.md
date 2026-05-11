---
name: dfd-gen-brd
description: Use when the user invokes /dfd:gen-brd to analyze raw business input or a source document and generate one or more BRD draft files under docs/brd using the BRD template.
---

# DFD Generate BRD

`/dfd:gen-brd` means Devflow Design: generate BRD.

Use this skill when the user types:

```text
/dfd:gen-brd <business text>
/dfd:gen-brd <path-to-source-document>
```

## Goal

Analyze raw business input and generate one or more BRD draft files in the target repository under:

```text
docs/brd/
```

Use `templates/brd.md` as the document shape.

## Required Behavior

1. Parse the input after `/dfd:gen-brd`.
2. If the input is a readable local file path, read the file and use its contents as the source.
3. Determine whether the source describes one BRD or multiple independent BRDs.
4. If multiple BRDs are detected, summarize the proposed split and ask for user confirmation before creating files.
5. If only one BRD is needed and core information is sufficient, generate a draft.
6. After writing BRD files, stop at a review gate. Do not generate HLD, MLD, LLD, TCD, code, commits, or PRs.

## Missing Information Strategy

Use a mixed conservative/draft strategy.

If core information is missing, ask a clarifying question before generating a BRD:

- Business context: why this is needed and what problem exists.
- At least one clear business requirement: what the business needs the system or process to support.
- Approximate business scope: what area or flow the BRD covers.

If non-core details are missing, generate a draft and put uncertainty into `开放问题`:

- Incomplete stakeholders.
- Incomplete constraints.
- Incomplete success criteria.
- Incomplete risks.
- Incomplete technical context.
- Imperfect requirement grouping.

Ask one clarifying question at a time.

## Split Rules

Before generating multiple BRDs, ask for confirmation when the input contains:

- Multiple independent business goals.
- Multiple independent business flows.
- Different stakeholders and success criteria.
- Work that could be shipped or accepted independently.

## Generation Command

Use the script for file creation:

```bash
scripts/devflow design gen-brd \
  --target <target-repo> \
  --title "<business summary>" \
  --context "<business context>" \
  --scope "<business scope>" \
  --requirement "<one sentence requirement>"
```

Use repeated options when applicable:

```bash
--requirement "<one sentence requirement>"
--stakeholder "<party>|<role/responsibility>|<concern>"
--constraint "<constraint>"
--success "<success criterion>"
--risk "<risk>|<high/medium/low>|<impact>|<mitigation>"
--open-question "<question>"
```

The script computes the next global BRD number by scanning `docs/brd/`.

## Validation

After generation, run:

```bash
scripts/devflow design validate --target <target-repo>
```

Report:

- Generated file paths.
- Whether validation passed.
- Any open questions that need user review.

## Hard Stops

Do not:

- Generate HLD, MLD, LLD, or TCD from this command.
- Write implementation code.
- Commit or push generated files unless the user explicitly asks.
- Overwrite an existing BRD file.
