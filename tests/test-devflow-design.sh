#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

target="$TMPDIR/target-repo"
mkdir -p "$target"

"$ROOT/scripts/devflow" design gen-brd \
  --target "$target" \
  --title "Withdrawal Risk Control" \
  --context "提现审核缺少风险判断上下文，运营人员受影响，可能导致高风险订单被误放行。" \
  --scope "覆盖提现审核前的风险判断展示，不覆盖风险模型训练。" \
  --requirement "运营人员需要在审核提现订单时看到该订单的风险判断结果。"

brd="$target/docs/brd/BRD-0001-withdrawal-risk-control.md"

if [[ ! -f "$brd" ]]; then
  echo "expected BRD file not found: $brd" >&2
  exit 1
fi

grep -q "id: BRD-0001" "$brd"
grep -q "title: Withdrawal Risk Control" "$brd"
grep -q "## 业务上下文" "$brd"
grep -q "R-001：运营人员需要在审核提现订单时看到该订单的风险判断结果。" "$brd"

"$ROOT/scripts/devflow" design validate --target "$target"
