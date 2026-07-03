---
name: gen-mld
description: Use when the user types `dfd:mld <HLD file path or HLD id>` to generate one or more MLD drafts from an accepted HLD, producing medium-level design documents under the same BRD design tree without proceeding to LLD, TCD, code, commits, or PRs.
---

# Generate MLD

`dfd:mld` means Devflow Design: generate MLD from an HLD.

Use this skill when the user types:

```text
dfd:mld <HLD file path>
dfd:mld <HLD id>
dfd:mld latest
dfd:mld 最新 HLD
```

## Goal

Read one accepted HLD and generate one or more Medium-Level Design drafts under the same BRD-scoped design tree:

```text
docs/design/<BRD file basename>/mld/
```

Use `templates/mld.md` as the document shape.

Example:

```text
docs/design/BRD-0001-withdrawal-risk-control/hld/HLD-0001-risk-control-overview.md
docs/design/BRD-0001-withdrawal-risk-control/mld/MLD-0001-risk-score-module.md
```

## Required Behavior

1. Parse the input after `dfd:mld`.
2. Resolve the source HLD from the parsed input.
3. Read the HLD and identify scope boundaries, BRD requirement mapping, design responsibilities, dependencies, rules, data objects, error handling, observability, and recommended MLD splits.
4. Apply the HLD Gate below before generating files.
5. Check whether HLD open questions block medium-level module contract design.
6. Decide which HLD responsibilities have independent module-contract design value.
7. If the HLD contains explicit MLD split recommendations and each recommendation has clear module-contract value, generate those MLD draft files directly.
8. If the split is unclear, incomplete, too granular, or too broad, use the clarification workflow below, then generate files after the user confirms the split.
9. Preserve HLD technical direction and deepen it into concrete module contracts. Do not spend most of the MLD repeating HLD scope/mapping.
10. Generate MLD draft files using ASCII-only file and directory slugs.
11. Stop at the MLD review gate. Do not generate LLD, TCD, code, commits, or PRs.

## HLD Resolution

Accept these input forms:

- Readable HLD file path, such as `docs/design/BRD-0001-example/hld/HLD-0001-overview.md`.
- HLD ID, such as `HLD-0001`; find matching files under `docs/design/**/hld/`.
- `latest`, `latest HLD`, or `最新 HLD`; select the latest HLD under `docs/design/**/hld/`, preferring the highest numbered file when timestamps are not useful.

If the input does not resolve to exactly one HLD, list the candidates and ask the user to choose.

## Parent Context

Use the selected HLD as the parent document. If the HLD frontmatter includes BRD metadata, preserve it in generated MLD frontmatter.

If the HLD references a readable BRD path, read the BRD only when needed to clarify business requirements, success criteria, or constraints. The HLD remains the source of truth for MLD scope.

## HLD Gate

Before generating MLD files, verify that the HLD is a valid parent for module-contract design.

Generate MLD only when the HLD:

- Has a clear BRD-scoped coverage boundary.
- Is not a project overview HLD.
- Identifies high-level responsibilities inside one BRD business closure or single capability.
- Provides enough design context to derive module contracts.

Stop and do not create MLD files when:

- The HLD is project-level and covers multiple independent business closures.
- The HLD mostly mirrors a broad BRD without clear `本 HLD 覆盖 / 不覆盖` boundaries.
- The HLD's "MLD split" is only a module list with no split rationale or module-contract value.
- The HLD mixes unrelated domains such as recharge, withdrawal, sweep, multisig, funds, admin, app, and migration in one design.

When stopping, report:

1. Why the HLD is not a valid MLD parent.
2. Which business closures or HLD boundaries should be fixed first.
3. A recommendation to split/fix the BRD or HLD before running `dfd:mld` again.

Do not generate MLD from a project overview HLD as a fallback.

## Missing Information Strategy

Ask one clarifying question before generating MLD when missing or unresolved information can change module design:

- The target HLD cannot be uniquely identified.
- The HLD scope boundary or module boundaries are unclear or internally contradictory.
- The HLD might be project-level and generating MLD could preserve a bad split.
- HLD open questions affect module ownership, interface direction, data ownership, error handling, or security.
- Multiple MLD splits are plausible and would create different module documents.

If missing information is non-blocking, generate a draft and record uncertainty in `开放问题与待澄清点`:

- Incomplete target file paths.
- Incomplete exact interface signatures.
- Incomplete test tool names.
- Incomplete metric or log names.
- Incomplete alert thresholds.

## Split Rules

MLD is module-contract design. Split by responsibilities that need independent contracts, not by every HLD module, page, data object, or requirement.

Generate multiple MLDs directly only when the HLD clearly recommends distinct MLD splits and each candidate has module-contract design value.

Treat a candidate as having module-contract value when it has several of:

- Distinct responsibility boundary.
- Owned data object or lifecycle.
- State machine or meaningful state transitions.
- Interface or event contract with other modules.
- Idempotency, consistency, compensation, or retry rules.
- External dependency, reliability risk, or security concern.
- Independent test strategy.
- Independent observability or audit needs.

Do not split a candidate into its own MLD when it is only:

- A small helper responsibility.
- A UI display point without module-level behavior.
- A field, status, validation rule, or minor step in a larger flow.
- A thin wrapper around another module.
- Understandable only as part of another module contract.

Do not stop for confirmation when the HLD provides clear MLD recommendations and the module-contract value is unambiguous.

Ask for clarification when the split is unclear, incomplete, too granular, too broad, or mechanically copied from an HLD module table. Use a brainstorming-style clarification loop:

1. State the ambiguity in concrete terms.
2. Propose 2-3 split options with tradeoffs.
3. Recommend the smallest coherent module-contract split.
4. Ask one clear confirmation question.
5. After the user confirms, proceed to generate the MLD files in the same turn.

If the split is not clearly necessary and the HLD does not recommend multiple valuable MLDs, default to one MLD and keep future LLD split suggestions inside that MLD's `LLD 拆分建议`.

Examples:

- HLD for "充值自动入账" recommends "充值地址归属、链上充值识别、充值入账记账" and explains each has distinct contracts -> generate three MLD files directly.
- HLD has several modules but no split recommendation and unclear ownership -> ask for confirmation before writing.
- HLD describes one module with several internal behaviors -> generate one MLD directly.
- HLD is a project overview containing recharge, sweep, withdrawal, multisig, admin, and app -> stop and require BRD/HLD split first.

## MLD Content Rules

Fill the MLD from the HLD at module-contract design level:

- `HLD 职责映射`: list covered HLD responsibilities, explicitly excluded responsibilities, and corresponding BRD requirements or child requirements. Keep this concise; do not let mapping dominate the MLD.
- `目的`: define what the module is responsible for in one sentence.
- `职责边界`: separate what this module owns from what it delegates.
- `接口契约草案`: describe provided and consumed capabilities, callers, purpose, input/output meaning, and error behavior. Do not require final code signatures.
- `建议落点`: optionally propose target repository areas only when inferable from repo patterns or HLD context.
- `模块契约`: define owned entities, enforced rules, and observable completion definitions.
- `数据与状态设计`: describe key data content, state transitions, lifecycle, and ownership without full DDL.
- `关键技术决策`: capture module-level technical decisions, strategy names, consistency model, idempotency boundary, persistence choices, and external dependency handling.
- `依赖`: list internal modules, external services, storage, queues, APIs, and failure impact.
- `行为描述`: describe normal and exceptional behavior principles without implementation steps.
- `错误处理`: identify module errors and defensive assertions.
- `测试策略`: map module behavior to unit, integration, and contract test layers.
- `可观测性`: define metrics, logs, and alert conditions.
- `安全`: identify module-specific risks and mitigation strategy.
- `LLD 拆分建议`: recommend low-level design splits only when there is enough complexity to justify them.
- `开放问题与待澄清点`: inherit unresolved HLD questions that still matter to MLD and add new module-design questions.

MLD may include key data objects, required data content, state names, capability-level interface names, background task concepts, and strategy names when they affect module contracts.

Do not require or write full database DDL, full API field tables, concrete directory structure, detailed file responsibilities, concrete class/package names, function signatures, SQL, line-by-line implementation steps, full test case documents, or code. Those belong to later LLD, TCD, and implementation stages.

An MLD is too shallow if it only says what the module does and does not specify:

- Owned entities and required data content.
- State transitions or lifecycle rules.
- Interface/event capability contracts and caller expectations.
- Idempotency, consistency, retry, compensation, and failure semantics.
- Security, permission, audit, and observability obligations.
- Which details must be handled by LLD and why.

An MLD is too verbose in the wrong way if most of it repeats HLD scope or BRD background instead of defining module contracts.

## Filename And Slug Rules

Use ASCII-only slugs for generated MLD files and inherited design directories.

- If parent BRD/HLD paths contain Chinese or non-ASCII characters, write new files under the ASCII design directory when possible, or report that the existing path should be normalized before continuing.
- Keep IDs such as `MLD-0001`.
- Use lower-case kebab-case English names after the ID.
- Chinese is allowed in title/body, not filenames or directories.

Good:

```text
docs/design/BRD-0002-v2-usdt-deposit-auto-credit/mld/MLD-0001-chain-deposit-scan-contract.md
```

Bad:

```text
docs/design/BRD-0002-v2-usdt-充值自动入账-gm-豆/mld/MLD-0001-链上充值监控.md
```

## Numbering And Paths

MLD numbering is scoped to one BRD design folder and increments inside that BRD's `mld/` directory:

```text
docs/design/BRD-0001-withdrawal-risk-control/mld/MLD-0001-risk-score-module.md
docs/design/BRD-0001-withdrawal-risk-control/mld/MLD-0002-admin-review-module.md
```

Another BRD may also start from `MLD-0001`.

Compute the next MLD ID by scanning existing files matching:

```text
MLD-[0-9][0-9][0-9][0-9]-*.md
```

Refuse to overwrite existing MLD files.

## Validation

After writing MLD files, run the repository's available validation command:

```bash
scripts/devflow design validate --target <target-repo>
```

If the validator currently checks only BRD structure, still run it and report that MLD validation is not yet automated.

Report:

- Source HLD path.
- Generated MLD file paths.
- Whether validation passed.
- Any open questions requiring review.

## Hard Stops

Do not:

- Modify the source HLD.
- Modify the source BRD.
- Generate LLD or TCD.
- Write implementation code.
- Commit or push generated files unless the user explicitly asks.
- Overwrite existing MLD files.
