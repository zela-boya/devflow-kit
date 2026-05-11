---
name: write-spec
description: Use after requirements are accepted to produce a design/spec artifact with architecture, data flow, failure handling, and testing strategy.
---

# Write Spec

Turn accepted requirements into an implementation-independent spec.

## Inputs

- Accepted requirements artifact.
- Repository structure and relevant existing patterns.

## Outputs

- `docs/devflow/spec.md` using `templates/spec.md`.

## Workflow

1. Summarize the problem and constraints.
2. Propose the smallest design that satisfies the accepted requirements.
3. Define components, interfaces, data flow, and error handling.
4. Define the test strategy and validation commands.
5. Stop for review before writing an implementation plan.

## Harness Checks

- The spec maps every acceptance criterion to a design decision.
- The design identifies failure modes and recovery behavior.
- The test strategy is concrete enough to execute.
