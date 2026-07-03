# Implement LLD Skill Design

## Goal

Create a Devflow Kit skill that converts one accepted LLD into code while preserving the artifact-driven workflow:

```text
LLD -> implementation plan -> TCD -> code changes -> test report
```

The skill should make LLD-to-code execution faster without bypassing implementation planning, test design, or verification evidence.

## Trigger

The new skill is named `implement-lld` and is used when the user invokes:

```text
dfi:lld <LLD path>
dfi:lld <LLD id>
```

The skill implements exactly one LLD per run. It does not accept multiple LLDs by default and does not support `latest` selection, because implementing the wrong LLD is higher risk than generating a draft document.

## Output

The skill produces:

- `docs/devflow/implementation-plan.md`
- One TCD under the current BRD design tree, such as `docs/design/<BRD>/tcd/TCD-0001-*.md`
- Code changes scoped to the selected LLD
- `docs/devflow/test-report.md`

The workflow stops at the code review gate.

It must not generate code review artifacts, commit, push, or open a PR.

## Architecture

`implement-lld` is an orchestration skill. It should not duplicate all implementation and testing rules. Instead, it reads and applies:

- `skills/write-plan/SKILL.md`
- `skills/implement-from-plan/SKILL.md`
- `skills/test-changes/SKILL.md`

The new skill owns the LLD-specific bridge:

- LLD resolution.
- Parent context loading from MLD, HLD, and BRD when needed.
- LLD implementation readiness checks.
- Centralized brainstorming for blocking questions.
- Implementation-plan generation from LLD.
- TCD generation from LLD behavior and acceptance expectations.
- Execution through code changes and verification.
- Test-report generation.

## Workflow

1. Parse the argument after `dfi:lld`.
2. Resolve exactly one LLD from a readable path or LLD ID.
3. Read the selected LLD.
4. Read parent MLD, HLD, and BRD only when needed to clarify inherited requirements, boundaries, success criteria, or constraints.
5. Read the rule-source skills listed above.
6. Check whether the LLD is ready for implementation.
7. Collect blocking questions that would change code behavior, delivery scope, data model, API contract, state transitions, permissions, errors, test coverage, or rollout order.
8. If blockers exist, run the centralized brainstorming loop.
9. Generate or update `docs/devflow/implementation-plan.md`.
10. Generate one TCD under the current BRD design tree.
11. Execute the implementation plan one step at a time.
12. Run the planned verification commands.
13. Write `docs/devflow/test-report.md`.
14. Stop at the code review gate and recommend running the review workflow next.

## LLD Resolution

Accept these input forms:

- Readable LLD file path, such as `docs/design/BRD-0001-example/lld/LLD-0001-api-and-storage.md`.
- LLD ID, such as `LLD-0001`; find matching files under `docs/design/**/lld/`.

If the input does not resolve to exactly one LLD, list candidates and ask the user to choose.

Do not accept `latest` by default.

## Readiness Gate

Before writing code, verify the LLD:

- Is PR-sized.
- Has a clear implementation scope.
- Identifies codebase landing areas or gives enough detail to infer them from the repository.
- Defines the relevant API, storage, state, algorithm, integration, worker, UI/query, error, security, observability, and test concerns for its scope.
- Has parent traceability to an MLD and BRD context, directly or through readable metadata.
- Has no unresolved open question that would change implementation behavior or delivery scope.

If the LLD is too broad, too vague, or missing implementation-critical decisions, stop for brainstorming before editing code.

## Centralized Brainstorming Loop

Use brainstorming only for blocking implementation questions.

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

Non-blocking unknowns become assumptions in the implementation plan and test report.

## Implementation Plan Rules

The generated `docs/devflow/implementation-plan.md` must:

- Name the source LLD path and ID.
- Summarize the exact PR-sized scope.
- List ordered implementation tasks.
- Identify files or code areas likely to change.
- Include a verification command or check for each meaningful task.
- Record assumptions and non-blocking open questions.
- Keep unrelated refactors out of scope.

If an implementation plan already exists, update it only when it belongs to the selected LLD. Otherwise, ask before overwriting or create a clearly scoped replacement only after user confirmation.

## TCD Rules

Generate one TCD under the selected BRD design tree:

```text
docs/design/<BRD>/tcd/TCD-0001-*.md
```

The TCD must:

- Reference the selected LLD as its parent.
- Preserve BRD traceability.
- Map LLD behavior to concrete test cases.
- Include unit, integration, contract, migration, and manual checks only when relevant.
- Name verification commands when they can be inferred.
- Mark skipped or unavailable checks explicitly.

The TCD is a test-design artifact, not the test report. Test execution results belong in `docs/devflow/test-report.md`.

## Code Execution Rules

When changing code:

- Confirm worktree state before editing.
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

## Slash Command

Add a command shim:

```text
commands/implementation-lld.md
```

The command should read `skills/implement-lld/SKILL.md`, pass `$ARGUMENTS` as the LLD selector, execute the LLD-to-code workflow, and stop at the code review gate.

The installer should copy this command to:

```text
~/.codex/commands/dfi:lld.md
```

## Validation

Implementation should update plugin validation and install coverage for:

- `skills/implement-lld/SKILL.md`
- `commands/implementation-lld.md`
- The installed `dfi:lld.md` command shim.

The skill itself should run project-specific verification commands from the generated implementation plan. The plugin repository tests should verify that the skill and command are present and installable.

## Acceptance Criteria

- Users can invoke `dfi:lld <LLD path or ID>` to implement exactly one accepted LLD.
- Blocking implementation questions are resolved through centralized brainstorming before code edits.
- The workflow generates or updates `docs/devflow/implementation-plan.md`.
- The workflow generates one TCD under the BRD design tree.
- Code changes are scoped to the selected LLD and implementation plan.
- Verification commands are run and summarized in `docs/devflow/test-report.md`.
- The workflow stops at the code review gate.
- The plugin validator and installer tests account for the new skill and command.

## Out Of Scope

- Implementing multiple LLDs in one run.
- Supporting `latest` LLD selection.
- Generating or modifying BRD, HLD, MLD, or LLD documents.
- Opening PRs, committing, or pushing.
- Automatically producing `docs/devflow/code-review.md`.
- Automatically fixing unrelated repository issues.
