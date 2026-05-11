# Workflow

Devflow Kit follows a staged workflow:

```text
raw request
  -> requirements
  -> spec
  -> implementation plan
  -> code changes
  -> test report
  -> code review
  -> commit and PR
```

## Stages

1. `analyze-requirements`: produce `docs/devflow/requirements.md`.
2. `write-spec`: produce `docs/devflow/spec.md`.
3. `write-plan`: produce `docs/devflow/implementation-plan.md`.
4. `implement-from-plan`: change code according to the approved plan.
5. `test-changes`: produce `docs/devflow/test-report.md`.
6. `review-changes`: produce `docs/devflow/code-review.md`.
7. `open-pr`: prepare the commit and PR description.

Each stage should stop when its artifact requires review or when verification fails.
