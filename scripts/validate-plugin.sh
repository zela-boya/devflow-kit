#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_paths=(
  ".codex-plugin/plugin.json"
  "install.sh"
  "commands/brd.md"
  "commands/hld.md"
  "commands/mld.md"
  "commands/lld.md"
  "commands/design-tree.md"
  "commands/implementation-lld.md"
  "commands/implementation-lld-folder.md"
  "skills/analyze-requirements/SKILL.md"
  "skills/write-spec/SKILL.md"
  "skills/write-plan/SKILL.md"
  "skills/implement-from-plan/SKILL.md"
  "skills/test-changes/SKILL.md"
  "skills/review-changes/SKILL.md"
  "skills/open-pr/SKILL.md"
  "skills/dfd-gen-brd/SKILL.md"
  "skills/gen-hld/SKILL.md"
  "skills/gen-mld/SKILL.md"
  "skills/gen-lld/SKILL.md"
  "skills/implement-lld/SKILL.md"
  "skills/implement-lld-folder/SKILL.md"
  "skills/gen-design-tree/SKILL.md"
  "scripts/devflow-design.sh"
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
