# Implement LLD Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `dfi:lld` workflow that turns one accepted LLD into implementation artifacts, scoped code changes, and a test report.

**Architecture:** Implement this as an orchestration skill that bridges one LLD into the existing plan, implementation, and testing workflows. Add a slash command shim and update validation/install coverage so the plugin exposes the new command consistently.

**Tech Stack:** Markdown-based Codex skills and commands, Bash installer and validation scripts, shell-based tests.

---

## File Structure

- Create `skills/implement-lld/SKILL.md`: Defines LLD resolution, readiness gates, brainstorming blockers, implementation-plan/TCD/test-report generation, code execution rules, and hard stops.
- Create `commands/implementation-lld.md`: Slash-command shim that loads the skill and passes `$ARGUMENTS` as the LLD selector.
- Modify `scripts/validate-plugin.sh`: Require the new skill and command in the plugin scaffold.
- Modify `install.sh`: Copy and report the new local Codex slash command shim.
- Modify `tests/test-install.sh`: Assert that the installed command shim exists and matches the source file.

## Task 1: Add Implement LLD Skill

**Files:**
- Create: `skills/implement-lld/SKILL.md`

- [ ] **Step 1: Create the skill directory**

Run:

```bash
mkdir -p skills/implement-lld
```

Expected: directory exists at `skills/implement-lld`.

- [ ] **Step 2: Add the skill content**

Create `skills/implement-lld/SKILL.md` with:

```markdown
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
12. Execute the implementation plan one step at a time.
13. Run planned verification commands.
14. Write `docs/devflow/test-report.md`.
15. Stop at the code review gate and recommend running `review-changes`.

## Readiness Gate

Before writing code, verify the LLD:

- Is PR-sized.
- Has a clear implementation scope.
- Identifies codebase landing areas or gives enough detail to infer them from the repository.
- Defines relevant API, storage, state, algorithm, integration, worker, UI/query, error, security, observability, and test concerns for its scope.
- Has parent traceability to an MLD and BRD context, directly or through readable metadata.
- Has no unresolved open question that would change implementation behavior or delivery scope.

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

The TCD must:

- Reference the selected LLD as its parent.
- Preserve BRD traceability.
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
```

- [ ] **Step 3: Verify the skill file exists**

Run:

```bash
test -f skills/implement-lld/SKILL.md
```

Expected: command exits with status 0.

## Task 2: Add Slash Command Shim

**Files:**
- Create: `commands/implementation-lld.md`

- [ ] **Step 1: Add the command file**

Create `commands/implementation-lld.md` with:

```markdown
---
description: Implement one accepted LLD with plan, TCD, code changes, and test report
argument-hint: [LLD path or LLD id]
allowed-tools: [Read, Bash, Write, Edit]
---

# /dfi:lld

Implement exactly one accepted LLD and stop at the code review gate.

## Arguments

The user invoked this command with: `$ARGUMENTS`

`$ARGUMENTS` may be:

- An LLD file path.
- A unique LLD ID such as `LLD-0001`.

`latest` is intentionally not accepted for implementation.

## Workflow

1. Read `skills/implement-lld/SKILL.md`.
2. Treat `$ARGUMENTS` as the LLD selector.
3. Resolve exactly one LLD.
4. Read and apply:
   - `skills/write-plan/SKILL.md`
   - `skills/implement-from-plan/SKILL.md`
   - `skills/test-changes/SKILL.md`
5. Check LLD implementation readiness.
6. Use centralized brainstorming to resolve every blocking implementation question.
7. Generate or update `docs/devflow/implementation-plan.md`.
8. Generate one TCD under the BRD design tree.
9. Make code changes according to the LLD and implementation plan.
10. Run planned verification commands.
11. Write `docs/devflow/test-report.md`.
12. Stop at the code review gate. Do not generate code review artifacts, commit, push, or open a PR.

## Summary

Report the source LLD path, implementation plan path, TCD path, changed code areas, verification results, test report path, and remaining risks.
```

- [ ] **Step 2: Verify the command file exists**

Run:

```bash
test -f commands/implementation-lld.md
```

Expected: command exits with status 0.

## Task 3: Update Plugin Scaffold Validation

**Files:**
- Modify: `scripts/validate-plugin.sh`

- [ ] **Step 1: Add required paths**

In `scripts/validate-plugin.sh`, add these entries to `required_paths`:

```bash
  "commands/implementation-lld.md"
  "skills/implement-lld/SKILL.md"
```

Place `commands/implementation-lld.md` with the command files and `skills/implement-lld/SKILL.md` with the implementation workflow skills.

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

Find the existing command copies:

```bash
cp "$ROOT/commands/brd.md" "$CODEX_COMMANDS_DIR/dfd:brd.md"
cp "$ROOT/commands/design-tree.md" "$CODEX_COMMANDS_DIR/dfd:design-tree.md"
```

Add:

```bash
cp "$ROOT/commands/implementation-lld.md" "$CODEX_COMMANDS_DIR/dfi:lld.md"
```

- [ ] **Step 2: Print the installed command path**

Find the existing command echoes:

```bash
echo "Codex command: $CODEX_COMMANDS_DIR/dfd:brd.md"
echo "Codex command: $CODEX_COMMANDS_DIR/dfd:design-tree.md"
```

Add:

```bash
echo "Codex command: $CODEX_COMMANDS_DIR/dfi:lld.md"
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

Near the existing command variables:

```bash
codex_command="$TMPDIR/home/.codex/commands/dfd:brd.md"
codex_design_tree_command="$TMPDIR/home/.codex/commands/dfd:design-tree.md"
```

Add:

```bash
codex_implement_lld_command="$TMPDIR/home/.codex/commands/dfi:lld.md"
```

- [ ] **Step 2: Assert the new command shim exists**

After the existing command-shim checks, add:

```bash
if [[ ! -f "$codex_implement_lld_command" ]]; then
  echo "local Codex implement-lld slash command shim missing: $codex_implement_lld_command" >&2
  exit 1
fi
```

- [ ] **Step 3: Assert the new command shim matches source**

After the existing command `cmp` checks, add:

```bash
if ! cmp -s "$ROOT/commands/implementation-lld.md" "$codex_implement_lld_command"; then
  echo "local Codex implement-lld slash command shim differs from source command" >&2
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
git diff -- skills/implement-lld/SKILL.md commands/implementation-lld.md scripts/validate-plugin.sh install.sh tests/test-install.sh
```

Expected: diff contains only the new implement-lld skill, new command shim, validation requirement, installer copy/output line, and install-test assertions for `dfi:lld.md`, plus any pre-existing WIP outside this scoped feature.

## Self-Review Notes

- Spec coverage: The plan covers the new skill, command shim, validation registration, installer behavior, install-test assertions, and verification.
- Placeholder scan: The only angle-bracket placeholders are literal command/path examples in skill and command docs.
- Scope check: Runtime implementation of a sample LLD is out of scope for this plugin repository change; the skill defines the agentic workflow.
