# Gen Design Tree Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `dfd:design-tree` workflow that generates HLD, MLD, and LLD drafts from one accepted BRD in a single gated flow.

**Architecture:** Implement this as an orchestration skill that reuses existing `gen-hld`, `gen-mld`, and `gen-lld` rules instead of duplicating them. Add a slash command shim and validation/install coverage so the plugin scaffold and local Codex command install stay consistent.

**Tech Stack:** Markdown-based Codex skills and commands, Bash installer and validation scripts, shell-based tests.

---

## File Structure

- Create `skills/gen-design-tree/SKILL.md`: Defines the new orchestration workflow, centralized blocker collection, brainstorming loop, split policy, generation rules, validation, and hard stops.
- Create `commands/design-tree.md`: Slash-command shim that loads the skill and passes `$ARGUMENTS` as the BRD selector.
- Modify `scripts/validate-plugin.sh`: Require the new skill and command in the plugin scaffold.
- Modify `install.sh`: Copy the new slash command into `~/.codex/commands/dfd:design-tree.md`.
- Modify `tests/test-install.sh`: Assert that the installed command shim exists and matches the source file.

## Task 1: Add Gen Design Tree Skill

**Files:**
- Create: `skills/gen-design-tree/SKILL.md`

- [ ] **Step 1: Create the skill directory**

Run:

```bash
mkdir -p skills/gen-design-tree
```

Expected: directory exists at `skills/gen-design-tree`.

- [ ] **Step 2: Add the skill content**

Create `skills/gen-design-tree/SKILL.md` with:

```markdown
---
name: gen-design-tree
description: Use when the user types `dfd:design-tree <BRD path or BRD id>` to generate HLD, MLD, and LLD drafts from one accepted BRD in a single centralized-brainstorming workflow without proceeding to TCD, code, commits, or PRs.
---

# Generate Design Tree

`dfd:design-tree` means Devflow Design: generate the design tree from an accepted BRD through LLD.

Use this skill when the user types:

```text
dfd:design-tree <BRD path>
dfd:design-tree <BRD id>
dfd:design-tree latest
dfd:design-tree 最新 BRD
```

## Goal

Read one accepted BRD and generate the draft design tree under:

```text
docs/design/<BRD file basename>/hld/
docs/design/<BRD file basename>/mld/
docs/design/<BRD file basename>/lld/
```

The workflow stops at the LLD review gate.

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
9. Generate HLD, MLD, and LLD draft files in one pass.
10. Run the available design validation command.
11. Report generated files, split decisions, validation result, and remaining non-blocking open questions.

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
- Commit or push generated files unless the user explicitly asks.
- Open a PR.
- Overwrite existing design files.
```

- [ ] **Step 3: Verify the skill file exists**

Run:

```bash
test -f skills/gen-design-tree/SKILL.md
```

Expected: command exits with status 0.

## Task 2: Add Slash Command Shim

**Files:**
- Create: `commands/design-tree.md`

- [ ] **Step 1: Add the command file**

Create `commands/design-tree.md` with:

```markdown
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
```

- [ ] **Step 2: Verify the command file exists**

Run:

```bash
test -f commands/design-tree.md
```

Expected: command exits with status 0.

## Task 3: Update Plugin Scaffold Validation

**Files:**
- Modify: `scripts/validate-plugin.sh`

- [ ] **Step 1: Add required paths**

In `scripts/validate-plugin.sh`, add these entries to `required_paths`:

```bash
  "commands/design-tree.md"
  "skills/gen-design-tree/SKILL.md"
```

Place `commands/design-tree.md` next to `commands/brd.md`, and place `skills/gen-design-tree/SKILL.md` next to the other design-generation skills.

- [ ] **Step 2: Run scaffold validation**

Run:

```bash
bash scripts/validate-plugin.sh
```

Expected output includes:

```text
plugin scaffold ok
```

## Task 4: Update Installer Command Copy

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Copy the new local Codex slash command shim**

Find the existing command copy:

```bash
cp "$ROOT/commands/brd.md" "$CODEX_COMMANDS_DIR/dfd:brd.md"
```

Add this line immediately after it:

```bash
cp "$ROOT/commands/design-tree.md" "$CODEX_COMMANDS_DIR/dfd:design-tree.md"
```

- [ ] **Step 2: Print the installed command path**

Find:

```bash
echo "Codex command: $CODEX_COMMANDS_DIR/dfd:brd.md"
```

Add:

```bash
echo "Codex command: $CODEX_COMMANDS_DIR/dfd:design-tree.md"
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

Near the existing command variable:

```bash
codex_command="$TMPDIR/home/.codex/commands/dfd:brd.md"
```

Add:

```bash
codex_design_tree_command="$TMPDIR/home/.codex/commands/dfd:design-tree.md"
```

- [ ] **Step 2: Assert the new command shim exists**

After the existing check for `codex_command`, add:

```bash
if [[ ! -f "$codex_design_tree_command" ]]; then
  echo "local Codex design-tree slash command shim missing: $codex_design_tree_command" >&2
  exit 1
fi
```

- [ ] **Step 3: Assert the new command shim matches source**

After the existing `cmp` check for `commands/brd.md`, add:

```bash
if ! cmp -s "$ROOT/commands/design-tree.md" "$codex_design_tree_command"; then
  echo "local Codex design-tree slash command shim differs from source command" >&2
  exit 1
fi
```

- [ ] **Step 4: Run install test**

Run:

```bash
bash tests/test-install.sh
```

Expected: command exits with status 0. The installer may print macOS cache warnings in this environment; those are acceptable if the final exit status is 0.

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
git diff -- skills/gen-design-tree/SKILL.md commands/design-tree.md scripts/validate-plugin.sh install.sh tests/test-install.sh
```

Expected: diff contains only the new design-tree skill, new command shim, validation requirement, installer copy/output line, and install-test assertions.

## Self-Review Notes

- Spec coverage: The plan covers the new orchestration skill, slash command, validation, installer behavior, and tests.
- Placeholder scan: The only angle-bracket placeholders are literal command/path examples in skill and command docs.
- Scope check: Automated semantic validation of generated HLD/MLD/LLD content remains out of scope, matching the approved design.
