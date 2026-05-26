# Gen Design Tree Skill Design

## Goal

Create a Devflow Kit skill that generates a complete design document tree from one accepted BRD through LLD in a single workflow:

```text
BRD -> HLD -> MLD -> LLD
```

The skill should reduce the time cost of invoking `dfd:gen-hld`, `dfd:gen-mld`, and `dfd:gen-lld` separately while preserving the same document gates and design quality.

## Trigger

The new skill is named `gen-design-tree` and is used when the user invokes:

```text
dfd:gen-design-tree <BRD path>
dfd:gen-design-tree <BRD id>
dfd:gen-design-tree latest
dfd:gen-design-tree 最新 BRD
```

The input is always an existing accepted BRD. The skill does not accept raw business text and does not generate a BRD.

## Output

The skill generates draft design documents under the selected BRD design tree:

```text
docs/design/<BRD file basename>/hld/
docs/design/<BRD file basename>/mld/
docs/design/<BRD file basename>/lld/
```

The workflow stops at the LLD review gate.

It must not generate TCDs, change implementation code, commit, push, or open a PR.

## Architecture

`gen-design-tree` is an orchestration skill. It should not duplicate the detailed rules from the existing layered skills. Instead, it reads and applies these skills as the source of truth:

- `skills/gen-hld/SKILL.md`
- `skills/gen-mld/SKILL.md`
- `skills/gen-lld/SKILL.md`

The new skill owns only the cross-layer workflow:

- BRD resolution.
- Preflight design-tree inference.
- Cross-layer blocker collection.
- Centralized brainstorming for blocking questions.
- One-pass HLD, MLD, and LLD generation.
- Final validation and reporting.

This keeps the single-layer and tree-generation behaviors aligned when HLD, MLD, or LLD rules change later.

## Workflow

1. Parse the argument after `dfd:gen-design-tree`.
2. Resolve exactly one BRD from a readable path, BRD ID, `latest`, or `最新 BRD`.
3. Read the BRD and load the HLD, MLD, and LLD skill rules.
4. Apply the BRD scope gate from `gen-hld`.
5. Infer the intended HLD, MLD, and LLD splits without writing files.
6. Collect every blocking question that would change design-tree shape or implementation scope.
7. If blockers exist, run a centralized brainstorming loop:
   - Ask one question at a time.
   - Prefer concrete options with tradeoffs.
   - Continue until the full tree can be generated.
8. Write HLD, MLD, and LLD draft files in one pass.
9. Run:

```bash
scripts/devflow design validate --target <target-repo>
```

10. Report source BRD, generated files, split decisions, validation result, and remaining non-blocking open questions.

## Blocking Question Policy

The skill should ask before writing files when an unresolved question can change:

- Whether the BRD is too broad for a useful HLD.
- HLD boundaries or whether multiple HLDs are justified.
- MLD module-contract boundaries.
- LLD PR-sized scope boundaries.
- API behavior, data ownership, state transitions, permissions, errors, rollout order, or delivery dependencies.

Non-blocking unknowns should be recorded in the generated documents' open-question sections.

## Split Strategy

Default behavior is automatic splitting with conservative gates:

- One valid BRD usually produces one HLD.
- Multiple HLDs are rare and require clear independent high-level design surfaces.
- Multiple MLDs are generated directly only when the HLD provides clear module-contract split value.
- Multiple LLDs are generated directly only when the MLD provides clear PR-sized implementation split value.
- Ambiguous, too-broad, or too-granular splits become centralized brainstorming blockers.

The skill must not generate a broad project-overview HLD, catch-all MLD, or catch-all LLD as a fallback.

## File Rules

The new skill follows existing document rules:

- File and directory slugs are ASCII-only lower-kebab-case.
- Chinese is allowed in titles and document bodies, not paths.
- HLD, MLD, and LLD numbering increments inside the current BRD design folder and document-type directory.
- Existing files are not overwritten.
- Child documents include parent metadata with ID, relative path, and title.
- Generated documents preserve BRD/HLD/MLD traceability.

## Slash Command

Add a command shim:

```text
commands/gen-design-tree.md
```

The command should instruct Codex to read `skills/gen-design-tree/SKILL.md`, pass `$ARGUMENTS` as the BRD selector, generate the design tree, validate with the available design validator, and stop at the LLD review gate.

The installer should copy this command to:

```text
~/.codex/commands/dfd:gen-design-tree.md
```

## Validation

Implementation should update existing validation coverage so the plugin scaffold requires:

- `skills/gen-design-tree/SKILL.md`
- `commands/gen-design-tree.md`

Installation tests should verify that the new command shim is installed.

The current `scripts/devflow design validate` mostly validates BRD structure. The new skill should still run it and explicitly report that HLD/MLD/LLD validation remains document-gate based until automated validation is added.

## Acceptance Criteria

- Users can invoke `dfd:gen-design-tree <BRD selector>` to generate HLD, MLD, and LLD drafts from one accepted BRD.
- The workflow uses centralized brainstorming to resolve all blocking cross-layer questions before writing files.
- The skill reuses existing HLD, MLD, and LLD rules rather than maintaining duplicated copies.
- The workflow stops at the LLD review gate.
- The plugin validator and installer tests account for the new skill and command.

## Out Of Scope

- Generating BRDs from raw business input.
- Generating TCDs.
- Writing implementation code.
- Automated semantic validation of HLD, MLD, or LLD content.
- Committing, pushing, or opening PRs from the design-tree skill.
