# Artifact Contracts

Artifacts make the workflow auditable and resumable. Each stage should consume the previous artifact and produce the next one.

Artifacts are the source of truth for Devflow Kit. They should capture decisions, assumptions, acceptance criteria, design decisions, verification evidence, and residual risk so the workflow can continue without relying on chat history.

## Contract Rules

- Every artifact must state its purpose and scope.
- Every artifact must separate confirmed facts from assumptions or open questions.
- A downstream artifact must reference or preserve the decisions it depends on.
- An artifact with blocking open questions cannot be used to authorize the next stage.
- Verification evidence must name the command or check that produced it.

## Paths and Numbering

BRD documents live in the target repository under `docs/brd/` and use globally increasing numbers:

```text
docs/brd/BRD-0001-withdrawal-risk-control.md
docs/brd/BRD-0002-user-kyc-upgrade.md
```

Each BRD owns a design folder under `docs/design/` with the same base name as the BRD file:

```text
docs/design/BRD-0001-withdrawal-risk-control/
```

Design documents live under that BRD-scoped design folder:

```text
docs/design/BRD-0001-withdrawal-risk-control/hld/HLD-0001-risk-control-overview.md
docs/design/BRD-0001-withdrawal-risk-control/mld/MLD-0001-risk-score-data-flow.md
docs/design/BRD-0001-withdrawal-risk-control/lld/LLD-0001-risk-score-storage-schema.md
docs/design/BRD-0001-withdrawal-risk-control/tcd/TCD-0001-risk-control-cases.md
```

HLD, MLD, LLD, and TCD numbers increment inside their own document-type directory within one BRD design folder.

## Parent References

Upper-level documents must not maintain child document lists. Lower-level documents must reference their parent documents.

Parent references must include:

- `id`: the parent document ID, used for machine checks.
- `path`: the relative path to the parent document, used to locate the file.
- `title`: the parent document title, used by humans to catch incorrect links.

Example HLD metadata:

```yaml
---
id: HLD-0001
type: HLD
title: Risk Control Overview
status: draft
brd:
  id: BRD-0001
  path: ../../brd/BRD-0001-withdrawal-risk-control.md
  title: Withdrawal Risk Control
parent:
  id: BRD-0001
  path: ../../brd/BRD-0001-withdrawal-risk-control.md
  title: Withdrawal Risk Control
---
```

Example MLD metadata:

```yaml
---
id: MLD-0001
type: MLD
title: Risk Score Data Flow
status: draft
brd:
  id: BRD-0001
  path: ../../brd/BRD-0001-withdrawal-risk-control.md
  title: Withdrawal Risk Control
parent:
  id: HLD-0001
  path: ../hld/HLD-0001-risk-control-overview.md
  title: Risk Control Overview
---
```

Example TCD metadata:

```yaml
---
id: TCD-0001
type: TCD
title: Risk Control Test Cases
status: draft
brd:
  id: BRD-0001
  path: ../../brd/BRD-0001-withdrawal-risk-control.md
  title: Withdrawal Risk Control
parents:
  - id: LLD-0001
    path: ../lld/LLD-0001-risk-score-storage-schema.md
    title: Risk Score Storage Schema
---
```

## BRD

- Name: Business Requirement Document.
- Role: The top-level business requirement document and starting artifact.
- Must define the business intent, affected users, business scope, acceptance criteria, non-goals, assumptions, and open questions.

## HLD

- Name: High-level Document.
- Role: A high-level design document derived from a BRD.
- Cardinality: One BRD may expand into one or more HLDs.
- Must stay close to business and system-level design concerns.

## MLD

- Name: Medium-level Document.
- Role: A medium-level design document derived from an HLD.
- Cardinality: One HLD may expand into one or more MLDs.
- Must bridge high-level system design and low-level implementation design.

## LLD

- Name: Low-level Document.
- Role: A low-level design document derived from an MLD.
- Cardinality: One MLD may expand into one or more LLDs.
- Must be concrete enough to guide implementation.

## TCD

- Name: Test Case Document.
- Role: A test design document derived from the approved design tree.
- Must be concrete enough to verify the behavior described by BRD, HLD, MLD, and LLD artifacts.

## Test Report

- Location: `docs/devflow/test-report.md`
- Template: `templates/test-report.md`
- Must include commands, results, failures, and skipped checks.

## Code Review

- Location: `docs/devflow/code-review.md`
- Template: `templates/code-review.md`
- Must lead with findings and document residual risk.

## PR Description

- Template: `templates/pr-description.md`
- Must summarize requirements, implementation, verification, and review notes.
