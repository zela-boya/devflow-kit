---
name: dfd-gen-brd
description: Use when the user invokes dfd:brd to turn raw business input, a small resource/API request, or a source document into one or more BRD draft files under docs/brd.
---

# DFD Generate BRD

`dfd:brd` means Devflow Design: generate BRD.

Use this skill when the user types:

```text
dfd:brd <business text>
dfd:brd <path-to-source-document>
/dfd:brd <legacy business text>
/dfd:brd <legacy path-to-source-document>
```

## Goal

Analyze raw business input and generate one or more BRD draft files in the target repository under:

```text
docs/brd/
```

Use `templates/brd.md` as the document shape.

## Required Behavior

1. Parse the input after `dfd:brd` or legacy `/dfd:brd`.
2. If the input is a readable local file path, read the file and use its contents as the source.
3. Classify the source with semantic judgment. Do not ask the user to classify it:
   - Small request / single capability.
   - Single business closure.
   - Project-level source document containing multiple business closures.
4. If the input is a small request or one business closure and core information is sufficient, generate one BRD draft.
5. If the input is clearly project-level, do not generate one monolithic BRD. Use the business-closure decomposition workflow below.
6. If classification is genuinely ambiguous, ask one clarifying question before writing files.
7. Preserve concrete technical facts from the source in the BRD. Do not reduce the BRD to vague business-only statements when the source contains technical direction.
8. Generate ASCII-only filenames and design directory slugs. Chinese is allowed in titles and document body, not in file or directory names.
9. After writing BRD files, stop at a review gate. Do not generate HLD, MLD, LLD, TCD, code, commits, or PRs.

## Input Classification

Classify internally before writing files.

### Small Request / Single Capability

Use one BRD when the source describes one resource, one API capability, one lifecycle, or one compact system ability.

Typical signals:

- One core object or resource.
- One main caller or user group.
- One clear capability such as create/query/update/enable/disable/delete.
- Requirements can be accepted together.
- No multiple independent business journeys.

Examples:

- "生成一个 KYC 配置资源，并对外提供生命周期管理 API"
- "新增用户提现地址白名单管理能力"
- "为 Admin 增加归集批次重试入口"

For this path, generate one BRD directly. Prefer a business-capability title, such as `KYC 配置管理能力`, while keeping the resource/API lifecycle as the core deliverable.

### Single Business Closure

Use one BRD when the source describes one independently accepted business outcome, even if it includes multiple technical steps.

Typical signals:

- One primary business result.
- One start-to-finish user or operational journey.
- Requirements share the same success criteria and rollout boundary.
- Supporting technical details exist but serve the same closure.

Examples:

- "用户 USDT 充值自动入账"
- "用户提现提交到链上出金完成"
- "归集候选筛选到批次执行完成"

### Project-Level Source Document

Treat the source as project-level when it contains multiple independently accepted business closures.

Typical signals:

- Multiple business flows, such as recharge, withdrawal, sweep, approval, migration, admin operations, and app experience.
- Different stakeholders with different success criteria.
- Work that could be shipped or accepted independently.
- The source reads like a PRD, project charter, HLD, or full solution proposal.

Do not turn a project-level source directly into one broad BRD. A broad BRD causes the HLD to become a project overview and makes later MLDs mirror modules instead of business slices.

## Business-Closure Decomposition Workflow

When the source is clearly project-level:

1. State that the source is too broad for a single implementation BRD, using concrete evidence from the source.
2. Propose BRD splits by independently accepted business closures, not by technical modules or system components.
3. For each proposed BRD, include:
   - Business goal.
   - Acceptance boundary.
   - Why it can be reviewed, shipped, or implemented independently.
4. Offer 2-3 split strategies only when there are meaningful alternatives. Prefer business closure; mention phased rollout or owner/system boundary only as alternatives when useful.
5. Ask one clear brainstorming-style confirmation or adjustment question.
6. After the user confirms or adjusts the split, generate the BRD files in the same turn.

Do not ask the user to decide whether the source is project-level. Make that judgment yourself. Only ask the user to confirm or adjust the proposed BRD boundaries.

## Technical Context Preservation

BRD is not a purely non-technical business summary. It must preserve the technical facts needed for HLD to make correct architecture decisions.

When the source includes known technical direction, include it in the BRD as `关键技术背景` and/or R child requirements. Examples:

- Required architecture pattern, such as Forwarder + Factory, event-driven accounting, KMS signing, multisig approval, state machine, async worker, adapter, or resource lifecycle API.
- Key protocols, chains, platforms, stores, queues, services, or third-party dependencies.
- Required data objects and necessary data content, such as user_id, chain, tx_hash, log_index, amount, status, config_version, deploy_state.
- Key algorithms or strategies, such as CREATE2 address calculation, ownership recognition, idempotency key, confirmation-window handling, sweep candidate selection, withdrawal routing, retry/compensation strategy.
- Hard safety/security boundaries, such as no user private keys, KMS-only signing, multisig-only owner, no v1 data migration, no manual tx hash as primary flow.
- Known integration direction, such as APP calls backend API, Admin query is read-only, ledger is the accounting authority, chain RPC is an external dependency.

Do not invent low-level details that the source does not imply. If an important technical decision is missing, either ask one clarifying question when it changes the BRD boundary, or record it in `开放问题`.

The generated BRD should let a reviewer understand both:

- What business outcome is required.
- What technical facts and constraints are already known and must not be lost in HLD.

If the BRD has only broad R items and no meaningful technical background or child requirements while the source contains technical content, it is too shallow.

## Missing Information Strategy

Use a mixed conservative/draft strategy.

If core information is missing, ask a clarifying question before generating a BRD:

- Business context: why this is needed and what problem exists.
- At least one clear business requirement: what the business needs the system or process to support.
- Approximate business scope: what area or flow the BRD covers.

If non-core details are missing, generate a draft and put uncertainty into `开放问题`:

- Incomplete stakeholders.
- Incomplete constraints.
- Incomplete success criteria.
- Incomplete risks.
- Incomplete technical context.
- Imperfect requirement grouping.

Ask one clarifying question at a time.

## Split Rules

BRD boundaries must be based on independently accepted business outcomes, not technical modules.

Generate one BRD when the input is a small request or a single business closure. Do not over-split compact resource/API requests.

Use the business-closure decomposition workflow when the input contains:

- Multiple independent business goals.
- Multiple independent business flows.
- Different stakeholders and success criteria.
- Work that could be shipped or accepted independently.
- A full project solution where each major section can become its own accepted capability.

Avoid splitting by:

- Internal modules alone.
- Database ownership alone.
- UI pages alone.
- Team ownership alone.
- Existing source-document headings alone.

## Requirement Rules

`R` means Requirement: a business-reviewable system capability within the current BRD scope.

Use these rules when writing `需求拆解`:

- `R-001` is the main requirement. It states one core capability or business-observable outcome.
- `R-001a`, `R-001b`, `R-001c` are optional child requirements for critical rules, data content, technical constraints, exception behavior, security requirements, integration boundaries, compatibility requirements, or acceptance constraints.
- A BRD usually has 3-7 main requirements.
- A main requirement usually has 0-5 child requirements.
- Main requirements must stay inside the current BRD's business closure or small capability.
- If the source contains concrete technical direction, most main R items should have child requirements. Do not generate only broad main R items unless the input itself is minimal.
- Child requirements should answer "how this capability must behave or be constrained" at business/technical-contract level, not just repeat the main R.

R items may include key technical content when it affects acceptance, safety, consistency, compliance, or integration:

- Key data objects, such as recharge records, asset ledgers, sweep batches, withdrawal orders, audit logs.
- Required data content, such as chain, tx_hash, log_index, amount, user, status, error reason.
- Core mechanisms, such as idempotent accounting, confirmation checks, rollback handling, state-machine transitions.
- Core strategy names, such as address ownership recognition, sweep candidate selection, withdrawal routing, risk-rule evaluation.
- Task concepts, such as chain scanning, sweep scheduling, withdrawal confirmation.
- API capability boundaries, such as create, query, update, approve, retry, enable, disable, delete.
- Integration boundaries, such as chain RPC, KMS, Admin, APP, ledger, notification, or third-party service dependencies.

R items should not usually include complete low-level implementation detail:

- Full DDL.
- Full API field tables.
- Function signatures.
- Concrete class/package names.
- Directory paths.
- SQL statements.
- Locking, retry interval, concurrency, or index details unless they are direct acceptance, safety, or consistency constraints.

If a low-level detail is itself a business, security, compliance, or integration constraint, include it as a child requirement and explain why it is fixed.

Good examples:

```text
- R-001：系统必须为用户提供 ETH/TRX USDT 充值地址，用户可直接向该地址转账完成充值。
  - R-001a：充值地址必须采用 Forwarder 合约地址，系统不得生成、保存或导入用户私钥。
  - R-001b：地址必须能按用户和链唯一归属，避免同一链地址被多个用户共享。
- R-002：系统必须识别用户向充值地址转入的 USDT，并在链上确认后自动入账 GM 豆。
  - R-002a：充值识别必须基于 USDT Transfer 事件，不得依赖用户手动提交交易哈希作为主流程。
  - R-002b：系统必须使用 chain、tx_hash、log_index 作为幂等依据，避免重复扫描导致重复入账。
```

Poor examples:

```text
- R-001：实现 recharge_scanner worker。
- R-002：创建 deposit_records 表。
- R-003：新增 DepositScanner.scanBlockRange(ctx, from, to) 函数。
```

## Filename And Slug Rules

Generated file and directory names must be ASCII-only.

- Use lower-case kebab-case English slugs.
- Keep the numeric ID prefix, such as `BRD-0001-`.
- Do not put Chinese, spaces, punctuation-heavy text, emoji, or full-width characters in paths.
- Document titles and body may be Chinese.

Good:

```text
docs/brd/BRD-0001-v2-forwarder-address-allocation.md
docs/design/BRD-0001-v2-forwarder-address-allocation/hld/HLD-0001-forwarder-address-allocation-overview.md
```

Bad:

```text
docs/brd/BRD-0001-v2-用户充值地址分配与查询.md
docs/design/BRD-0001-v2-usdt-充值自动入账-gm-豆/
```

## Devflow Script Resolution

Do not assume the target repository contains `scripts/devflow`. In normal command usage, the current working directory is the target business repository, while the Devflow script lives in the installed plugin.

Resolve the Devflow script before generation. Use the first executable path that exists:

```bash
./scripts/devflow
$HOME/plugins/dfd/scripts/devflow
$HOME/.codex/plugins/cache/local-devflow/dfd/0.1.0/scripts/devflow
```

Use `./scripts/devflow` only when running inside this plugin repository. If no path exists, stop and report that Devflow Kit is not installed or the local plugin cache is missing, then ask the user to run this plugin's `install.sh`.

## Generation Command

Use the script for file creation:

```bash
"<devflow-script>" design gen-brd \
  --target <target-repo> \
  --title "<business summary>" \
  --context "<business context>" \
  --scope "<business scope>" \
  --requirement "<one sentence requirement>"
```

Use repeated options when applicable:

```bash
--requirement "<one sentence requirement>"
--stakeholder "<party>|<role/responsibility>|<concern>"
--constraint "<constraint>"
--success "<success criterion>"
--risk "<risk>|<high/medium/low>|<impact>|<mitigation>"
--open-question "<question>"
```

The script computes the next global BRD number by scanning `docs/brd/`.

## Validation

After generation, run:

```bash
"<devflow-script>" design validate --target <target-repo>
```

Report:

- Generated file paths.
- Whether validation passed.
- Any open questions that need user review.

## Hard Stops

Do not:

- Generate HLD, MLD, LLD, or TCD from this command.
- Write implementation code.
- Commit or push generated files unless the user explicitly asks.
- Overwrite an existing BRD file.
