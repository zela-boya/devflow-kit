---
name: implement-lld
description: Use when the user types `dfi:lld <LLD path or LLD id>` to implement exactly one accepted LLD by generating an implementation plan, generating a TCD, changing code, running verification, and writing a test report before stopping at the code review gate.
---

# Implement LLD

`dfi:lld` means Devflow Implementation: implement one accepted LLD.

Use this skill when the user types:

```text
dfi:lld <LLD path>
dfi:lld <LLD id>
```

## Goal

Read one accepted LLD and convert it into:

- `docs/devflow/implementation-plan.md`
- One TCD under the current BRD design tree
- Code changes scoped to the selected LLD
- `docs/devflow/test-report.md`

Stop at the code review gate.

## Required Rule Sources

Before implementation, read and apply:

- `skills/write-plan/SKILL.md`
- `skills/implement-from-plan/SKILL.md`
- `skills/test-changes/SKILL.md`

Those skills remain the source of truth for implementation planning, scoped code execution, and test reporting. This skill owns only the LLD-to-code orchestration.

## LLD Resolution

Accept these input forms:

- Readable LLD file path, such as `docs/design/BRD-0001-example/lld/LLD-0001-api-and-storage.md`.
- LLD ID, such as `LLD-0001`; find matching files under `docs/design/**/lld/`.

If the input does not resolve to exactly one LLD, list candidates and ask the user to choose.

Do not accept `latest` by default. If the user provides `latest`, explain that `dfi:lld` requires an explicit LLD path or unique LLD ID.

## Parent Context

Use the selected LLD as the implementation source of truth.

If the LLD frontmatter or body references parent MLD, HLD, or BRD paths, read those files only when needed to clarify inherited requirements, constraints, success criteria, business rules, or scope boundaries.

Do not modify BRD, HLD, MLD, or LLD source documents.

## Authorization Model

Invoking `dfi:lld` authorizes this workflow to generate or update the implementation plan, generate one TCD, execute the implementation plan, edit code, run verification, and write the test report when all generated artifacts stay within the accepted LLD scope.

Before code edits, stop and ask for explicit approval if:

- The generated implementation plan or TCD materially deviates from the selected LLD.
- The workflow would overwrite an existing implementation plan that belongs to a different LLD or unrelated effort.
- The generated plan expands implementation scope beyond the selected LLD.
- Any assumption in the generated plan or TCD affects implementation behavior, delivery scope, API semantics, data behavior, permissions, errors, rollout, or verification strategy.

## Workflow

1. Parse the input after `dfi:lld`.
2. Resolve exactly one LLD.
3. Read the LLD.
4. Read parent MLD, HLD, and BRD only when needed.
5. Read the required rule-source skills listed above.
6. Confirm the current worktree state before editing.
7. Apply the Readiness Gate below.
8. Collect blocking implementation questions.
9. If blockers exist, run the Centralized Brainstorming Loop below.
10. Generate or update `docs/devflow/implementation-plan.md`.
11. Generate one TCD under the BRD design tree.
12. Apply the Authorization Model before code edits.
13. Execute the implementation plan one step at a time.
14. Run planned verification commands.
15. Write `docs/devflow/test-report.md`.
16. Stop at the code review gate and recommend running `review-changes`.

## Readiness Gate

Before writing code, verify the LLD:

- Has status indicating accepted or approved when frontmatter is present.
- Is PR-sized.
- Has a clear implementation scope.
- Identifies codebase landing areas or gives enough detail to infer them from the repository.
- Defines relevant API, storage, state, algorithm, integration, worker, UI/query, error, security, observability, and test concerns for its scope.
- Has parent traceability to an MLD and BRD context, directly or through readable metadata.
- Has no unresolved open question that would change implementation behavior or delivery scope.

If frontmatter status is draft, missing, or unclear, require explicit user confirmation that the LLD is accepted before implementation.

If the LLD is too broad, too vague, or missing implementation-critical decisions, stop for brainstorming before editing code.

## Centralized Brainstorming Loop

Use this loop only for blocking implementation questions.

1. Group blockers by impact:
   - LLD scope and PR-sized boundary.
   - Codebase landing area.
   - API, data, state, permission, and error semantics.
   - Test and verification strategy.
   - Rollout, migration, dependency, and delivery order.
2. Ask one question at a time.
3. Prefer concrete options with tradeoffs and a recommendation.
4. After each answer, update the planned implementation scope.
5. Continue until implementation can proceed without hiding critical decisions in code.

Record non-blocking unknowns as assumptions in the implementation plan and test report.

## Implementation Plan Rules

Generate or update `docs/devflow/implementation-plan.md`.

The plan must:

- Name the source LLD path and ID.
- Summarize the exact PR-sized scope.
- List ordered implementation tasks.
- Identify files or code areas likely to change.
- Include a verification command or check for each meaningful task.
- Record assumptions and non-blocking open questions.
- Keep unrelated refactors out of scope.

If an implementation plan already exists, update it only when it belongs to the selected LLD. Otherwise, ask before overwriting it.

## TCD Rules

Generate one TCD under the selected BRD design tree:

```text
docs/design/<BRD>/tcd/TCD-0001-*.md
```

Compute the next TCD ID by scanning existing files matching:

```text
docs/design/<BRD>/tcd/TCD-[0-9][0-9][0-9][0-9]-*.md
```

Use the next numeric ID after the highest existing match. Use an ASCII lower-kebab-case slug after the ID. Refuse to overwrite an existing TCD file.

The TCD must:

- Include parent metadata with the selected LLD ID, path, and title.
- Preserve BRD traceability in metadata and body content.
- Map LLD behavior to concrete test cases.
- Include unit, integration, contract, migration, and manual checks only when relevant.
- Name verification commands when they can be inferred.
- Mark skipped or unavailable checks explicitly.

The TCD is a test-design artifact. Test execution results belong in `docs/devflow/test-report.md`.

## Code Execution Rules

When changing code:

- Preserve user changes and unrelated WIP.
- Follow the selected LLD and implementation plan.
- Keep code changes scoped to the selected LLD.
- Update the implementation plan if repository reality differs from the plan.
- Run planned verification before claiming completion.

## Test Report Rules

Write `docs/devflow/test-report.md` after running verification.

The report must include:

- Source LLD path.
- Commands run.
- Pass/fail/skipped status.
- Relevant output summaries.
- Failure root-cause notes or next actions.
- Remaining assumptions or risks.

## Report

Report:

- Source LLD path.
- Implementation plan path.
- TCD path.
- Code areas changed.
- Verification commands and results.
- Test report path.
- Remaining assumptions, open questions, or risks.

## Hard Stops

Do not:

- Implement multiple LLDs in one run.
- Accept `latest` as an LLD selector.
- Modify BRD, HLD, MLD, or LLD source documents.
- Generate code review artifacts.
- Commit or push changes.
- Open a PR.
- Fix unrelated repository issues.
