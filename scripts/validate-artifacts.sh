#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACT_DIR="${DEVFLOW_ARTIFACT_DIR:-$ROOT/docs/devflow}"

required_artifacts=(
  "requirements.md"
  "spec.md"
  "implementation-plan.md"
  "test-report.md"
  "code-review.md"
)

for artifact in "${required_artifacts[@]}"; do
  if [[ ! -s "$ARTIFACT_DIR/$artifact" ]]; then
    echo "missing or empty artifact: $ARTIFACT_DIR/$artifact" >&2
    exit 1
  fi
done

echo "workflow artifacts ok"
