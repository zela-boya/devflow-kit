# Implement LLD Folder Skill Design

## Goal

Create a Devflow Kit skill that serially implements every accepted LLD in one `lld/` folder while preserving the single-LLD implementation safety gates.

The workflow is:

```text
LLD folder -> ordered LLD list -> batch implementation plan -> per-LLD TCDs -> code changes -> batch test report
```

## Trigger

The new skill is named `implement-lld-folder` and is used when the user invokes:

```text
dfi:lld-folder <LLD folder path>
```

The input must resolve to one readable directory that contains LLD markdown files named:

```text
LLD-[0-9][0-9][0-9][0-9]-*.md
```

## Output

The skill produces:

- `docs/devflow/implementation-plan.md`, as a batch-level plan grouped by LLD
- One TCD per LLD under the current BRD design tree
- Code changes from each successfully implemented LLD
- `docs/devflow/test-report.md`, as a batch-level report grouped by LLD

The workflow stops at the code review gate.

It must not generate code review artifacts, commit, push, or open a PR.

## Architecture

`implement-lld-folder` is a serial orchestration skill. It should not duplicate detailed LLD implementation rules. Instead, it reads and applies:

- `skills/implement-lld/SKILL.md`
- `skills/write-plan/SKILL.md`
- `skills/implement-from-plan/SKILL.md`
- `skills/test-changes/SKILL.md`

The new skill owns the folder-level behavior:

- Folder resolution.
- LLD file discovery and ordering.
- Batch-level readiness and sequencing.
- Serial execution.
- Fail-fast handling.
- Batch-level artifact aggregation.

## Ordering

Sort LLD files by filename in ascending order. This means:

```text
LLD-0001-*.md
LLD-0002-*.md
LLD-0003-*.md
```

are executed in that order.

Do not infer dependency order from document prose in this version. If the filename order appears to conflict with explicit LLD dependency or delivery-order text, stop and ask before implementation.

## Workflow

1. Parse the argument after `dfi:lld-folder`.
2. Resolve exactly one readable LLD folder.
3. Discover files matching `LLD-[0-9][0-9][0-9][0-9]-*.md`.
4. Sort the LLD files by filename ascending.
5. Read `skills/implement-lld/SKILL.md` and required downstream rule-source skills.
6. Confirm the current worktree state before editing.
7. Preflight each LLD using the `implement-lld` readiness gate.
8. Collect blocking folder-level questions.
9. If blockers exist, use centralized brainstorming before any code edits.
10. Generate or update a batch-level `docs/devflow/implementation-plan.md`, grouped by LLD in execution order.
11. Execute LLDs serially in filename order.
12. For each LLD:
    - Apply the single-LLD readiness and authorization model.
    - Generate one TCD.
    - Execute the LLD-scoped implementation plan section.
    - Run the planned verification commands for that LLD.
    - Record results in the batch test report state.
13. If any LLD fails or blocks, stop immediately.
14. Write `docs/devflow/test-report.md`, grouped by LLD.
15. Stop at the code review gate and recommend running `review-changes`.

## Fail-Fast Policy

If an LLD fails readiness, hits a blocker, fails verification, or cannot be implemented without expanding scope:

- Stop immediately.
- Do not start later LLDs.
- Preserve completed LLD results in the implementation plan and test report.
- Report:
  - Completed LLDs.
  - Failed or blocked LLD.
  - Failure reason.
  - Remaining unexecuted LLDs.
  - Next recommended action.

Do not skip failed LLDs and continue.

## Folder Readiness Gate

Before code edits, verify:

- The folder contains at least one matching LLD file.
- All selected LLDs belong to the same BRD design tree.
- Each LLD has accepted or approved status, or the user explicitly confirms it is accepted.
- Each LLD is PR-sized according to `implement-lld`.
- Filename order is not contradicted by explicit dependency or delivery-order text.
- No LLD has a blocking open question that affects implementation behavior or delivery scope.

If any of these checks fail, stop for brainstorming before editing code.

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

Generate one TCD per LLD using the TCD rules from `implement-lld`:

- Compute the next TCD ID in the BRD design tree.
- Use ASCII lower-kebab-case slugs.
- Include parent metadata for the selected LLD.
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

## Slash Command

Add a command shim:

```text
commands/implementation-lld-folder.md
```

The command should read `skills/implement-lld-folder/SKILL.md`, pass `$ARGUMENTS` as the folder selector, execute the serial LLD-folder implementation workflow, and stop at the code review gate.

The installer should copy this command to:

```text
~/.codex/commands/dfi:lld-folder.md
```

## Validation

Implementation should update plugin validation and install coverage for:

- `skills/implement-lld-folder/SKILL.md`
- `commands/implementation-lld-folder.md`
- The installed `dfi:lld-folder.md` command shim.

## Acceptance Criteria

- Users can invoke `dfi:lld-folder <LLD folder path>`.
- The workflow discovers matching LLD files and runs them by filename order.
- The workflow uses `implement-lld` rules for each LLD.
- The workflow fail-fast stops on the first failed or blocked LLD.
- The workflow writes batch-level implementation plan and test report artifacts grouped by LLD.
- The workflow generates one TCD per LLD.
- The workflow stops at the code review gate.
- The plugin validator and installer tests account for the new skill and command.

## Out Of Scope

- Parallel LLD implementation.
- Dependency-based sorting.
- Skipping failed LLDs.
- Implementing LLDs from multiple folders or multiple BRD design trees.
- Committing, pushing, opening PRs, or generating code review artifacts.
