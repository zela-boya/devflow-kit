# Harness Engineering

Harness engineering for this project means building repeatable guardrails around Codex-driven software delivery.

The plugin should make each phase explicit:

1. Convert raw intent into requirements.
2. Convert requirements into a reviewed spec.
3. Convert the spec into an executable plan.
4. Implement only the approved plan.
5. Verify changes with concrete commands.
6. Review the diff before commit or PR.
7. Create a PR with traceable evidence.

## Principles

- Artifacts are contracts between phases.
- Skills orchestrate judgment-heavy workflow.
- Scripts handle repeatable validation.
- Every phase has a clear input, output, and stop condition.
- Failures should produce useful evidence, not hidden state.
