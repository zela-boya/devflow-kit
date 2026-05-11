# Harness Engineering

Harness engineering for this project means building repeatable guardrails around Codex-driven software delivery.

Devflow Kit is document-driven first. The repository should be designed around this rule:

```text
The artifact is the source of truth.
The conversation is temporary.
The code is derived.
```

Conversation is useful for exploration and clarification, but it is not the durable state of the workflow. Durable state lives in reviewed artifacts: BRDs, HLDs, MLDs, LLDs, TCDs, test reports, code reviews, and PR descriptions.

The plugin should make each phase explicit:

1. Convert raw intent into a BRD.
2. Expand the BRD into one or more HLDs.
3. Expand each HLD into one or more MLDs.
4. Expand each MLD into one or more LLDs.
5. Derive TCDs from the design document tree.
6. Implement only from approved LLDs and TCDs.
7. Verify changes with concrete commands.
8. Review the diff before commit or PR.
9. Create a PR with traceable evidence.

## Principles

- Documents drive the workflow; prompts do not replace artifacts.
- Artifacts are contracts between phases.
- Later phases must consume accepted artifacts from earlier phases.
- Skills orchestrate judgment-heavy workflow.
- Scripts handle repeatable validation.
- Every phase has a clear input, output, and stop condition.
- Failures should produce useful evidence, not hidden state.

## Implications

- Business requirements must become a BRD before design expansion starts.
- HLD, MLD, and LLD documents refine the same intent from macro to micro.
- LLDs must be concrete enough to guide code changes.
- TCDs must be concrete enough to verify the implementation.
- Test reports and code reviews must capture evidence before PR creation.
- A paused workflow should be recoverable from artifacts without relying on chat history.
