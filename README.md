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
