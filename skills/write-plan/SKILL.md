---
name: write-plan
description: Use after a spec is accepted to create a step-by-step implementation plan with verification gates.
---

# Write Plan

Convert an accepted spec into an implementation plan that can be executed incrementally.

## Inputs

- Accepted spec artifact.
- Current repository state.

## Outputs

- `docs/devflow/implementation-plan.md` using `templates/implementation-plan.md`.

## Workflow

1. Break the work into small ordered tasks.
2. Identify files or modules likely to change.
3. Define the test or verification command for each meaningful task.
4. Mark review checkpoints where user approval is required.
5. Stop before implementation until the plan is approved.

## Harness Checks

- Tasks are independently understandable.
- Each risky task has a verification step.
- The plan avoids unrelated refactors.
