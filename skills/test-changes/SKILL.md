---
name: test-changes
description: Use after implementation to run and summarize the validation commands required by the plan or repository.
---

# Test Changes

Run the agreed verification commands and turn results into a durable test report.

## Inputs

- Implementation plan.
- Repository test, lint, build, and type-check commands.

## Outputs

- `docs/devflow/test-report.md` using `templates/test-report.md`.

## Workflow

1. Run the planned validation commands.
2. Capture pass/fail status and relevant output.
3. Investigate failures before proposing fixes.
4. Document skipped checks with a concrete reason.

## Harness Checks

- Every planned validation command is accounted for.
- Failures include root cause notes or next steps.
- The report distinguishes verified facts from assumptions.
