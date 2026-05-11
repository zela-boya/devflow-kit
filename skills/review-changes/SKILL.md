---
name: review-changes
description: Use after tests to review the code diff for correctness, regressions, missing tests, and PR readiness.
---

# Review Changes

Perform a code-review pass before commit or PR creation.

## Inputs

- Current git diff.
- Requirements, spec, plan, and test report artifacts.

## Outputs

- `docs/devflow/code-review.md` using `templates/code-review.md`.

## Workflow

1. Compare the diff against the accepted requirements and spec.
2. Prioritize bugs, regressions, missing tests, and unclear behavior.
3. Record findings with file and line references when possible.
4. Fix accepted findings or document why they are deferred.

## Harness Checks

- Review findings lead with risks, not summaries.
- No known failing validation is hidden.
- Deferred issues have an owner or next action.
