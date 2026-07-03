---
id: LLD-0006
type: LLD
title: S3 multimedia runtime access contract checks
status: draft
created_at: 2026-05-27
updated_at: 2026-05-27
owner: TBD
brd:
  id: BRD-0012
  path: ../../../brd/BRD-0012-s3-multimedia-storage.md
  title: S3 多媒体文件存储部署能力
parent:
  id: MLD-0003
  path: ../mld/MLD-0003-s3-multimedia-runtime-access-module.md
  title: 业务运行时访问授权模块中层设计
---

# LLD-0006 S3 multimedia runtime access contract checks

## PR 级范围

### 本 LLD 覆盖

- 新增运行时访问授权的静态 contract check 脚本。
- 验证 Terraform 模块支持 IRSA role ARN、prefix、runtime actions 和默认不授权行为。
- 验证 runtime policy 不包含公开主体、S3 管理权限、长期密钥变量或敏感 output。
- 验证 README 或模块说明记录默认不授权和参数化接入方式。

### 本 LLD 不覆盖

- 不创建或修改 IAM policy 资源；由 `LLD-0005` 覆盖。
- 不调用真实 AWS IAM 或 S3 API。
- 不创建业务 ServiceAccount、应用配置、上传 API、签名 URL 或 CloudFront。
- 不执行真实 `terraform apply`。

### PR-sized 判断

本 LLD 是一个只读静态检查 PR，范围集中在脚本和契约验证。它可以独立运行、独立 review，不需要云端凭据；失败时只说明 Terraform 模块运行时授权不符合设计契约。

## 来源映射

| 来源 | 覆盖内容 |
| --- | --- |
| MLD-0003 | runtime access contract check、禁止公开 Principal、禁止管理权限、禁止长期密钥输出 |
| HLD-0001 | IRSA 最小权限、默认私有、部署角色与运行时角色分离 |
| BRD-0012 | R-002c、R-002d、R-005a、R-005b、R-005c |

## 实现目标

该 PR 落地后，仓库存在一个可本地和 CI 执行的静态检查脚本，用于验证多媒体 S3 Terraform 模块的业务运行时授权能力没有引入公开访问、长期凭据、过宽 S3 管理权限或敏感 output。

## 变更范围

| 类型 | 名称/路径 | 说明 |
| --- | --- | --- |
| Script | `scripts/check-terraform-s3-runtime-access-contract.sh` | 新增运行时授权静态 contract check |
| Docs | `iac/terraform/s3-multimedia-storage/README.md` | 记录检查命令和默认不授权行为 |
| Optional wiring | `scripts/check-structure.sh` | 如仓库模式要求，可串联该检查 |

## 代码库落点

| 落点 | 类型 | 当前状态 | 本 LLD 中的处理 |
| --- | --- | --- | --- |
| `scripts/check-terraform-s3-runtime-access-contract.sh` | shell script | 需新增 | 新增只读静态检查 |
| `iac/terraform/s3-multimedia-storage/` | Terraform root module | 由前序 LLD 建立 | 作为检查目标 |
| `scripts/check-structure.sh` | shell script | 已存在 | 可选接入，按仓库现有模式判断 |

## 设计细节

### Worker / Job Detail

| 项 | 说明 |
| --- | --- |
| 触发方式 | 人工执行、CI 或结构检查脚本调用 |
| 输入 | 仓库根目录，默认检查 `iac/terraform/s3-multimedia-storage/` |
| 输出 | stdout 中的通过/失败信息，退出码 0/非 0 |
| 幂等 | 只读文件检查，可重复执行 |
| 重试/补偿 | 失败后修复 Terraform 文件或脚本规则再重跑 |

### Script contract

脚本应支持在仓库根目录执行：

```bash
bash scripts/check-terraform-s3-runtime-access-contract.sh
```

脚本使用 `set -euo pipefail`，只做本地文件检查，不访问 AWS、Kubernetes 或 Terraform backend。

### Required files

检查以下文件存在：

```text
iac/terraform/s3-multimedia-storage/variables.tf
iac/terraform/s3-multimedia-storage/locals.tf
iac/terraform/s3-multimedia-storage/runtime-access.tf
iac/terraform/s3-multimedia-storage/outputs.tf
iac/terraform/s3-multimedia-storage/README.md
```

### Required variables

检查 `variables.tf` 中存在：

```text
allowed_irsa_role_arns
allowed_prefixes
allowed_runtime_actions
allow_full_bucket_runtime_access
```

检查关键默认值：

| 变量 | 默认值 |
| --- | --- |
| `allowed_irsa_role_arns` | `[]` |
| `allowed_prefixes` | `["uploads/"]` |
| `allow_full_bucket_runtime_access` | `false` |

### Required policy resources

检查 `runtime-access.tf` 中存在：

| 内容 | 期望 |
| --- | --- |
| `aws_iam_policy_document` | 用于构造 runtime access policy |
| `aws_iam_role_policy` 或等价 role attachment | 用于绑定明确 IRSA role |
| `s3:ListBucket` | 允许按 prefix list |
| `s3:GetObject` | 默认对象读权限 |
| `s3:PutObject` | 默认对象写权限 |
| `s3:DeleteObject` | 默认对象删除权限 |
| `s3:prefix` | ListBucket prefix 条件 |
| `aws_s3_bucket.multimedia.arn` | bucket ARN 来源 |

### Forbidden scope checks

脚本必须拒绝以下内容：

| 禁止项 | 检查方式 |
| --- | --- |
| 公开主体 | 不允许 `Principal = "*"`、`principals { identifiers = ["*"] }` 或等价公开片段 |
| S3 管理权限 | 不允许 `s3:*`、`s3:PutBucketPolicy`、`s3:DeleteBucketPolicy`、`s3:PutBucketAcl`、`s3:PutBucketPublicAccessBlock` |
| 长期密钥变量 | 不允许变量名包含 `access_key`、`secret_key`、`session_token` |
| 敏感 output | 不允许 output 名称包含 `access_key`、`secret_key`、`session_token`、`credential`、`token` |
| CloudFront/公开访问 | 不允许 runtime access 文件中出现 `aws_cloudfront_distribution`、`public-read`、`public-read-write` |
| 全 bucket 默认授权 | 不允许空 prefix 作为默认值，除非显式 `allow_full_bucket_runtime_access=true` 且有风险说明 |

### Required outputs

检查 `outputs.tf` 中存在：

```text
runtime_access_enabled
runtime_access_grant_count
runtime_access_summary
runtime_access_prefixes
runtime_access_actions
```

这些 output 不得标记为 `sensitive = false` 且包含凭据字段；原则上它们只输出 role/prefix/action 摘要。

### README contract

README 必须记录：

- 默认 `allowed_irsa_role_arns=[]` 时不创建业务运行时授权。
- 业务服务通过 EKS IRSA role ARN 接入。
- 默认 prefix 建议为 `uploads/`。
- 本模块不创建 access key、Kubernetes Secret、业务 ServiceAccount 或应用配置。
- 公开访问、CloudFront、签名 URL 不在首版范围内。

## 数据与状态变更

| 类型 | 对象 | 变更内容 | 回滚/兼容 |
| --- | --- | --- | --- |
| 新脚本 | `scripts/check-terraform-s3-runtime-access-contract.sh` | 新增只读静态检查 | 删除脚本即可回滚 |
| 可选结构检查接入 | `scripts/check-structure.sh` | 串联新检查 | 若误报，可先单独运行脚本再决定是否接入 |

状态流转：

```text
not-run -> checking -> passed
                  -> failed
```

## 错误处理与断言

| 错误 | 触发条件 | 输出示例 |
| --- | --- | --- |
| 缺少变量 | 未定义 required variable | `missing runtime access variable: allowed_irsa_role_arns` |
| 缺少 policy | 未定义 policy document 或 attachment | `missing runtime access policy document` |
| 公开主体 | 出现 Principal `*` | `forbidden runtime access principal: *` |
| 过宽 action | 出现 S3 管理权限或 `s3:*` | `forbidden runtime action: s3:*` |
| 敏感 output | output 暴露 token/credential | `forbidden sensitive runtime access output` |

成功输出：

```text
s3 multimedia runtime access contract check passed
```

## 测试范围

| 测试 | 命令/方式 | 验证内容 |
| --- | --- | --- |
| 脚本语法 | `bash -n scripts/check-terraform-s3-runtime-access-contract.sh` | shell 语法 |
| 静态 contract | `bash scripts/check-terraform-s3-runtime-access-contract.sh` | runtime access 变量、policy、outputs、禁止项 |
| 结构检查接入 | `bash scripts/check-structure.sh` | 若接入，确认整体结构检查通过 |

## 可观测性

| 日志/输出 | 含义 |
| --- | --- |
| `missing runtime access variable` | 缺少必要变量 |
| `forbidden runtime action` | 运行时权限过宽 |
| `forbidden sensitive runtime access output` | output 可能泄露凭据 |
| `s3 multimedia runtime access contract check passed` | 所有静态契约通过 |

## 依赖与交付顺序

- 依赖 `LLD-0005` 定义 runtime access variables、policy 和 outputs。
- 可在 `LLD-0005` 同 PR 后续追加，或作为独立 PR 紧随其后实现。
- 不依赖 AWS 凭据、Terraform init 或真实业务 ServiceAccount。

## 开放问题与待澄清点

- OQ-001：是否将该检查纳入 `scripts/check-structure.sh`。
  - 处理：实现时按仓库既有模式判断；即使不接入，也必须支持单独执行。
