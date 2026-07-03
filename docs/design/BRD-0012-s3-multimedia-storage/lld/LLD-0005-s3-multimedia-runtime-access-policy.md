---
id: LLD-0005
type: LLD
title: S3 multimedia runtime access policy
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

# LLD-0005 S3 multimedia runtime access policy

## PR 级范围

### 本 LLD 覆盖

- 在 `iac/terraform/s3-multimedia-storage/` 中新增业务运行时 IRSA 授权能力。
- 新增 `allowed_irsa_role_arns`、`allowed_prefixes`、`allowed_runtime_actions` 等变量契约。
- 当 role 列表为空时，不创建业务运行时访问授权。
- 当 role 列表非空时，为每个明确 IRSA role 生成限定 bucket/prefix/action 的最小权限 policy attachment。
- 输出非敏感运行时访问摘要，供验证脚本和接入审查使用。

### 本 LLD 不覆盖

- 不创建业务 Kubernetes ServiceAccount、Deployment、Helm values 或应用配置。
- 不设计业务上传 API、下载 API、签名 URL、CloudFront 或公开访问策略。
- 不创建 bucket 基础资源、安全基线、preflight 或 postcheck；这些由 `LLD-0001`、`LLD-0003`、`LLD-0004` 覆盖。
- 不实现运行时访问 contract check 脚本；由 `LLD-0006` 覆盖。

### PR-sized 判断

本 LLD 聚焦一个 Terraform root module 内的可选运行时授权子能力：变量、locals、IAM policy document、role policy attachment 和 outputs。它可以作为一个独立 PR 被 review 和回滚；若出现问题，可移除该授权文件和变量输出，不影响 bucket 基础资源定义。

## 来源映射

| 来源 | 覆盖内容 |
| --- | --- |
| MLD-0003 | IRSA role ARN、prefix、actions、默认不授权、非敏感访问摘要 |
| HLD-0001 | 业务运行时访问默认使用 EKS IRSA，部署角色与业务运行时角色分离 |
| BRD-0012 | R-001c、R-002c、R-002d、R-005a |

## 实现目标

该 PR 落地后，多媒体 S3 Terraform 模块在默认参数下不会授予任何业务运行时访问权限；只有调用方显式传入 IRSA role ARN 和 prefix 时，模块才会为这些 role 生成最小 S3 对象访问权限，并输出不含凭据的授权摘要。

## 变更范围

| 类型 | 名称/路径 | 说明 |
| --- | --- | --- |
| Terraform | `iac/terraform/s3-multimedia-storage/variables.tf` | 新增运行时授权变量和校验 |
| Terraform | `iac/terraform/s3-multimedia-storage/locals.tf` | 归一化 role、prefix、actions 和授权摘要 |
| Terraform | `iac/terraform/s3-multimedia-storage/runtime-access.tf` | 新增 IAM policy document 与 role attachment |
| Terraform | `iac/terraform/s3-multimedia-storage/outputs.tf` | 新增非敏感运行时访问 output |
| Docs | `iac/terraform/s3-multimedia-storage/README.md` | 记录 IRSA 授权参数、默认不授权和接入示例 |

## 代码库落点

| 落点 | 类型 | 当前状态 | 本 LLD 中的处理 |
| --- | --- | --- | --- |
| `iac/terraform/s3-multimedia-storage/` | Terraform root module | 由 `LLD-0001` 新增 | 追加运行时授权子能力 |
| `variables.tf` | Terraform variables | 后续存在 | 增加 role、prefix、actions 变量 |
| `locals.tf` | Terraform locals | 后续存在 | 增加归一化和摘要 locals |
| `runtime-access.tf` | Terraform IAM resources | 需新增 | 管理运行时 role policy attachment |
| `outputs.tf` | Terraform outputs | 后续存在 | 增加 runtime access summary |

## 设计细节

### Terraform 变量契约

| 变量 | 类型/默认值 | 说明 | 校验 |
| --- | --- | --- | --- |
| `allowed_irsa_role_arns` | `list(string)` / `[]` | 允许访问多媒体 bucket 的业务 IRSA role ARN | 每项必须是 IAM role ARN；空列表表示不授权 |
| `allowed_prefixes` | `list(string)` / `["uploads/"]` | 允许业务对象访问的 prefix | 不允许空字符串；必须以 `/` 结尾或归一化为目录边界 |
| `allowed_runtime_actions` | `list(string)` / 最小读写集合 | 运行时 S3 action | 不允许 bucket policy、ACL、公共访问配置或管理类 action |
| `allow_full_bucket_runtime_access` | `bool` / `false` | 是否允许全 bucket 对象访问 | 默认 false；true 时必须显式记录风险 |

默认 action 集合：

```text
s3:GetObject
s3:PutObject
s3:DeleteObject
s3:ListBucket
```

其中 `ListBucket` 必须配合 prefix 条件，object action 必须限定到 `arn:aws:s3:::<bucket>/<prefix>*`。

### Prefix 归一化

`allowed_prefixes` 中每个 prefix 应归一化为对象路径边界：

- 拒绝空字符串。
- 拒绝包含 `..` 的路径。
- 建议以 `/` 结尾；实现可将 `uploads` 归一化为 `uploads/`。
- 默认值为 `uploads/`，但调用方可覆盖。

当 `allow_full_bucket_runtime_access=false` 时，不允许通过空 prefix 表示全 bucket。

### Role ARN 校验

每个 role ARN 必须符合：

```text
arn:aws:iam::<account-id>:role/<role-name>
```

不得接受 user ARN、group ARN、policy ARN 或空字符串。Terraform 变量校验无法确认 role 是否真实存在，但必须在格式层面阻止错误主体。

### IAM policy document

`runtime-access.tf` 使用 `aws_iam_policy_document` 构造每个 role 的最小权限：

```hcl
data "aws_iam_policy_document" "runtime_access" {
  for_each = local.runtime_access_grants

  statement {
    sid     = "ListAllowedPrefixes"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.multimedia.arn
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = each.value.prefixes
    }
  }

  statement {
    sid     = "ObjectAccess"
    effect  = "Allow"
    actions = local.runtime_object_actions
    resources = each.value.object_resource_arns
  }
}
```

实现时可按 role 拆分 policy，也可生成单独 inline policy attachment；但必须保证每个 role 的 resources 和 prefix 边界明确可审计。

### Role policy attachment

推荐使用 role inline policy：

```hcl
resource "aws_iam_role_policy" "runtime_access" {
  for_each = data.aws_iam_policy_document.runtime_access

  name   = "s3-multimedia-runtime-access"
  role   = local.runtime_access_role_names[each.key]
  policy = each.value.json
}
```

如果 role ARN 只在运行时可知，locals 需从 ARN 中解析 role name。解析失败必须由变量校验或 contract check 捕获。

### 空授权行为

当 `allowed_irsa_role_arns = []` 时：

- 不创建 `aws_iam_role_policy.runtime_access`。
- 不生成任何业务运行时读写授权。
- output `runtime_access_enabled=false`。
- output `runtime_access_grant_count=0`。
- README 明确说明 bucket 已创建但业务运行时尚无访问权限。

### Runtime access outputs

新增 outputs：

| Output | 内容 | 敏感性 |
| --- | --- | --- |
| `runtime_access_enabled` | role 列表是否非空 | 非敏感 |
| `runtime_access_grant_count` | 授权 role 数量 | 非敏感 |
| `runtime_access_summary` | role ARN 摘要、prefix、actions | 非敏感 |
| `runtime_access_prefixes` | 归一化 prefix 列表 | 非敏感 |
| `runtime_access_actions` | 最终 action 列表 | 非敏感 |

不得输出 access key、secret key、session token、Pod token 或临时凭据。

## 数据与状态变更

| 对象 | 变更内容 | 约束 |
| --- | --- | --- |
| Terraform variables | 新增运行时授权输入 | 默认空 role 不授权 |
| Terraform locals | 新增 role/prefix/action 归一化 | 不得用空 prefix 隐式全 bucket |
| IAM role policy | 可选创建 inline policy | 只绑定明确 role，禁止公开主体 |
| Outputs | 新增非敏感授权摘要 | 不输出任何凭据 |

状态流转：

```text
no-grants -> grants-planned -> grants-applied
          -> grant-invalid
```

## 错误处理与断言

| 断言 | 守护条件 | 失败处理 |
| --- | --- | --- |
| ASSERT-001 | runtime 主体必须是 IAM role ARN | 变量校验或 contract check 失败 |
| ASSERT-002 | prefix 不得为空字符串或包含 `..` | 变量校验失败 |
| ASSERT-003 | actions 不得包含 S3 管理类权限 | 变量校验或 contract check 失败 |
| ASSERT-004 | 不得授权 Principal `*` | contract/postcheck 失败 |
| ASSERT-005 | 不得输出长期密钥或 token | contract check 失败 |

禁止的 action 示例：

```text
s3:PutBucketPolicy
s3:DeleteBucketPolicy
s3:PutBucketAcl
s3:PutBucketPublicAccessBlock
s3:DeleteBucket
s3:*
```

## 测试范围

| 测试 | 命令/方式 | 验证内容 |
| --- | --- | --- |
| Terraform fmt | `terraform fmt -check` | Terraform 文件格式 |
| Terraform validate | `terraform validate` | 变量和资源语法 |
| 静态 contract check | `bash scripts/check-terraform-s3-runtime-access-contract.sh` | role/prefix/action/output 契约 |
| 空 role 场景 | plan 或静态检查 | 不创建 runtime policy |
| 非空 role 场景 | plan 或静态检查 | 创建限定 prefix/action 的 role policy |

## 可观测性

| 指标/摘要 | 含义 | 来源 |
| --- | --- | --- |
| `runtime_access_grant_count` | 授权 role 数量 | Terraform output |
| `runtime_access_prefixes` | 授权 prefix 列表 | Terraform output |
| `runtime_access_actions` | 授权 action 列表 | Terraform output |

## 依赖与交付顺序

- 依赖 `LLD-0001` 提供 `aws_s3_bucket.multimedia`、bucket ARN 和基础 outputs。
- 建议在 `LLD-0006` 前实现，因为 contract check 需要检查本 LLD 的变量、policy 和 outputs。
- 不依赖真实业务 ServiceAccount；首版通过参数化 role ARN 支持后续业务接入。

## 开放问题与待澄清点

- OQ-001：首个业务服务的真实 IRSA role ARN 尚未确定。
  - 处理：不阻塞本 LLD。首版以参数化变量支持，默认不创建业务授权。
- OQ-002：是否允许全 bucket 对象访问。
  - 处理：默认不允许。若后续业务需要，必须显式设置 `allow_full_bucket_runtime_access=true` 并在审查中记录风险。
