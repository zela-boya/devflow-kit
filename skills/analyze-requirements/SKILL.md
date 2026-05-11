---
name: analyze-requirements
description: Use when turning a raw feature request, bug report, or product idea into a structured requirements artifact before design or implementation.
---

# Analyze Requirements

Convert raw user intent into a requirements artifact that is specific enough to review and plan from.

## Inputs

- Raw user request, issue, ticket, or conversation summary.
- Relevant repository context when available.

## Outputs

- `docs/devflow/requirements.md` using `templates/requirements.md`.

## Workflow

1. Identify the user goal, affected users, and expected outcome.
2. Separate confirmed facts from assumptions.
3. Ask for missing information when a reasonable assumption would be risky.
4. Define acceptance criteria and explicit non-goals.
5. Stop before design or implementation until the requirements artifact is reviewed.

## Harness Checks

- The artifact has no unresolved placeholders.
- Acceptance criteria are testable.
- Non-goals make the first iteration small enough to implement safely.
