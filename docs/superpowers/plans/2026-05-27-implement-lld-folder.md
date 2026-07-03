# Implement LLD Folder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `dfi:lld-folder` workflow that serially implements every accepted LLD in one folder with fail-fast behavior.

**Architecture:** Implement this as a folder-level orchestration skill that delegates single-LLD behavior to `implement-lld`, then add a slash command shim and plugin install/validation coverage.

**Tech Stack:** Markdown-based Codex skills and commands, Bash installer and validation scripts, shell-based tests.

---

## File Structure

- Create `skills/implement-lld-folder/SKILL.md`: Defines folder resolution, LLD discovery/order, fail-fast behavior, batch artifacts, and hard stops.
- Create `commands/implementation-lld-folder.md`: Slash-command shim that loads the skill and passes `$ARGUMENTS` as the LLD folder selector.
- Modify `scripts/validate-plugin.sh`: Require the new skill and command in the plugin scaffold.
- Modify `install.sh`: Copy and report the new local Codex slash command shim.
- Modify `tests/test-install.sh`: Assert that the installed command shim exists and matches the source file.

## Task 1: Add Implement LLD Folder Skill

**Files:**
- Create: `skills/implement-lld-folder/SKILL.md`

- [ ] **Step 1: Create the skill directory**

Run:

```bash
mkdir -p skills/implement-lld-folder
```

Expected: directory exists at `skills/implement-lld-folder`.

- [ ] **Step 2: Add the skill content**

Create `skills/implement-lld-folder/SKILL.md` with:

```markdown
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
```

- [ ] **Step 3: Verify the skill file exists**

Run:

```bash
test -f skills/implement-lld-folder/SKILL.md
```

Expected: command exits with status 0.

## Task 2: Add Slash Command Shim

**Files:**
- Create: `commands/implementation-lld-folder.md`

- [ ] **Step 1: Add the command file**

Create `commands/implementation-lld-folder.md` with:

```markdown
---
description: Serially implement every accepted LLD in one folder
argument-hint: [LLD folder path]
allowed-tools: [Read, Bash, Write, Edit]
---

# /dfi:lld-folder

Serially implement every accepted LLD in one `lld/` folder and stop at the code review gate.

## Arguments

The user invoked this command with: `$ARGUMENTS`

`$ARGUMENTS` must be one readable LLD folder path containing files named:

```text
LLD-[0-9][0-9][0-9][0-9]-*.md
```

## Workflow

1. Read `skills/implement-lld-folder/SKILL.md`.
2. Treat `$ARGUMENTS` as the LLD folder selector.
3. Discover matching LLD files and sort them by filename.
4. Read and apply:
   - `skills/implement-lld/SKILL.md`
   - `skills/write-plan/SKILL.md`
   - `skills/implement-from-plan/SKILL.md`
   - `skills/test-changes/SKILL.md`
5. Preflight the folder and each LLD before code edits.
6. Use centralized brainstorming to resolve every blocking folder or LLD question.
7. Generate or update a batch-level `docs/devflow/implementation-plan.md`.
8. Serially implement each LLD in filename order.
9. Generate one TCD per LLD.
10. Run planned verification commands.
11. Write a batch-level `docs/devflow/test-report.md`.
12. Fail fast on the first blocked or failed LLD.
13. Stop at the code review gate. Do not generate code review artifacts, commit, push, or open a PR.

## Summary

Report the source folder, LLD execution order, completed LLDs, failed or blocked LLD if any, remaining LLDs, generated TCD paths, verification results, test report path, and remaining risks.
```

- [ ] **Step 2: Verify the command file exists**

Run:

```bash
test -f commands/implementation-lld-folder.md
```

Expected: command exits with status 0.

## Task 3: Update Plugin Scaffold Validation

**Files:**
- Modify: `scripts/validate-plugin.sh`

- [ ] **Step 1: Add required paths**

In `scripts/validate-plugin.sh`, add these entries to `required_paths`:

```bash
  "commands/implementation-lld-folder.md"
  "skills/implement-lld-folder/SKILL.md"
```

Place `commands/implementation-lld-folder.md` with command files and `skills/implement-lld-folder/SKILL.md` with implementation workflow skills.

- [ ] **Step 2: Run scaffold validation**

Run:

```bash
bash scripts/validate-plugin.sh
```

Expected output:

```text
plugin scaffold ok
```

## Task 4: Update Installer Command Copy

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Copy the new local Codex slash command shim**

Find existing command copies and add:

```bash
cp "$ROOT/commands/implementation-lld-folder.md" "$CODEX_COMMANDS_DIR/dfi:lld-folder.md"
```

- [ ] **Step 2: Print the installed command path**

Find existing command echoes and add:

```bash
echo "Codex command: $CODEX_COMMANDS_DIR/dfi:lld-folder.md"
```

- [ ] **Step 3: Run shell syntax check**

Run:

```bash
bash -n install.sh
```

Expected: command exits with status 0 and no output.

## Task 5: Update Install Test

**Files:**
- Modify: `tests/test-install.sh`

- [ ] **Step 1: Add expected command path variable**

Near existing command variables, add:

```bash
codex_implement_lld_folder_command="$TMPDIR/home/.codex/commands/dfi:lld-folder.md"
```

- [ ] **Step 2: Assert the new command shim exists**

After existing command-shim checks, add:

```bash
if [[ ! -f "$codex_implement_lld_folder_command" ]]; then
  echo "local Codex implement-lld-folder slash command shim missing: $codex_implement_lld_folder_command" >&2
  exit 1
fi
```

- [ ] **Step 3: Assert the new command shim matches source**

After existing command `cmp` checks, add:

```bash
if ! cmp -s "$ROOT/commands/implementation-lld-folder.md" "$codex_implement_lld_folder_command"; then
  echo "local Codex implement-lld-folder slash command shim differs from source command" >&2
  exit 1
fi
```

- [ ] **Step 4: Run install test**

Run:

```bash
bash tests/test-install.sh
```

Expected: command exits with status 0. macOS cache or FSEvents warnings are acceptable if the final exit status is 0.

## Task 6: Full Verification

**Files:**
- Verify only.

- [ ] **Step 1: Run plugin validation**

Run:

```bash
bash scripts/validate-plugin.sh
```

Expected:

```text
plugin scaffold ok
```

- [ ] **Step 2: Run BRD design workflow test**

Run:

```bash
bash tests/test-devflow-design.sh
```

Expected output includes:

```text
design docs ok
```

- [ ] **Step 3: Run install test**

Run:

```bash
bash tests/test-install.sh
```

Expected: command exits with status 0.

- [ ] **Step 4: Review final diff**

Run:

```bash
git diff -- skills/implement-lld-folder/SKILL.md commands/implementation-lld-folder.md scripts/validate-plugin.sh install.sh tests/test-install.sh
```

Expected: diff contains only the new implement-lld-folder skill, new command shim, validation requirement, installer copy/output line, and install-test assertions for `dfi:lld-folder.md`, plus any pre-existing WIP outside this scoped feature.

## Self-Review Notes

- Spec coverage: The plan covers the new folder-level skill, command shim, validation registration, installer behavior, install-test assertions, and verification.
- Placeholder scan: The only angle-bracket placeholders are literal command/path examples in skill and command docs.
- Scope check: Runtime implementation against a sample LLD folder is out of scope for this plugin repository change; the skill defines the agentic workflow.
