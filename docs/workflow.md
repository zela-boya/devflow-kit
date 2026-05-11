# Workflow

Devflow Kit follows a staged, document-driven workflow:

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

The workflow state is represented by artifacts on disk. Chat may help create or refine those artifacts, but it must not be the only place where decisions, assumptions, or verification evidence live.

## Stages

1. `analyze-requirements`: produce `docs/devflow/requirements.md` from raw intent.
2. `write-spec`: produce `docs/devflow/spec.md` from accepted requirements.
3. `write-plan`: produce `docs/devflow/implementation-plan.md` from an accepted spec.
4. `implement-from-plan`: change code according to the approved plan.
5. `test-changes`: produce `docs/devflow/test-report.md` from verification commands.
6. `review-changes`: produce `docs/devflow/code-review.md` from the final diff and artifacts.
7. `open-pr`: prepare the commit and PR description from the complete artifact set.

Each stage should stop when its artifact requires review or when verification fails.

## Gates

- No spec without accepted requirements.
- No implementation plan without an accepted spec.
- No code changes without an approved implementation plan.
- No PR without verification evidence and review notes.
