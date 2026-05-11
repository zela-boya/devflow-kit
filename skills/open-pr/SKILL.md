---
name: open-pr
description: Use after implementation, testing, and review artifacts are complete to prepare a commit and pull request.
---

# Open PR

Prepare a pull request with traceable context from requirements through verification.

## Inputs

- Requirements, spec, plan, test report, and code review artifacts.
- Clean and intentional git diff.

## Outputs

- Commit.
- Pull request description using `templates/pr-description.md`.

## Workflow

1. Confirm the diff only contains intended changes.
2. Create a concise commit with the approved scope.
3. Draft the PR description from the artifacts.
4. Include verification evidence and known risks.

## Harness Checks

- The PR description links requirements to implementation and tests.
- The commit excludes unrelated work.
- Remaining risks are explicit.
