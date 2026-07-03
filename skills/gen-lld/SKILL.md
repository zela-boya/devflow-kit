---
name: gen-lld
description: Use when the user types `dfd:lld <MLD file path or MLD id>` to generate one or more LLD drafts from an accepted MLD, producing low-level design documents under the same BRD design tree without proceeding to TCD, code, commits, or PRs.
---

# Generate LLD

`dfd:lld` means Devflow Design: generate LLD from an MLD.

Use this skill when the user types:

```text
dfd:lld <MLD file path>
dfd:lld <MLD id>
dfd:lld latest
dfd:lld 最新 MLD
```

## Goal

Read one accepted MLD and generate one or more Low-Level Design drafts under the same BRD-scoped design tree:

```text
docs/design/<BRD file basename>/lld/
```

Use `templates/lld.md` as the document shape.

Example:

```text
docs/design/BRD-0001-withdrawal-risk-control/mld/MLD-0001-risk-score-module.md
docs/design/BRD-0001-withdrawal-risk-control/lld/LLD-0001-risk-score-api-and-storage.md
```

## Required Behavior

1. Parse the input after `dfd:lld`.
2. Resolve the source MLD from the parsed input.
3. Read the MLD and identify HLD/BRD mappings, module-contract scope, interfaces, entities, state, rules, dependencies, errors, assertions, tests, observability, security, and any recommended LLD splits.
4. Apply the MLD Gate below before generating files.
5. Check whether MLD open questions block low-level implementation design decisions.
6. Decide which implementation scopes are PR-sized.
7. If the MLD explicitly recommends LLD splits and each split is PR-sized, generate those LLD draft files directly.
8. If the split is unclear, too broad, too small, or not PR-sized, use the clarification workflow below, then generate files after the user confirms the split.
9. Expand module contracts into concrete codebase-aware implementation design. Do not produce generic PR-sized prose that lacks actionable technical detail.
10. Generate LLD draft files using ASCII-only file and directory slugs.
11. Stop at the LLD review gate. Do not generate TCD, code, commits, or PRs.

## MLD Resolution

Accept these input forms:

- Readable MLD file path, such as `docs/design/BRD-0001-example/mld/MLD-0001-module.md`.
- MLD ID, such as `MLD-0001`; find matching files under `docs/design/**/mld/`.
- `latest`, `latest MLD`, or `最新 MLD`; select the latest MLD under `docs/design/**/mld/`, preferring the highest numbered file when timestamps are not useful.

If the input does not resolve to exactly one MLD, list the candidates and ask the user to choose.

## Parent Context

Use the selected MLD as the parent document. If the MLD frontmatter includes BRD and HLD metadata, preserve it in generated LLD frontmatter where the template supports it.

If the MLD references readable HLD or BRD paths, read them only when needed to clarify inherited rules, module boundaries, business constraints, or acceptance expectations. The MLD remains the source of truth for LLD scope.

## MLD Gate

Before generating LLD files, verify that the MLD is a valid parent for PR-sized implementation design.

Generate LLD only when the MLD:

- Is a module-contract design, not a project overview.
- Has clear HLD responsibility mapping and BRD requirement mapping, or enough context to infer them.
- Defines module boundaries, owned data/state, interaction contracts, errors, tests, and observability at contract level.
- Is specific enough to derive implementation scopes.

Stop and do not create LLD files when:

- The MLD is really a project/module overview that spans multiple business closures.
- The MLD mixes unrelated modules or unrelated review surfaces.
- The MLD lacks enough contract detail to decide API, storage, state, worker, algorithm, or integration boundaries.
- Open questions would change implementation scope, data schema, API behavior, state transitions, or rollout order.

When stopping, report:

1. Why the MLD is not ready for LLD.
2. What contract details or splits need to be fixed first.
3. A recommendation to update/regenerate the MLD before running `dfd:lld` again.

Do not generate a large catch-all LLD as a fallback.

## Missing Information Strategy

Ask one clarifying question before generating LLD when missing or unresolved information can change implementation design:

- The target MLD cannot be uniquely identified.
- The MLD implementation scope is unclear or internally contradictory.
- The MLD is missing HLD/BRD mapping or module-contract boundaries needed to define PR-sized work.
- MLD open questions affect API contracts, data schema, state changes, algorithms, error behavior, assertions, or configuration.
- Multiple LLD splits are plausible and would create different PR-sized implementation documents.

If missing information is non-blocking, generate a draft and record uncertainty in `开放问题与待澄清点`:

- Incomplete exact endpoint paths.
- Incomplete exact function signatures.
- Incomplete field types or default values.
- Incomplete config keys or environment variable names.
- Incomplete migration or rollback details.
- Incomplete alert thresholds.

## Split Rules

One LLD should be one PR-sized implementation design.

PR-sized means a reviewer can understand, test, merge, and roll back the implementation as one coherent change.

An LLD may include related small changes when they are necessary for the same resource lifecycle, worker loop, algorithm, adapter, or API capability. It may be slightly larger than a single small task, but should stay near the size of one resource lifecycle management change.

Generate multiple LLDs directly when the MLD clearly recommends distinct LLD splits and each split is PR-sized.

Good LLD boundaries include:

- One resource lifecycle API and its required storage/repo validation.
- One background job or worker loop and its required cursor/state/idempotency records.
- One core algorithm or strategy and its required configuration.
- One event handler and its state transitions.
- One external integration adapter and its timeout/retry/error mapping.
- One storage schema/repo contract when it is a distinct review surface.
- One UI/API query or operation capability with necessary validation and errors.

Split when a candidate LLD:

- Crosses independent business closures.
- Crosses multiple services or language stacks that can be delivered independently.
- Combines large API, worker, algorithm, schema, migration, audit, and observability work into one review.
- Has unclear test scope.
- Would be hard to review as one PR.
- Would be hard to roll back without affecting independent capabilities.
- Requires different rollout or delivery order.

Do not split when the candidate is only:

- One field.
- One helper function.
- One error code.
- One log or metric.
- A tiny validation rule.
- A small change that must ship with the same API, worker, algorithm, adapter, or resource lifecycle to compile, test, or behave correctly.

Ask for clarification when the split is unclear, incomplete, too broad, too small, or not PR-sized. Use a brainstorming-style clarification loop:

1. State the ambiguity in concrete terms.
2. Propose 2-3 split options with tradeoffs.
3. Recommend the smallest coherent PR-sized split.
4. Ask one clear confirmation question.
5. After the user confirms, proceed to generate the LLD files in the same turn.

If the MLD does not recommend multiple LLDs but clearly contains multiple PR-sized implementation units, propose a PR-sized split instead of generating one large LLD.

If the MLD describes one cohesive PR-sized implementation unit, generate one LLD.

Examples:

- MLD says "LLD 拆分建议：资源存储与生命周期 API、异步同步任务、外部适配器" and each is PR-sized -> generate three LLD files directly.
- MLD lists several responsibilities but no implementation split and unclear ownership -> ask for confirmation before writing.
- MLD describes one cohesive implementation unit -> generate one LLD directly.
- MLD covers API, PHP address generation, Go repository, DB schema, CREATE2 algorithm, deploy-state worker, and audit logging -> split into PR-sized LLDs.

## LLD Content Rules

Fill the LLD from the MLD at PR-sized implementation-design level:

- `PR 级范围`: state what this LLD covers, what it does not cover, and why it is PR-sized.
- `来源映射`: map the LLD to MLD contract areas, HLD responsibilities, and BRD requirements or child requirements.
- `实现目标`: describe the behavior added or changed after this PR lands.
- `变更范围`: identify only the APIs, functions, algorithms, jobs, events, files, schemas, configs, or adapters in this PR-sized scope.
- `代码库落点`: identify existing files, packages, modules, migrations, commands, or config areas when inferable. If not inferable, say what must be checked before implementation.
- `设计细节`: include only sections relevant to this LLD type. API, worker, storage, algorithm, integration, and UI/query LLDs should not all fill every section.
- `数据与状态变更`: define concrete schema, migration, state, lifecycle, or rollback details when applicable.
- `错误处理与断言`: define implementation errors, return/throw locations, recovery behavior, and assertions.
- `测试范围`: define the tests needed for this PR-sized implementation.
- `可观测性`: define metrics, logs, alerts, and trace points when applicable.
- `依赖与交付顺序`: identify prerequisites, downstream LLDs, feature flags, migration order, or rollout concerns.
- `开放问题与待澄清点`: inherit unresolved MLD questions that still matter to LLD and add new implementation-design questions.

LLD may include concrete signatures, request/response examples, schema fields, pseudocode, and file paths.

Do not write production code, complete migration scripts, full test case documents, or broad PR plans. Those belong to implementation and TCD stages.

Do not generate an LLD that tries to exhaustively cover every API, worker, storage, algorithm, migration, audit, and monitoring concern from a large MLD. Split instead.

An LLD is too shallow if a developer cannot start implementation from it. It should include applicable details such as:

- Endpoint method/path, request/response examples, auth and permission checks.
- Function or method responsibilities and important signatures when known.
- Schema fields, indexes, uniqueness, migration and rollback notes.
- Worker trigger, cursor/state, idempotency key, retry and compensation behavior.
- Algorithm inputs, outputs, rules, pseudocode, precision, and edge cases.
- Existing code areas, files, packages, or migration locations when inferable from the repo.
- Concrete errors, assertions, test targets, metrics, logs, and alerts.

Keep the LLD PR-sized, but do not make it generic.

## Filename And Slug Rules

Use ASCII-only slugs for generated LLD files and inherited design directories.

- If parent BRD/HLD/MLD paths contain Chinese or non-ASCII characters, write new files under the ASCII design directory when possible, or report that the existing path should be normalized before continuing.
- Keep IDs such as `LLD-0001`.
- Use lower-case kebab-case English names after the ID.
- Chinese is allowed in title/body, not filenames or directories.

Good:

```text
docs/design/BRD-0002-v2-usdt-deposit-auto-credit/lld/LLD-0001-transfer-scan-adapter.md
```

Bad:

```text
docs/design/BRD-0002-v2-usdt-充值自动入账-gm-豆/lld/LLD-0001-充值扫描适配器.md
```

## Numbering And Paths

LLD numbering is scoped to one BRD design folder and increments inside that BRD's `lld/` directory:

```text
docs/design/BRD-0001-withdrawal-risk-control/lld/LLD-0001-risk-score-api-and-storage.md
docs/design/BRD-0001-withdrawal-risk-control/lld/LLD-0002-risk-score-worker.md
```

Another BRD may also start from `LLD-0001`.

Compute the next LLD ID by scanning existing files matching:

```text
LLD-[0-9][0-9][0-9][0-9]-*.md
```

Refuse to overwrite existing LLD files.

## Validation

After writing LLD files, run the repository's available validation command:

```bash
scripts/devflow design validate --target <target-repo>
```

If the validator currently checks only BRD structure, still run it and report that LLD validation is not yet automated.

Report:

- Source MLD path.
- Generated LLD file paths.
- Whether validation passed.
- Any open questions requiring review.

## Hard Stops

Do not:

- Modify the source MLD.
- Modify the source HLD or BRD.
- Generate TCD.
- Write implementation code.
- Commit or push generated files unless the user explicitly asks.
- Overwrite existing LLD files.
