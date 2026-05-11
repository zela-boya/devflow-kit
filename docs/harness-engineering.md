# Harness Engineering

Harness engineering for this project means building repeatable guardrails around Codex-driven software delivery.

Devflow Kit is document-driven first. The repository should be designed around this rule:

```text
The artifact is the source of truth.
The conversation is temporary.
The code is derived.
```

Conversation is useful for exploration and clarification, but it is not the durable state of the workflow. Durable state lives in reviewed artifacts: requirements, specs, implementation plans, test reports, code reviews, and PR descriptions.

The plugin should make each phase explicit:

1. Convert raw intent into requirements.
2. Convert requirements into a reviewed spec.
3. Convert the spec into an executable plan.
4. Implement only the approved plan.
5. Verify changes with concrete commands.
6. Review the diff before commit or PR.
7. Create a PR with traceable evidence.

## Principles

- Documents drive the workflow; prompts do not replace artifacts.
- Artifacts are contracts between phases.
- Later phases must consume accepted artifacts from earlier phases.
- Skills orchestrate judgment-heavy workflow.
- Scripts handle repeatable validation.
- Every phase has a clear input, output, and stop condition.
- Failures should produce useful evidence, not hidden state.

## Implications

- Requirements must become an artifact before design starts.
- Specs must describe the intended behavior before planning starts.
- Plans must define the implementation path before code changes start.
- Test reports and code reviews must capture evidence before PR creation.
- A paused workflow should be recoverable from artifacts without relying on chat history.
