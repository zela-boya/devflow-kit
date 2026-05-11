# Artifact Contracts

Artifacts make the workflow auditable and resumable. Each stage should consume the previous artifact and produce the next one.

Artifacts are the source of truth for Devflow Kit. They should capture decisions, assumptions, acceptance criteria, verification evidence, and residual risk so the workflow can continue without relying on chat history.

## Contract Rules

- Every artifact must state its purpose and scope.
- Every artifact must separate confirmed facts from assumptions or open questions.
- A downstream artifact must reference or preserve the decisions it depends on.
- An artifact with blocking open questions cannot be used to authorize the next stage.
- Verification evidence must name the command or check that produced it.

## Requirements

- Location: `docs/devflow/requirements.md`
- Template: `templates/requirements.md`
- Must include goal, context, acceptance criteria, non-goals, assumptions, and open questions.

## Spec

- Location: `docs/devflow/spec.md`
- Template: `templates/spec.md`
- Must include design, components, data flow, error handling, and testing strategy.

## Implementation Plan

- Location: `docs/devflow/implementation-plan.md`
- Template: `templates/implementation-plan.md`
- Must include ordered tasks, likely files, verification commands, checkpoints, and risks.

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
