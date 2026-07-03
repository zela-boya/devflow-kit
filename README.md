# devflow-kit

Devflow Kit is a Codex plugin for document-driven agentic development.

Its core rule is simple:

```text
The artifact is the source of truth.
The conversation is temporary.
The code is derived.
```

This project treats BRD, HLD, MLD, LLD, TCD, test reports, code reviews, and PR descriptions as durable workflow artifacts. Codex may use conversation to clarify intent, but each delivery phase must be driven by reviewed documents rather than transient chat context.

## Workflow

```text
raw request
  -> BRD
  -> HLD
  -> MLD
  -> LLD
  -> TCD
  -> code changes
  -> test report
  -> code review
  -> commit and PR
```

Each stage has a defined input, output, and stop condition. A later stage should not proceed until the previous artifact is complete enough to act as a contract.

## Commands

Devflow Kit exposes two command namespaces. The namespace is part of the
workflow contract, not just a short prefix.

- `dfd` means Devflow Design. Commands in this namespace create or update
  durable design artifacts only. They must not generate TCDs, edit product
  code, run implementation plans, commit, push, or open PRs.
- `dfi` means Devflow Implementation. Commands in this namespace consume
  accepted low-level design artifacts and may generate implementation plans,
  TCDs, code changes, and test reports. They still stop before code-review
  artifacts, commits, pushes, or PRs unless another reviewed workflow
  explicitly continues from there.

The command suffix names the artifact or artifact collection being operated on.
For example, `dfd:lld` means "generate LLD design from an accepted MLD", while
`dfi:lld` means "implement one accepted LLD". The namespace disambiguates
design from implementation.

### Design Commands

Design commands use the `dfd` namespace:

```text
dfd:brd <business text or source document path>
dfd:hld <BRD path | BRD id | latest | 最新 BRD>
dfd:mld <HLD path | HLD id | latest | 最新 HLD>
dfd:lld <MLD path | MLD id | latest | 最新 MLD>
dfd:design-tree <BRD path | BRD id | latest | 最新 BRD>
```

#### `dfd:brd`

Use `dfd:brd` to turn raw business input into one or more BRD draft files under
`docs/brd/`.

Accepted input:

- A short business request, such as "Add withdrawal address whitelist
  management".
- A longer business description pasted into the prompt.
- A local source-document path containing business requirements.

What it does:

1. Reads `skills/dfd-gen-brd/SKILL.md`.
2. Classifies the input as a small request, a single business closure, or a
   project-level source document containing multiple business closures.
3. Generates one BRD directly when the input is one coherent business closure.
4. Proposes a BRD split when the input is project-level, then waits for the user
   to confirm or adjust the split before writing files.
5. Preserves concrete technical facts from the source as BRD technical context
   and child requirements.
6. Validates generated artifacts with the Devflow design validator.

Output:

- One or more files like `docs/brd/BRD-0001-some-capability.md`.
- No HLD, MLD, LLD, TCD, code, commits, or PRs.

Stop condition:

- Stops at the BRD review gate. The user should review and accept the BRD before
  generating HLDs.

Example:

```text
dfd:brd Add user withdrawal address whitelist management for Admin and API users.
```

#### `dfd:hld`

Use `dfd:hld` to generate one or more HLD draft files from one accepted BRD.

Accepted input:

- A BRD file path, such as `docs/brd/BRD-0001-withdrawal-risk-control.md`.
- A BRD ID, such as `BRD-0001`.
- `latest`, `latest BRD`, or `最新 BRD`.

What it does:

1. Reads `skills/gen-hld/SKILL.md`.
2. Resolves exactly one BRD.
3. Applies the BRD scope gate. It generates HLDs only for a small request,
   single capability, or single business closure.
4. Stops if the BRD is project-level and reports a proposed BRD split instead
   of creating a vague overview HLD.
5. Expands BRD goals, constraints, risks, and technical context into high-level
   design direction.

Output:

- Files under `docs/design/<BRD file basename>/hld/`.

Stop condition:

- Stops at the HLD review gate. It does not generate MLDs, LLDs, TCDs, code,
  commits, or PRs.

Example:

```text
dfd:hld BRD-0001
```

#### `dfd:mld`

Use `dfd:mld` to generate one or more MLD draft files from one accepted HLD.

Accepted input:

- An HLD file path.
- An HLD ID, such as `HLD-0001`.
- `latest`, `latest HLD`, or `最新 HLD`.

What it does:

1. Reads `skills/gen-mld/SKILL.md`.
2. Resolves exactly one HLD.
3. Applies the HLD gate. It generates MLDs only when the HLD has a clear
   BRD-scoped responsibility boundary.
4. Converts high-level responsibilities into module-contract design.
5. Uses explicit HLD split recommendations when they are clear and have
   independent module-contract value.
6. Asks for clarification when the split is unclear, too broad, or too granular.

Output:

- Files under `docs/design/<BRD file basename>/mld/`.

Stop condition:

- Stops at the MLD review gate. It does not generate LLDs, TCDs, code, commits,
  or PRs.

Example:

```text
dfd:mld HLD-0001
```

#### `dfd:lld`

Use `dfd:lld` to generate one or more LLD draft files from one accepted MLD.

Accepted input:

- An MLD file path.
- An MLD ID, such as `MLD-0001`.
- `latest`, `latest MLD`, or `最新 MLD`.

What it does:

1. Reads `skills/gen-lld/SKILL.md`.
2. Resolves exactly one MLD.
3. Applies the MLD gate. It generates LLDs only when the MLD has concrete
   module boundaries, owned data or state, interaction contracts, errors,
   tests, observability, and enough detail to derive PR-sized implementation
   scopes.
4. Converts module contracts into concrete codebase-aware implementation design.
5. Uses explicit MLD LLD-split recommendations when each split is PR-sized.
6. Asks for clarification when the split is unclear, too broad, too small, or
   not implementation-sized.

Output:

- Files under `docs/design/<BRD file basename>/lld/`.

Stop condition:

- Stops at the LLD review gate. It does not generate TCDs, code, commits, or
  PRs.

Example:

```text
dfd:lld MLD-0001
```

#### `dfd:design-tree`

Use `dfd:design-tree` to generate HLD, MLD, and LLD drafts from one accepted BRD
in a single provisional design pass.

Accepted input:

- A BRD file path.
- A BRD ID, such as `BRD-0001`.
- `latest`, `latest BRD`, or `最新 BRD`.

What it does:

1. Reads `skills/gen-design-tree/SKILL.md`.
2. Reads and applies the current HLD, MLD, and LLD generation rules from:
   - `skills/gen-hld/SKILL.md`
   - `skills/gen-mld/SKILL.md`
   - `skills/gen-lld/SKILL.md`
3. Resolves exactly one BRD.
4. Infers the HLD, MLD, and LLD split tree before writing files.
5. Collects blocking questions that would change the design-tree shape or
   implementation scope.
6. Uses a centralized brainstorming loop to resolve blocking questions.
7. Generates HLD, MLD, and LLD draft files in one pass.
8. Validates the generated design tree.

Output:

- Files under:
  - `docs/design/<BRD file basename>/hld/`
  - `docs/design/<BRD file basename>/mld/`
  - `docs/design/<BRD file basename>/lld/`

Stop condition:

- Stops at the LLD review gate. This is still a design workflow. It does not
  generate TCDs, edit code, commit, push, or open PRs.

When to use it:

- Use it when the BRD is already accepted and the design shape is small enough
  to infer in one coordinated pass.
- Prefer the step-by-step `dfd:hld`, `dfd:mld`, `dfd:lld` flow when each layer
  needs separate review or when the design is large, risky, or unclear.

Example:

```text
dfd:design-tree BRD-0001
```

### Implementation Commands

Implementation commands use the `dfi` namespace:

```text
dfi:lld <LLD path | LLD id>
dfi:lld-folder <LLD folder path>
```

#### `dfi:lld`

Use `dfi:lld` to implement exactly one accepted LLD.

Accepted input:

- An LLD file path.
- A unique LLD ID, such as `LLD-0001`.

Intentionally rejected input:

- `latest`. Implementation requires an explicit LLD path or unique LLD ID to
  avoid editing code from the wrong design artifact.

What it does:

1. Reads `skills/implement-lld/SKILL.md`.
2. Resolves exactly one LLD.
3. Reads parent MLD, HLD, or BRD files only when needed to clarify inherited
   requirements, constraints, success criteria, business rules, or scope
   boundaries.
4. Reads and applies:
   - `skills/write-plan/SKILL.md`
   - `skills/implement-from-plan/SKILL.md`
   - `skills/test-changes/SKILL.md`
5. Confirms worktree state before editing.
6. Applies the LLD readiness gate.
7. Collects blocking implementation questions before code edits.
8. Generates or updates `docs/devflow/implementation-plan.md`.
9. Generates one TCD under the current BRD design tree.
10. Makes code changes scoped to the selected LLD.
11. Runs planned verification commands.
12. Writes `docs/devflow/test-report.md`.

Output:

- `docs/devflow/implementation-plan.md`
- One TCD under `docs/design/<BRD file basename>/tcd/`
- Code changes scoped to the selected LLD
- `docs/devflow/test-report.md`

Stop condition:

- Stops at the code review gate. It does not generate code-review artifacts,
  commit, push, or open a PR.

Example:

```text
dfi:lld docs/design/BRD-0001-withdrawal-risk-control/lld/LLD-0001-risk-score-storage.md
```

#### `dfi:lld-folder`

Use `dfi:lld-folder` to serially implement every accepted LLD in one `lld/`
folder.

Accepted input:

- One readable directory path containing files named
  `LLD-[0-9][0-9][0-9][0-9]-*.md`.

Intentionally rejected input:

- Individual LLD files.
- Glob expressions.
- Multiple folders.
- `latest`.

What it does:

1. Reads `skills/implement-lld-folder/SKILL.md`.
2. Reads and applies the single-LLD implementation rules from
   `skills/implement-lld/SKILL.md`.
3. Discovers matching LLD files.
4. Sorts them by filename ascending.
5. Stops before implementation if filename order conflicts with explicit
   dependency or delivery-order text in an LLD.
6. Generates or updates a batch-level `docs/devflow/implementation-plan.md`.
7. Implements each LLD serially in filename order.
8. Generates one TCD per LLD.
9. Runs planned verification commands after each meaningful implementation
   milestone.
10. Writes a batch-level `docs/devflow/test-report.md`.
11. Fails fast on the first blocked or failed LLD.

Output:

- A batch-level implementation plan grouped by LLD.
- One TCD per implemented LLD.
- Code changes from each completed LLD.
- A batch-level test report grouped by LLD.

Stop condition:

- Stops at the code review gate. It does not generate code-review artifacts,
  commit, push, or open a PR.

Example:

```text
dfi:lld-folder docs/design/BRD-0001-withdrawal-risk-control/lld
```

### Command Migration

Older local command shims used longer names:

```text
dfd:gen-brd
dfd:gen-hld
dfd:gen-mld
dfd:gen-lld
dfd:gen-design-tree
dfd:implement-lld
dfd:implement-lld-folder
```

The current command names are:

```text
dfd:brd
dfd:hld
dfd:mld
dfd:lld
dfd:design-tree
dfi:lld
dfi:lld-folder
```

Running `install.sh` installs the current command shims and removes the old
local shims from `~/.codex/commands/`.

## Design Document Levels

- BRD: Business Requirement Document. The top-level business requirement and starting artifact.
- HLD: High-level Document. One BRD may expand into one or more HLDs.
- MLD: Medium-level Document. One HLD may expand into one or more MLDs.
- LLD: Low-level Document. One MLD may expand into one or more LLDs.
- TCD: Test Case Document. Test cases derived from the design document tree.

The document tree moves from fuzzy to concrete and from macro to micro.

## Document Layout

Business project documents use a BRD-scoped design tree:

```text
docs/
  brd/
    BRD-0001-withdrawal-risk-control.md
  design/
    BRD-0001-withdrawal-risk-control/
      hld/
        HLD-0001-risk-control-overview.md
      mld/
        MLD-0001-risk-score-data-flow.md
      lld/
        LLD-0001-risk-score-storage-schema.md
      tcd/
        TCD-0001-risk-control-cases.md
```

BRD numbers increment globally under `docs/brd/`. HLD, MLD, LLD, and TCD numbers increment inside the corresponding BRD design folder and document-type directory.

## Project Documents

- `docs/harness-engineering.md`: engineering principles for the plugin.
- `docs/workflow.md`: staged workflow and gates.
- `docs/artifact-contracts.md`: required artifacts and their responsibilities.
