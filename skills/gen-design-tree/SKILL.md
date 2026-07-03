---
name: gen-design-tree
description: Use when the user types `dfd:design-tree <BRD path or BRD id>` to generate HLD, MLD, and LLD drafts from one accepted BRD in a single centralized-brainstorming workflow without proceeding to TCD, code, commits, or PRs.
---

# Generate Design Tree

`dfd:design-tree` means Devflow Design: generate a provisional design tree from an accepted BRD through LLD.

Use this skill when the user types:

```text
dfd:design-tree <BRD path>
dfd:design-tree <BRD id>
dfd:design-tree latest
dfd:design-tree 最新 BRD
```

## Goal

Read one accepted BRD and generate the draft/provisional design tree under:

```text
docs/design/<BRD file basename>/hld/
docs/design/<BRD file basename>/mld/
docs/design/<BRD file basename>/lld/
```

This is an explicit provisional workflow: it can generate HLD, MLD, and LLD drafts in one pass before separate per-level acceptance.

The workflow stops at the LLD review gate. It does not remove or bypass the normal HLD, MLD, and LLD acceptance gates required before implementation authorization.

## Required Rule Sources

Before generating files, read and apply the current rules from:

- `skills/gen-hld/SKILL.md`
- `skills/gen-mld/SKILL.md`
- `skills/gen-lld/SKILL.md`

Those skills remain the source of truth for HLD, MLD, and LLD gates, split rules, content rules, numbering, filenames, validation, and hard stops.

This skill owns only the cross-layer orchestration:

- BRD resolution.
- Preflight design-tree inference.
- Cross-layer blocker collection.
- Centralized brainstorming for blocking questions.
- One-pass HLD, MLD, and LLD draft generation.
- Final validation and reporting.

## BRD Resolution

Accept these input forms:

- Readable BRD file path, such as `docs/brd/BRD-0001-example.md`.
- BRD ID, such as `BRD-0001`; find the matching file under `docs/brd/`.
- `latest`, `latest BRD`, or `最新 BRD`; select the highest numbered `BRD-*.md` under `docs/brd/`.

If the input does not resolve to exactly one BRD, list the candidates and ask the user to choose.

Do not accept raw business text. If the user provides raw business text, tell them to run `dfd:brd` first.

## Workflow

1. Parse the input after `dfd:design-tree`.
2. Resolve exactly one source BRD.
3. Read the source BRD.
4. Read the HLD, MLD, and LLD skill files listed above.
5. Apply the BRD Scope Gate from `gen-hld`.
6. Infer the intended HLD, MLD, and LLD split tree without writing files.
7. Collect all blocking questions that would change design-tree shape or implementation scope.
8. If blockers exist, run the Centralized Brainstorming Loop below.
9. Confirm every generated MLD maps to exactly one generated HLD and every generated LLD maps to exactly one generated MLD.
10. Generate HLD, MLD, and LLD draft files in one pass.
11. Run the available design validation command.
12. Report generated files, split decisions, validation result, and remaining non-blocking open questions.

## Centralized Brainstorming Loop

Use this loop only for blocking questions.

1. Group blockers by impact order:
   - BRD scope.
   - HLD boundaries.
   - MLD module-contract boundaries.
   - LLD PR-sized boundaries.
   - API, data, state, permission, error, rollout, or delivery-order choices.
2. Ask one question at a time.
3. Prefer concrete options with tradeoffs and a recommendation.
4. After each answer, update the inferred design tree and remove resolved blockers.
5. Continue until the HLD, MLD, and LLD drafts can be generated without changing unresolved assumptions into hidden design decisions.

Do not write partial HLD, MLD, or LLD files before the blocking loop is resolved.

## Blocking Question Policy

Ask before writing files when an unresolved question can change:

- Whether the BRD is too broad for a useful HLD.
- Whether the BRD should be split before design continues.
- HLD coverage boundaries or whether multiple HLDs are justified.
- MLD module ownership, interface direction, data ownership, error handling, security, or observability.
- LLD PR-sized implementation scope.
- Whether each generated MLD has exactly one generated HLD parent and each generated LLD has exactly one generated MLD parent.
- API behavior, data schema, state transitions, permissions, errors, rollout order, delivery dependencies, or rollback behavior.

Record non-blocking unknowns in the generated documents' open-question sections.

## Split Strategy

Default to automatic splitting with conservative gates:

- One valid BRD usually produces one HLD.
- Multiple HLDs are rare and require clear independent high-level design surfaces.
- Multiple MLDs are generated directly only when the inferred or explicit HLD split has clear module-contract design value.
- Multiple LLDs are generated directly only when the inferred or explicit MLD split has clear PR-sized implementation value.
- Ambiguous, too-broad, or too-granular splits become centralized brainstorming blockers.

Do not generate a project-overview HLD, catch-all MLD, or catch-all LLD as a fallback.

## Generation Rules

When writing files:

- Preserve all relevant BRD decisions, constraints, risks, and technical facts.
- Apply the HLD content rules from `gen-hld`.
- Apply the MLD content rules from `gen-mld`.
- Apply the LLD content rules from `gen-lld`.
- Use ASCII-only lower-kebab-case slugs for file and design directory names.
- Keep Chinese in titles and body only, not paths.
- Increment HLD, MLD, and LLD numbers inside the current BRD design folder and document-type directory.
- Refuse to overwrite existing files.
- Include parent metadata with ID, relative path, and title.
- Preserve BRD/HLD/MLD traceability in child documents.

Before writing files, every generated MLD must be attached to exactly one generated HLD, and every generated LLD must be attached to exactly one generated MLD. Ambiguous parent mapping is a blocking brainstorming question.

## Validation

After writing files, run:

```bash
scripts/devflow design validate --target <target-repo>
```

If the validator currently checks only BRD structure, still run it and report that HLD, MLD, and LLD validation is not yet automated.

## Report

Report:

- Source BRD path.
- Generated HLD files.
- Generated MLD files.
- Generated LLD files.
- Split decisions and any choices made during brainstorming.
- Validation command and result.
- Remaining non-blocking open questions.

## Hard Stops

Do not:

- Generate a BRD from raw business text.
- Modify the source BRD.
- Generate TCD files.
- Write implementation code.
- Commit or push generated files.
- Open a PR.
- Overwrite existing design files.
