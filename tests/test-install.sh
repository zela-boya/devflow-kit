#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/home/.agents/plugins"
mkdir -p "$TMPDIR/home/.codex/commands"
mkdir -p "$TMPDIR/home/.codex/.tmp/plugins/.agents/plugins"
mkdir -p "$TMPDIR/home/.codex/plugins/cache/local-devflow/dfd"
for legacy_command in \
  "dfd:gen-brd.md" \
  "dfd:gen-hld.md" \
  "dfd:gen-mld.md" \
  "dfd:gen-lld.md" \
  "dfd:gen-design-tree.md" \
  "dfd:implement-lld.md" \
  "dfd:implement-lld-folder.md"; do
  touch "$TMPDIR/home/.codex/commands/$legacy_command"
done
cat > "$TMPDIR/home/.agents/plugins/marketplace.json" <<'JSON'
{
  "name": "local-devflow",
  "interface": {
    "displayName": "Local Devflow"
  },
  "plugins": [
    {
      "name": "devflow-kit",
      "source": {
        "source": "local",
        "path": "./plugins/devflow-kit"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity"
    }
  ]
}
JSON
cat > "$TMPDIR/home/.codex/.tmp/plugins/.agents/plugins/marketplace.json" <<'JSON'
{
  "name": "openai-curated",
  "interface": {
    "displayName": "Codex official"
  },
  "plugins": []
}
JSON

HOME="$TMPDIR/home" DEVFLOW_SKIP_CODEX_MARKETPLACE_ADD=1 "$ROOT/install.sh"

plugin_path="$TMPDIR/home/plugins/devflow-kit"
dfd_plugin_path="$TMPDIR/home/plugins/dfd"
marketplace="$TMPDIR/home/.agents/plugins/marketplace.json"
synced_marketplace="$TMPDIR/home/.codex/.tmp/plugins/.agents/plugins/marketplace.json"
codex_config="$TMPDIR/home/.codex/config.toml"
codex_command="$TMPDIR/home/.codex/commands/dfd:brd.md"
codex_hld_command="$TMPDIR/home/.codex/commands/dfd:hld.md"
codex_mld_command="$TMPDIR/home/.codex/commands/dfd:mld.md"
codex_lld_command="$TMPDIR/home/.codex/commands/dfd:lld.md"
codex_design_tree_command="$TMPDIR/home/.codex/commands/dfd:design-tree.md"
codex_implement_lld_command="$TMPDIR/home/.codex/commands/dfi:lld.md"
codex_implement_lld_folder_command="$TMPDIR/home/.codex/commands/dfi:lld-folder.md"
legacy_codex_commands=(
  "$TMPDIR/home/.codex/commands/dfd:gen-brd.md"
  "$TMPDIR/home/.codex/commands/dfd:gen-hld.md"
  "$TMPDIR/home/.codex/commands/dfd:gen-mld.md"
  "$TMPDIR/home/.codex/commands/dfd:gen-lld.md"
  "$TMPDIR/home/.codex/commands/dfd:gen-design-tree.md"
  "$TMPDIR/home/.codex/commands/dfd:implement-lld.md"
  "$TMPDIR/home/.codex/commands/dfd:implement-lld-folder.md"
)
codex_cache_hld_skill="$TMPDIR/home/.codex/plugins/cache/local-devflow/dfd/0.1.0/skills/gen-hld/SKILL.md"
codex_cache_mld_skill="$TMPDIR/home/.codex/plugins/cache/local-devflow/dfd/0.1.0/skills/gen-mld/SKILL.md"
codex_cache_lld_skill="$TMPDIR/home/.codex/plugins/cache/local-devflow/dfd/0.1.0/skills/gen-lld/SKILL.md"

if [[ ! -d "$dfd_plugin_path" ]]; then
  echo "expected plugin directory not found: $dfd_plugin_path" >&2
  exit 1
fi

if [[ -L "$dfd_plugin_path" ]]; then
  echo "plugin install path should be a physical directory, not a symlink: $dfd_plugin_path" >&2
  exit 1
fi

if [[ ! -f "$dfd_plugin_path/.codex-plugin/plugin.json" ]]; then
  echo "installed plugin manifest missing" >&2
  exit 1
fi

if [[ ! -f "$dfd_plugin_path/commands/brd.md" ]]; then
  echo "installed slash command missing" >&2
  exit 1
fi

if [[ ! -f "$codex_command" ]]; then
  echo "local Codex slash command shim missing: $codex_command" >&2
  exit 1
fi

if [[ ! -f "$codex_design_tree_command" ]]; then
  echo "local Codex design-tree slash command shim missing: $codex_design_tree_command" >&2
  exit 1
fi

if [[ ! -f "$codex_hld_command" ]]; then
  echo "local Codex HLD slash command shim missing: $codex_hld_command" >&2
  exit 1
fi

if [[ ! -f "$codex_mld_command" ]]; then
  echo "local Codex MLD slash command shim missing: $codex_mld_command" >&2
  exit 1
fi

if [[ ! -f "$codex_lld_command" ]]; then
  echo "local Codex LLD slash command shim missing: $codex_lld_command" >&2
  exit 1
fi

if [[ ! -f "$codex_implement_lld_command" ]]; then
  echo "local Codex implement-lld slash command shim missing: $codex_implement_lld_command" >&2
  exit 1
fi

if [[ ! -f "$codex_implement_lld_folder_command" ]]; then
  echo "local Codex implement-lld-folder slash command shim missing: $codex_implement_lld_folder_command" >&2
  exit 1
fi

if [[ ! -f "$codex_cache_hld_skill" ]]; then
  echo "Codex plugin cache skill missing: $codex_cache_hld_skill" >&2
  exit 1
fi

if [[ ! -f "$codex_cache_mld_skill" ]]; then
  echo "Codex plugin cache skill missing: $codex_cache_mld_skill" >&2
  exit 1
fi

if [[ ! -f "$codex_cache_lld_skill" ]]; then
  echo "Codex plugin cache skill missing: $codex_cache_lld_skill" >&2
  exit 1
fi

if ! cmp -s "$ROOT/commands/brd.md" "$codex_command"; then
  echo "local Codex slash command shim differs from source command" >&2
  exit 1
fi

if ! cmp -s "$ROOT/commands/hld.md" "$codex_hld_command"; then
  echo "local Codex HLD slash command shim differs from source command" >&2
  exit 1
fi

if ! cmp -s "$ROOT/commands/mld.md" "$codex_mld_command"; then
  echo "local Codex MLD slash command shim differs from source command" >&2
  exit 1
fi

if ! cmp -s "$ROOT/commands/lld.md" "$codex_lld_command"; then
  echo "local Codex LLD slash command shim differs from source command" >&2
  exit 1
fi

if ! cmp -s "$ROOT/commands/design-tree.md" "$codex_design_tree_command"; then
  echo "local Codex design-tree slash command shim differs from source command" >&2
  exit 1
fi

if ! cmp -s "$ROOT/commands/implementation-lld.md" "$codex_implement_lld_command"; then
  echo "local Codex implement-lld slash command shim differs from source command" >&2
  exit 1
fi

if ! cmp -s "$ROOT/commands/implementation-lld-folder.md" "$codex_implement_lld_folder_command"; then
  echo "local Codex implement-lld-folder slash command shim differs from source command" >&2
  exit 1
fi

for legacy_command in "${legacy_codex_commands[@]}"; do
  if [[ -e "$legacy_command" ]]; then
    echo "legacy local Codex slash command shim should have been removed: $legacy_command" >&2
    exit 1
  fi
done

if [[ -e "$TMPDIR/home/.codex/.tmp/plugins/plugins/dfd" ]]; then
  echo "dfd should not be injected into the openai-curated sync tree" >&2
  exit 1
fi

if [[ -e "$plugin_path" || -L "$plugin_path" ]]; then
  echo "legacy plugin path should have been removed: $plugin_path" >&2
  exit 1
fi

python3 - "$marketplace" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

plugins = data.get("plugins", [])
matches = [p for p in plugins if p.get("name") == "dfd"]
assert len(matches) == 1, matches
legacy = [p for p in plugins if p.get("name") == "devflow-kit"]
assert legacy == [], legacy
entry = matches[0]
assert entry["source"] == {"source": "local", "path": "./plugins/dfd"}, entry
assert entry["policy"] == {"installation": "AVAILABLE", "authentication": "ON_INSTALL"}, entry
assert entry["category"] == "Productivity", entry
PY

python3 - "$synced_marketplace" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

plugins = data.get("plugins", [])
matches = [p for p in plugins if p.get("name") == "dfd"]
assert matches == [], matches
PY

grep -q '^\[plugins."dfd@local-devflow"\]$' "$codex_config"
if grep -q '^\[plugins."dfd@openai-curated"\]$' "$codex_config"; then
  echo "dfd should not be enabled from openai-curated" >&2
  exit 1
fi
grep -q '^enabled = true$' "$codex_config"
