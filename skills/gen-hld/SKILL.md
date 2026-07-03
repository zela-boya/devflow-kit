---
name: gen-hld
description: Use when the user types `dfd:hld <brd path or BRD id>` to generate one or more HLD drafts from an accepted BRD under docs/brd, producing high-level design documents under docs/design/<BRD>/hld without proceeding to MLD, LLD, TCD, code, commits, or PRs.
---

# Generate HLD

`dfd:hld` means Devflow Design: generate HLD from a BRD.

Use this skill when the user types:

```text
dfd:hld <brd path>
dfd:hld <BRD id>
dfd:hld latest
dfd:hld 最新 BRD
```

## Goal

Read one accepted BRD and generate one or more High-Level Design drafts under the BRD-scoped design tree:

```text
docs/design/<BRD file basename>/hld/
```

Use `templates/hld.md` as the document shape.

Example:

```text
docs/brd/BRD-0001-withdrawal-risk-control.md
docs/design/BRD-0001-withdrawal-risk-control/hld/HLD-0001-risk-control-overview.md
```

## Required Behavior

1. Parse the input after `dfd:hld`.
2. Resolve the source BRD from the parsed input.
3. Read the BRD and identify business goals, scope, requirements, child requirements, constraints, risks, success criteria, and open questions.
4. Apply the BRD Scope Gate below before generating files.
5. Check whether BRD open questions block high-level design decisions.
6. For a valid small request, single capability, or single business-closure BRD, default to one HLD.
7. Preserve and expand BRD technical context into explicit high-level design direction. Do not produce a mostly restated BRD.
8. Generate HLD draft files in the BRD-scoped `hld/` directory using ASCII-only directory and file slugs.
9. Stop at the HLD review gate. Do not generate MLD, LLD, TCD, code, commits, or PRs.

## BRD Resolution

Accept these input forms:

- Readable BRD file path, such as `docs/brd/BRD-0001-example.md`.
- BRD ID, such as `BRD-0001`; find the matching file under `docs/brd/`.
- `latest`, `latest BRD`, or `最新 BRD`; select the highest numbered `BRD-*.md` under `docs/brd/`.

If the input does not resolve to exactly one BRD, list the candidates and ask the user to choose.

## BRD Scope Gate

Before generating an HLD, classify the BRD with semantic judgment:

- Small request / single capability.
- Single business closure.
- Project-level BRD containing multiple business closures.

Generate HLD only for a small request, single capability, or single business-closure BRD.

If the BRD is project-level, stop and do not create HLD files. Report:

1. That the BRD is too broad for a useful HLD.
2. Concrete evidence from the BRD, such as multiple independent flows, stakeholders, success criteria, rollout boundaries, or acceptance outcomes.
3. A proposed business-closure BRD split.
4. A recommendation to split the BRD first, then run `dfd:hld` for each accepted BRD.

Do not generate a project overview HLD as a fallback. A project-level HLD tends to mirror the BRD, then turns MLD into a module list instead of preserving business-slice design boundaries.

Treat these as project-level signals:

- The BRD contains several independently shippable flows, such as recharge, withdrawal, sweep, approval, funds management, admin operations, app experience, or migration.
- Requirements are really epics or modules rather than capabilities inside one business closure.
- Different requirements have different owners, acceptance criteria, risk profiles, or rollout phases.
- The BRD title or context reads like a project charter, full solution proposal, or system replacement plan.

Treat these as valid HLD inputs:

- A compact resource/API lifecycle capability.
- One user or operational journey from trigger to accepted outcome.
- Requirements that share one success boundary and one system design problem.

## Missing Information Strategy

Ask one clarifying question before generating HLD when missing or unresolved information can change the architecture:

- The target BRD cannot be uniquely identified.
- The BRD scope is unclear or internally contradictory.
- The BRD might be project-level and generating HLD could create a project overview.
- The BRD has open questions that affect module boundaries, data ownership, permissions, or rollout strategy.
- The valid BRD still has multiple plausible HLD boundaries that would create different document trees.

If missing information is non-blocking, generate a draft and record uncertainty in `开放问题与待澄清点`:

- Incomplete owner.
- Incomplete target dates.
- Incomplete monitoring metric details.
- Incomplete existing-system replacement details.
- Incomplete permission-role details.

## Split Rules

Default to one HLD for one valid BRD. Multiple HLDs should be rare.

Before generating multiple HLDs, ask for confirmation only when a valid BRD contains multiple high-level architecture alternatives or independent design surfaces that cannot be explained coherently in one HLD.

Do not split HLDs merely because the BRD has multiple requirements, child requirements, modules, pages, or data objects.

If the BRD appears to require multiple HLDs because it contains multiple independently shippable system capabilities, first re-check the BRD Scope Gate. The correct answer is often to split the BRD, not to create several HLDs under one broad BRD.

## HLD Content Rules

Fill the HLD from the BRD at system-design level:

- `BRD 范围判断`: state whether the BRD is a small request or single business closure, and why it is valid for HLD. This section is mandatory for generated HLDs.
- `覆盖范围`: explicitly list what this HLD covers and does not cover.
- `BRD 需求到设计决策映射`: map main requirements and child requirements to high-level design decisions. Do not mechanically create one section, module, or MLD per R item.
- `关键技术背景承接`: carry forward known technical facts from BRD, and distinguish fixed constraints from assumptions.
- `问题背景与约束`: derive from BRD context, constraints, risks, and consequences.
- `高层架构方案`: describe the system-level solution, selected architecture direction, major tradeoffs, and rejected alternatives. Avoid low-level code details, but be explicit about protocols, stores, jobs, events, external dependencies, and consistency boundaries when known.
- `组件关系`: use an ASCII diagram or concise text relationship map.
- `模块边界与依赖`: define module responsibilities, allowed calls, and forbidden dependencies.
- `核心数据模型与流转`: describe business objects, owners, key business fields, lifecycle, and data flow.
- `系统级横切关注点`: cover access control, logs, metrics, tracing, and error handling.
- `MLD 拆分建议`: recommend MLDs only when a responsibility has independent module-design value. Explain why. Also name responsibilities that should not be split yet when they are too small.
- `上线与迁移策略`: include only when the BRD implies existing-system replacement, phased rollout, or migration.
- `开放问题与待澄清点`: inherit unresolved BRD questions that still matter to HLD and add new design questions.

Do not write database schemas, API contracts, class design, implementation tasks, or test cases in HLD. Those belong to later MLD, LLD, and TCD stages.

An HLD is too shallow if it only restates BRD requirements and does not answer:

- What architecture direction is selected and why.
- Which technical facts are fixed constraints versus assumptions.
- Which components own data, state, external calls, and failure handling.
- What consistency, idempotency, security, and observability principles shape the design.
- What is intentionally left for MLD/LLD.

## Requirement Mapping Rules

Map BRD requirements to design decisions, not to files.

- Main `R-001` items usually become high-level capabilities, flows, or responsibility groups.
- Child `R-001a` items usually become design constraints, data requirements, exception handling, security boundaries, integration rules, or acceptance-impacting decisions.
- Do not generate one HLD section, module, or later MLD for every main R or child R.
- Group related R items into coherent design responsibilities.
- Preserve key technical content from child requirements when it affects acceptance, safety, consistency, compliance, or integration.

Example:

```text
R-002：识别充值并自动入账 GM 豆
R-002a：基于 USDT Transfer 事件
R-002b：使用 chain、tx_hash、log_index 幂等
```

Good HLD mapping:

- Chain event recognition and confirmation design.
- Idempotency boundary.
- Accounting handoff and status lifecycle.

Poor HLD mapping:

- Transfer event MLD.
- tx_hash MLD.
- log_index MLD.

## Module And MLD Guidance

Modules in HLD are internal design responsibilities. They are not automatic MLD files.

When writing `模块边界与依赖`:

- Show what each responsibility owns.
- Show what each responsibility explicitly does not own.
- Show dependencies and forbidden dependencies.
- Avoid turning the module table into a mandatory MLD generation list.

When writing `MLD 拆分建议`:

- Recommend an MLD only when it needs independent medium-level design because of complexity, data ownership, external dependencies, reliability risk, security concerns, or independent testability.
- Keep small supporting responsibilities inside the nearest larger MLD recommendation.
- Explain the split reason and covered HLD responsibilities.

## Filename And Slug Rules

Use ASCII-only slugs for generated HLD files and BRD design directories.

- If the source BRD filename contains Chinese or non-ASCII characters, derive an English kebab-case design directory slug from the BRD title and ID.
- Keep IDs such as `BRD-0001` and `HLD-0001`.
- Use Chinese only in document title/body, not in file or directory names.

Good:

```text
docs/design/BRD-0001-v2-forwarder-address-allocation/hld/HLD-0001-forwarder-address-allocation-overview.md
```

Bad:

```text
docs/design/BRD-0001-v2-用户充值地址分配与查询/hld/HLD-0001-v2-forwarder-address-allocation-overview.md
```

## Numbering And Paths

HLD numbering is scoped to one BRD design folder and increments inside that BRD's `hld/` directory:

```text
docs/design/BRD-0001-withdrawal-risk-control/hld/HLD-0001-risk-control-overview.md
docs/design/BRD-0001-withdrawal-risk-control/hld/HLD-0002-admin-review-overview.md
```

Another BRD may also start from `HLD-0001`.

Compute the next HLD ID by scanning existing files matching:

```text
HLD-[0-9][0-9][0-9][0-9]-*.md
```

Refuse to overwrite existing HLD files.

## Validation

After writing HLD files, run the repository's available validation command:

```bash
scripts/devflow design validate --target <target-repo>
```

If the validator currently checks only BRD structure, still run it and report that HLD validation is not yet automated.

Report:

- Source BRD path.
- Generated HLD file paths.
- Whether validation passed.
- Any open questions requiring review.

## Hard Stops

Do not:

- Modify the source BRD.
- Generate MLD, LLD, or TCD.
- Write implementation code.
- Commit or push generated files unless the user explicitly asks.
- Overwrite existing HLD files.
