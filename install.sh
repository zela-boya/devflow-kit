#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="dfd"
LEGACY_PLUGIN_NAME="devflow-kit"
MARKETPLACE_NAME="${DEVFLOW_MARKETPLACE_NAME:-dfd}"
HOME_DIR="${HOME:?HOME is required}"
PLUGIN_PARENT="${DEVFLOW_PLUGIN_PARENT:-$HOME_DIR/plugins}"
PLUGIN_PATH="$PLUGIN_PARENT/$PLUGIN_NAME"
MARKETPLACE_PATH="${DEVFLOW_MARKETPLACE_PATH:-$HOME_DIR/.agents/plugins/marketplace.json}"
CODEX_CONFIG_PATH="${DEVFLOW_CODEX_CONFIG_PATH:-$HOME_DIR/.codex/config.toml}"
CODEX_TMP_MARKETPLACE_ROOT="${DEVFLOW_CODEX_TMP_MARKETPLACE_ROOT:-$HOME_DIR/.codex/.tmp/plugins}"
CODEX_COMMANDS_DIR="${DEVFLOW_CODEX_COMMANDS_DIR:-$HOME_DIR/.codex/commands}"
CODEX_PLUGIN_CACHE_PATH="${DEVFLOW_CODEX_PLUGIN_CACHE_PATH:-$HOME_DIR/.codex/plugins/cache/local-devflow/$PLUGIN_NAME/0.1.0}"

usage() {
  cat <<'USAGE'
install.sh [--force]

Installs the current Devflow Kit plugin for future Codex CLI sessions by:
  1. Copying this repository to ~/plugins/dfd.
  2. Adding the dfd plugin entry to ~/.agents/plugins/marketplace.json.

Environment overrides:
  DEVFLOW_PLUGIN_PARENT     Parent directory for installed plugins.
  DEVFLOW_MARKETPLACE_PATH  Marketplace JSON path.
  DEVFLOW_MARKETPLACE_NAME  Marketplace name, default: dfd.
  DEVFLOW_CODEX_CONFIG_PATH Codex config path.
  DEVFLOW_CODEX_COMMANDS_DIR
                            Codex local slash command directory.
  DEVFLOW_CODEX_PLUGIN_CACHE_PATH
                            Codex local plugin cache path to refresh when present.
  DEVFLOW_CODEX_TMP_MARKETPLACE_ROOT
                            Codex synced marketplace root to clean stale entries from when present.
  DEVFLOW_SKIP_CODEX_MARKETPLACE_ADD
                            Set to 1 to skip `codex plugin marketplace add`.

Options:
  --force  Replace an existing plugin install path.
USAGE
}

force=false
while (($#)); do
  case "$1" in
    --force)
      force=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! -f "$ROOT/.codex-plugin/plugin.json" ]]; then
  echo "missing plugin manifest: $ROOT/.codex-plugin/plugin.json" >&2
  exit 1
fi

mkdir -p "$PLUGIN_PARENT"
mkdir -p "$(dirname "$MARKETPLACE_PATH")"

if [[ -e "$PLUGIN_PATH" || -L "$PLUGIN_PATH" ]]; then
  if [[ "$force" == true ]]; then
    rm -rf "$PLUGIN_PATH"
  else
    echo "plugin path already exists: $PLUGIN_PATH" >&2
    echo "rerun with --force to replace it" >&2
    exit 1
  fi
fi

mkdir -p "$PLUGIN_PATH"
rsync -a \
  --exclude '.git' \
  --exclude '.idea' \
  --exclude '.DS_Store' \
  "$ROOT/" "$PLUGIN_PATH/"

if [[ -d "$(dirname "$CODEX_PLUGIN_CACHE_PATH")" ]]; then
  rm -rf "$CODEX_PLUGIN_CACHE_PATH"
  mkdir -p "$CODEX_PLUGIN_CACHE_PATH"
  rsync -a \
    --exclude '.git' \
    --exclude '.idea' \
    --exclude '.DS_Store' \
    "$ROOT/" "$CODEX_PLUGIN_CACHE_PATH/"
fi

update_marketplace() {
  local marketplace_path="$1"
  local marketplace_name="$2"
  local plugin_path="$3"

  mkdir -p "$(dirname "$marketplace_path")"
  python3 - "$marketplace_path" "$marketplace_name" "$PLUGIN_NAME" "$plugin_path" <<'PY'
import json
import os
import sys

marketplace_path, marketplace_name, plugin_name, plugin_path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

if os.path.exists(marketplace_path):
    with open(marketplace_path, "r", encoding="utf-8") as f:
        data = json.load(f)
else:
    data = {
        "name": marketplace_name,
        "interface": {"displayName": "Local Devflow"},
        "plugins": [],
    }

data.setdefault("name", marketplace_name)
data.setdefault("interface", {}).setdefault("displayName", "Local Devflow")
plugins = data.setdefault("plugins", [])

entry = {
    "name": plugin_name,
    "source": {
        "source": "local",
        "path": plugin_path,
    },
    "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL",
    },
    "category": "Productivity",
}

plugins[:] = [p for p in plugins if p.get("name") not in {plugin_name, "devflow-kit"}]
plugins.append(entry)

with open(marketplace_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")
PY
}

update_marketplace "$MARKETPLACE_PATH" "local-devflow" "./plugins/$PLUGIN_NAME"

mkdir -p "$CODEX_COMMANDS_DIR"
rm -f \
  "$CODEX_COMMANDS_DIR/dfd:gen-brd.md" \
  "$CODEX_COMMANDS_DIR/dfd:gen-hld.md" \
  "$CODEX_COMMANDS_DIR/dfd:gen-mld.md" \
  "$CODEX_COMMANDS_DIR/dfd:gen-lld.md" \
  "$CODEX_COMMANDS_DIR/dfd:gen-design-tree.md" \
  "$CODEX_COMMANDS_DIR/dfd:implement-lld.md" \
  "$CODEX_COMMANDS_DIR/dfd:implement-lld-folder.md"
cp "$ROOT/commands/brd.md" "$CODEX_COMMANDS_DIR/dfd:brd.md"
cp "$ROOT/commands/hld.md" "$CODEX_COMMANDS_DIR/dfd:hld.md"
cp "$ROOT/commands/mld.md" "$CODEX_COMMANDS_DIR/dfd:mld.md"
cp "$ROOT/commands/lld.md" "$CODEX_COMMANDS_DIR/dfd:lld.md"
cp "$ROOT/commands/design-tree.md" "$CODEX_COMMANDS_DIR/dfd:design-tree.md"
cp "$ROOT/commands/implementation-lld.md" "$CODEX_COMMANDS_DIR/dfi:lld.md"
cp "$ROOT/commands/implementation-lld-folder.md" "$CODEX_COMMANDS_DIR/dfi:lld-folder.md"

if [[ -f "$CODEX_TMP_MARKETPLACE_ROOT/.agents/plugins/marketplace.json" ]]; then
  python3 - "$CODEX_TMP_MARKETPLACE_ROOT/.agents/plugins/marketplace.json" "$PLUGIN_NAME" <<'PY'
import json
import sys

marketplace_path, plugin_name = sys.argv[1], sys.argv[2]
with open(marketplace_path, "r", encoding="utf-8") as f:
    data = json.load(f)

plugins = data.setdefault("plugins", [])
plugins[:] = [p for p in plugins if p.get("name") != plugin_name]

with open(marketplace_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")
PY
  rm -rf "$CODEX_TMP_MARKETPLACE_ROOT/plugins/$PLUGIN_NAME"
fi

echo "Installed $PLUGIN_NAME"
echo "Plugin name: $MARKETPLACE_NAME"
echo "Plugin path: $PLUGIN_PATH"
if [[ -d "$CODEX_PLUGIN_CACHE_PATH" ]]; then
  echo "Codex plugin cache: $CODEX_PLUGIN_CACHE_PATH"
fi
echo "Marketplace: $MARKETPLACE_PATH"
echo "Codex command: $CODEX_COMMANDS_DIR/dfd:brd.md"
echo "Codex command: $CODEX_COMMANDS_DIR/dfd:hld.md"
echo "Codex command: $CODEX_COMMANDS_DIR/dfd:mld.md"
echo "Codex command: $CODEX_COMMANDS_DIR/dfd:lld.md"
echo "Codex command: $CODEX_COMMANDS_DIR/dfd:design-tree.md"
echo "Codex command: $CODEX_COMMANDS_DIR/dfi:lld.md"
echo "Codex command: $CODEX_COMMANDS_DIR/dfi:lld-folder.md"
legacy_path="$PLUGIN_PARENT/$LEGACY_PLUGIN_NAME"
if [[ -L "$legacy_path" ]]; then
  rm "$legacy_path"
fi

if [[ "${DEVFLOW_SKIP_CODEX_MARKETPLACE_ADD:-0}" != "1" ]]; then
  if command -v codex >/dev/null 2>&1; then
    codex plugin marketplace add "$HOME_DIR"
  else
    echo "codex command not found; manually run: codex plugin marketplace add \"$HOME_DIR\"" >&2
  fi
fi

mkdir -p "$(dirname "$CODEX_CONFIG_PATH")"
python3 - "$CODEX_CONFIG_PATH" "$MARKETPLACE_NAME" "$CODEX_TMP_MARKETPLACE_ROOT" <<'PY'
import re
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
plugin_name = sys.argv[2]
tmp_root = Path(sys.argv[3])
plugin_keys_to_remove = [f'{plugin_name}@local-devflow', f'{plugin_name}@openai-curated']
plugin_keys_to_enable = [f'{plugin_name}@local-devflow']

text = config_path.read_text(encoding="utf-8") if config_path.exists() else ""
for plugin_key in plugin_keys_to_remove:
    pattern = re.compile(
        rf'(?ms)^\[plugins\."{re.escape(plugin_key)}"\]\n'
        r'(?:^[^\[].*?\n)*'
    )
    text = pattern.sub("", text).rstrip()
if text:
    text += "\n\n"
text += "\n\n".join(f'[plugins."{plugin_key}"]\nenabled = true' for plugin_key in plugin_keys_to_enable)
text += "\n"
config_path.write_text(text, encoding="utf-8")
PY

echo "Codex config: $CODEX_CONFIG_PATH"
