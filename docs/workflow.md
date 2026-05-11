# Workflow

Devflow Kit follows a staged, document-driven workflow:

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

The workflow state is represented by artifacts on disk. Chat may help create or refine those artifacts, but it must not be the only place where decisions, assumptions, or verification evidence live.

## Design Document Tree

Devflow Kit uses a design document tree for business projects:

```text
BRD
  -> HLD 1
    -> MLD 1
      -> LLD 1
      -> LLD 2
    -> MLD 2
  -> HLD 2
```

The tree starts with a single BRD. One BRD may expand into one or more HLDs, one HLD may expand into one or more MLDs, and one MLD may expand into one or more LLDs. TCDs are derived from the approved design tree and define how the system will be verified.

This progression moves from fuzzy to concrete and from macro to micro.

## Document Layout

In a target business repository, BRD documents live under `docs/brd/` and increment globally:

```text
docs/
  brd/
    BRD-0001-withdrawal-risk-control.md
    BRD-0002-user-kyc-upgrade.md
```

Each BRD owns a design folder with the same name as the BRD file without `.md`:

```text
docs/
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

HLD, MLD, LLD, and TCD numbering is scoped to the current BRD design folder and the document-type directory. A different BRD design folder may also contain `HLD-0001`, `MLD-0001`, `LLD-0001`, and `TCD-0001`.

Upper-level documents do not maintain child lists. Lower-level documents declare their parent with an ID, relative path, and title so conflicts can be diagnosed by both scripts and humans.

## Stages

1. `analyze-requirements`: produce a BRD from raw intent.
2. `write-spec`: expand accepted BRD content into HLD, MLD, and LLD documents.
3. `write-plan`: derive implementation tasks from accepted LLDs.
4. `test-changes`: derive TCDs and run verification commands.
5. `implement-from-plan`: change code according to approved LLDs, tasks, and TCDs.
6. `review-changes`: produce `docs/devflow/code-review.md` from the final diff and artifacts.
7. `open-pr`: prepare the commit and PR description from the complete artifact set.

Each stage should stop when its artifact requires review or when verification fails.

## Gates

- No HLD without an accepted BRD.
- No MLD without an accepted HLD.
- No LLD without an accepted MLD.
- No code changes without approved LLDs and TCDs.
- No PR without verification evidence and review notes.
