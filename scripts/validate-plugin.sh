#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_paths=(
  ".codex-plugin/plugin.json"
  "skills/analyze-requirements/SKILL.md"
  "skills/write-spec/SKILL.md"
  "skills/write-plan/SKILL.md"
  "skills/implement-from-plan/SKILL.md"
  "skills/test-changes/SKILL.md"
  "skills/review-changes/SKILL.md"
  "skills/open-pr/SKILL.md"
  "templates/brd.md"
  "templates/hld.md"
  "templates/mld.md"
  "templates/lld.md"
  "templates/requirements.md"
  "templates/spec.md"
  "templates/implementation-plan.md"
  "templates/test-report.md"
  "templates/code-review.md"
  "templates/pr-description.md"
  "docs/harness-engineering.md"
  "docs/workflow.md"
  "docs/artifact-contracts.md"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$ROOT/$path" ]]; then
    echo "missing required file: $path" >&2
    exit 1
  fi
done

python3 -m json.tool "$ROOT/.codex-plugin/plugin.json" >/dev/null

echo "plugin scaffold ok"
