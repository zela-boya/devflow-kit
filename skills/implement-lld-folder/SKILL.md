---
name: implement-lld-folder
description: Use when the user types `dfi:lld-folder <LLD folder path>` to serially implement every accepted LLD in one lld folder, in filename order, with fail-fast behavior, batch implementation plan, per-LLD TCDs, code changes, verification, and batch test report before stopping at the code review gate.
---

# Implement LLD Folder

`dfi:lld-folder` means Devflow Implementation: serially implement every accepted LLD in one folder.

Use this skill when the user types:

```text
dfi:lld-folder <LLD folder path>
```

## Goal

Read one `lld/` folder and serially implement every matching LLD file in filename order.

The workflow produces:

- `docs/devflow/implementation-plan.md`, as a batch-level plan grouped by LLD
- One TCD per LLD under the current BRD design tree
- Code changes from each successfully implemented LLD
- `docs/devflow/test-report.md`, as a batch-level report grouped by LLD

Stop at the code review gate.

## Required Rule Sources

Before implementation, read and apply:

- `skills/implement-lld/SKILL.md`
- `skills/write-plan/SKILL.md`
- `skills/implement-from-plan/SKILL.md`
- `skills/test-changes/SKILL.md`

`implement-lld` remains the source of truth for single-LLD readiness, authorization, TCD generation, code execution, and test reporting. This skill owns only folder-level ordering, fail-fast behavior, and batch artifact aggregation.

## Folder Resolution

Accept exactly one readable directory path.

The directory must contain one or more files matching:

```text
LLD-[0-9][0-9][0-9][0-9]-*.md
```

If the input is not a directory, does not exist, or contains no matching LLD files, stop and report the problem.

Do not accept individual LLD files, glob expressions, multiple folders, or `latest`.

## Ordering

Sort matching LLD files by filename ascending.

Do not infer dependency order from document prose. If filename order appears to conflict with explicit dependency or delivery-order text in an LLD, stop and ask before implementation.

## Workflow

1. Parse the input after `dfi:lld-folder`.
2. Resolve exactly one readable LLD folder.
3. Discover matching `LLD-[0-9][0-9][0-9][0-9]-*.md` files.
4. Sort the LLD files by filename ascending.
5. Read the required rule-source skills listed above.
6. Confirm the current worktree state before editing.
7. Preflight each LLD with the Folder Readiness Gate.
8. Collect blocking folder-level questions.
9. If blockers exist, run the Centralized Brainstorming Loop below before code edits.
10. Generate or update a batch-level `docs/devflow/implementation-plan.md`.
11. Execute LLDs serially in filename order.
12. For each LLD:
    - Apply `implement-lld` readiness and authorization rules.
    - Generate one TCD.
    - Execute the LLD-scoped implementation plan section.
    - Run planned verification commands for that LLD.
    - Record results for the batch test report.
13. If any LLD fails or blocks, stop immediately.
14. Write `docs/devflow/test-report.md`, grouped by LLD.
15. Stop at the code review gate and recommend running `review-changes`.

## Folder Readiness Gate

Before code edits, verify:

- The folder contains at least one matching LLD file.
- All selected LLDs belong to the same BRD design tree.
- Each LLD has accepted or approved status, or the user explicitly confirms it is accepted.
- Each LLD is PR-sized according to `implement-lld`.
- Filename order is not contradicted by explicit dependency or delivery-order text.
- No LLD has a blocking open question that affects implementation behavior or delivery scope.

If any check fails, stop for brainstorming before editing code.

## Centralized Brainstorming Loop

Use this loop only for blocking folder-level or LLD-level implementation questions.

1. Group blockers by execution impact:
   - Folder selection.
   - LLD ordering.
   - LLD acceptance status.
   - LLD implementation scope.
   - Cross-LLD dependency or delivery conflict.
   - Test and verification strategy.
2. Ask one question at a time.
3. Prefer concrete options with tradeoffs and a recommendation.
4. Continue until the serial batch can start without hiding critical decisions in code.

## Fail-Fast Policy

If an LLD fails readiness, hits a blocker, fails verification, or cannot be implemented without expanding scope:

- Stop immediately.
- Do not start later LLDs.
- Preserve completed LLD results in the implementation plan and test report.
- Report completed LLDs, the failed or blocked LLD, the failure reason, remaining unexecuted LLDs, and the next recommended action.

Do not skip failed LLDs and continue.

## Batch Implementation Plan Rules

Generate or update `docs/devflow/implementation-plan.md` as one batch-level artifact.

The plan must:

- Name the source LLD folder.
- List the LLD execution order.
- Group implementation tasks by LLD.
- Preserve each LLD path and ID.
- Include verification commands per LLD.
- Record assumptions and non-blocking open questions per LLD.
- Mark completed, blocked, or pending sections when fail-fast stops execution.

If an implementation plan already exists and belongs to a different effort, ask before overwriting it.

## TCD Rules

Generate one TCD per LLD using the TCD rules from `implement-lld`.

Each TCD must:

- Use the next available TCD ID in the BRD design tree.
- Use an ASCII lower-kebab-case slug.
- Include parent metadata for its selected LLD.
- Preserve BRD traceability.
- Refuse to overwrite existing TCD files.

Each LLD receives a distinct TCD.

## Batch Test Report Rules

Write `docs/devflow/test-report.md` as one batch-level report.

The report must:

- Name the source LLD folder.
- List LLD execution order.
- Group commands and results by LLD.
- Mark each LLD as passed, failed, blocked, or not run.
- Include failure root-cause notes or next actions.
- Include remaining assumptions or risks.

## Code Execution Rules

When changing code:

- Preserve user changes and unrelated WIP.
- Execute LLDs serially; do not parallelize code edits.
- Keep each LLD implementation scoped to its LLD and batch plan section.
- Allow later LLDs to build on earlier completed LLD code changes.
- Stop before later LLDs if an earlier LLD fails.
- Run planned verification before marking each LLD complete.

## Report

Report:

- Source LLD folder.
- LLD execution order.
- Completed LLDs.
- Failed or blocked LLD, if any.
- Remaining unexecuted LLDs.
- Batch implementation plan path.
- Generated TCD paths.
- Code areas changed.
- Verification commands and results.
- Batch test report path.
- Remaining assumptions, open questions, or risks.

## Hard Stops

Do not:

- Accept a non-folder input.
- Implement LLDs outside the selected folder.
- Reorder LLDs except by filename.
- Skip failed LLDs and continue.
- Modify BRD, HLD, MLD, or LLD source documents.
- Generate code review artifacts.
- Commit or push changes.
- Open a PR.
- Fix unrelated repository issues.
