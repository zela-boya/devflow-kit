#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'USAGE'
devflow design <command>

Commands:
  gen-brd   Generate a BRD file in <target>/docs/brd.
  validate  Validate BRD document structure in <target>/docs/brd.

Examples:
  devflow design gen-brd --target /path/to/repo --title "Withdrawal Risk Control" \
    --context "..." --scope "..." --requirement "..."
  devflow design validate --target /path/to/repo
USAGE
}

die() {
  echo "$*" >&2
  exit 1
}

slugify() {
  local value="$1"
  value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  value="$(printf '%s' "$value" | sed -E 's/[[:space:]]+/-/g; s#[/\\:]+#-#g; s/[^[:alnum:]_.-]+/-/g; s/-+/-/g; s/^-//; s/-$//')"
  if [[ -z "$value" ]]; then
    value="summary"
  fi
  printf '%s' "$value"
}

next_brd_id() {
  local brd_dir="$1"
  local max=0
  local file base num value

  mkdir -p "$brd_dir"
  while IFS= read -r file; do
    base="$(basename "$file")"
    num="${base:4:4}"
    if [[ "$num" =~ ^[0-9]{4}$ ]]; then
      value=$((10#$num))
      if (( value > max )); then
        max="$value"
      fi
    fi
  done < <(find "$brd_dir" -maxdepth 1 -type f -name 'BRD-[0-9][0-9][0-9][0-9]-*.md' | sort)

  printf 'BRD-%04d' "$((max + 1))"
}

append_default_rows() {
  local kind="$1"
  case "$kind" in
    stakeholders)
      cat <<'EOF'
| 待确认 | 待确认 | 待确认 |
EOF
      ;;
    constraints)
      cat <<'EOF'
1. 暂无明确约束。
EOF
      ;;
    success)
      cat <<'EOF'
- SC-001：需求相关方确认 BRD 覆盖了当前业务目标和范围。
EOF
      ;;
    risks)
      cat <<'EOF'
| 暂无明确风险 | 低 | 待确认 | 持续跟进 |
EOF
      ;;
    questions)
      cat <<'EOF'
- OQ-001：相关方、约束、成功标准或风险是否需要进一步补充？
  - 答案：<待确认>
EOF
      ;;
  esac
}

cmd_gen_brd() {
  local target="."
  local title=""
  local context=""
  local scope=""
  local slug=""
  local owner=""
  local created_at=""
  local source=""
  local requirements=()
  local stakeholders=()
  local constraints=()
  local successes=()
  local risks=()
  local questions=()

  while (($#)); do
    case "$1" in
      --target)
        target="${2:-}"; shift 2 ;;
      --title)
        title="${2:-}"; shift 2 ;;
      --context)
        context="${2:-}"; shift 2 ;;
      --scope)
        scope="${2:-}"; shift 2 ;;
      --slug)
        slug="${2:-}"; shift 2 ;;
      --owner)
        owner="${2:-}"; shift 2 ;;
      --source)
        source="${2:-}"; shift 2 ;;
      --requirement)
        requirements+=("${2:-}"); shift 2 ;;
      --stakeholder)
        stakeholders+=("${2:-}"); shift 2 ;;
      --constraint)
        constraints+=("${2:-}"); shift 2 ;;
      --success)
        successes+=("${2:-}"); shift 2 ;;
      --risk)
        risks+=("${2:-}"); shift 2 ;;
      --open-question)
        questions+=("${2:-}"); shift 2 ;;
      -h|--help)
        usage; exit 0 ;;
      *)
        die "unknown gen-brd option: $1" ;;
    esac
  done

  [[ -n "$title" ]] || die "missing required option: --title"
  [[ -n "$context" ]] || die "missing required option: --context"
  [[ -n "$scope" ]] || die "missing required option: --scope"
  (( ${#requirements[@]} > 0 )) || die "missing required option: --requirement"

  if [[ -n "$source" && -f "$source" ]]; then
    context="$context"$'\n\n'"来源文档：$source"
  fi

  local brd_dir="$target/docs/brd"
  local id
  id="$(next_brd_id "$brd_dir")"
  if [[ -z "$slug" ]]; then
    slug="$(slugify "$title")"
  else
    slug="$(slugify "$slug")"
  fi

  local path="$brd_dir/$id-$slug.md"
  [[ ! -e "$path" ]] || die "refusing to overwrite existing BRD: $path"

  if [[ -z "$created_at" ]]; then
    created_at="$(date +%F)"
  fi
  if [[ -z "$owner" ]]; then
    owner="<负责人>"
  fi

  {
    cat <<EOF
---
id: $id
type: BRD
title: $title
status: draft
created_at: $created_at
updated_at: $created_at
owner: $owner
---

# $id $title

## 业务上下文

$context

## 相关方

| 相关方 | 角色/职责 | 关注点 |
| --- | --- | --- |
EOF

    if (( ${#stakeholders[@]} == 0 )); then
      append_default_rows stakeholders
    else
      local item party role focus
      for item in "${stakeholders[@]}"; do
        IFS='|' read -r party role focus <<<"$item"
        printf '| %s | %s | %s |\n' "${party:-待确认}" "${role:-待确认}" "${focus:-待确认}"
      done
    fi

    cat <<EOF

## 需求拆解

### 核心需求

EOF

    local idx=1
    local requirement
    for requirement in "${requirements[@]}"; do
      printf -- '- R-%03d：%s\n' "$idx" "$requirement"
      idx="$((idx + 1))"
    done

    cat <<EOF

## 约束

EOF

    if (( ${#constraints[@]} == 0 )); then
      append_default_rows constraints
    else
      idx=1
      local constraint
      for constraint in "${constraints[@]}"; do
        printf '%d. %s\n' "$idx" "$constraint"
        idx="$((idx + 1))"
      done
    fi

    cat <<EOF

## 成功标准

EOF

    if (( ${#successes[@]} == 0 )); then
      append_default_rows success
    else
      idx=1
      local success
      for success in "${successes[@]}"; do
        printf -- '- SC-%03d：%s\n' "$idx" "$success"
        idx="$((idx + 1))"
      done
    fi

    cat <<EOF

## 风险

| 风险 | 风险等级 | 影响 | 应对方式 |
| --- | --- | --- | --- |
EOF

    if (( ${#risks[@]} == 0 )); then
      append_default_rows risks
    else
      local risk level impact mitigation
      for item in "${risks[@]}"; do
        IFS='|' read -r risk level impact mitigation <<<"$item"
        printf '| %s | %s | %s | %s |\n' "${risk:-待确认}" "${level:-中}" "${impact:-待确认}" "${mitigation:-待确认}"
      done
    fi

    cat <<EOF

## 开放问题

EOF

    if (( ${#questions[@]} == 0 )); then
      append_default_rows questions
    else
      idx=1
      local question
      for question in "${questions[@]}"; do
        printf -- '- OQ-%03d：%s\n' "$idx" "$question"
        printf '  - 答案：<待确认>\n'
        idx="$((idx + 1))"
      done
    fi
  } > "$path"

  echo "$path"
}

validate_brd_file() {
  local file="$1"
  local base id
  base="$(basename "$file")"
  [[ "$base" =~ ^BRD-[0-9]{4}-.+\.md$ ]] || die "invalid BRD filename: $file"
  id="${base:0:8}"

  grep -q "^id: $id$" "$file" || die "metadata id does not match filename: $file"
  grep -q '^type: BRD$' "$file" || die "missing BRD type metadata: $file"

  local section
  for section in "业务上下文" "相关方" "需求拆解" "约束" "成功标准" "风险" "开放问题"; do
    grep -q "^## $section$" "$file" || die "missing required section '$section': $file"
  done

  grep -Eq '^- R-[0-9]{3}：.+' "$file" || die "missing R-xxx requirement item: $file"
  grep -Eq '^- SC-[0-9]{3}：.+' "$file" || die "missing SC-xxx success criterion: $file"
  grep -Eq '^- OQ-[0-9]{3}：.+' "$file" || die "missing OQ-xxx open question: $file"
}

cmd_validate() {
  local target="."
  while (($#)); do
    case "$1" in
      --target)
        target="${2:-}"; shift 2 ;;
      -h|--help)
        usage; exit 0 ;;
      *)
        die "unknown validate option: $1" ;;
    esac
  done

  local brd_dir="$target/docs/brd"
  [[ -d "$brd_dir" ]] || die "missing BRD directory: $brd_dir"

  local count=0
  local file
  while IFS= read -r file; do
    validate_brd_file "$file"
    count="$((count + 1))"
  done < <(find "$brd_dir" -maxdepth 1 -type f -name 'BRD-*.md' | sort)

  (( count > 0 )) || die "no BRD files found in: $brd_dir"
  echo "design docs ok"
}

case "${1:-}" in
  gen-brd)
    shift
    cmd_gen_brd "$@"
    ;;
  validate)
    shift
    cmd_validate "$@"
    ;;
  ""|-h|--help|help)
    usage
    ;;
  *)
    die "unknown design command: $1"
    ;;
esac
