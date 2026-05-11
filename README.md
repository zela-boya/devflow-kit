# devflow-kit

Devflow Kit is a Codex plugin for document-driven agentic development.

Its core rule is simple:

```text
The artifact is the source of truth.
The conversation is temporary.
The code is derived.
```

This project treats requirements, specs, implementation plans, test reports, code reviews, and PR descriptions as durable workflow artifacts. Codex may use conversation to clarify intent, but each delivery phase must be driven by reviewed documents rather than transient chat context.

## Workflow

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

Each stage has a defined input, output, and stop condition. A later stage should not proceed until the previous artifact is complete enough to act as a contract.

## Project Documents

- `docs/harness-engineering.md`: engineering principles for the plugin.
- `docs/workflow.md`: staged workflow and gates.
- `docs/artifact-contracts.md`: required artifacts and their responsibilities.
