---
name: implement-from-plan
description: Use when executing an approved implementation plan while preserving artifacts, scope, and verification gates.
---

# Implement From Plan

Execute an approved plan with small changes and verification after meaningful milestones.

## Inputs

- Approved implementation plan.
- Current repository state.

## Outputs

- Source changes.
- Updated implementation notes when the plan changes.

## Workflow

1. Confirm the worktree state before editing.
2. Execute one plan step at a time.
3. Keep changes scoped to the approved plan.
4. Update the plan when reality differs from the original assumptions.
5. Run the planned verification commands before claiming completion.

## Harness Checks

- User changes are preserved.
- Deviations from the plan are documented.
- Verification output is captured for the test report.
