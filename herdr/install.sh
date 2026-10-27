#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# herdr config installer
# ============================================================================
# Usage: ./install.sh
# Idempotent - safe to re-run. Links ~/.config/herdr/config.toml to the repo.
# herdr keeps its session, logs, and sidebar height beside the config, so only
# the one file is linked, not the whole directory.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERDR_DIR="$HOME/.config/herdr"
TARGET="$HERDR_DIR/config.toml"

mkdir -p "$HERDR_DIR"

if [ -f "$TARGET" ] && [ ! -L "$TARGET" ]; then
  mv "$TARGET" "$TARGET.backup-$(date +%Y%m%d-%H%M%S)"
  echo "[ok] backed up the old config.toml"
fi
ln -sf "$SCRIPT_DIR/config.toml" "$TARGET"
echo "[ok] $TARGET -> $SCRIPT_DIR/config.toml"

# herdr keeps the spaces/agents split per client in its state dir, not in
# config.toml. 0.1 is herdr's minimum, which leaves the most room for agents.
SECTION_SPLIT=0.1
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/herdr/client-shell"
shopt -s nullglob
prefs=("$STATE_DIR"/local-*.json)
shopt -u nullglob
if [ ${#prefs[@]} -eq 0 ]; then
  echo "[skip] sidebar height: start herdr once, then re-run this installer"
else
  for pref in "${prefs[@]}"; do
    python3 - "$pref" "$SECTION_SPLIT" <<'PY'
import json, os, sys
path, split = sys.argv[1], float(sys.argv[2])
with open(path) as handle:
    prefs = json.load(handle)
prefs["sidebar_section_split"] = split
with open(path + ".tmp", "w") as handle:
    json.dump(prefs, handle, indent=2)
os.replace(path + ".tmp", path)
PY
    echo "[ok] sidebar height $SECTION_SPLIT in $pref"
  done
  echo "     Detach and reattach herdr to apply it; a running window keeps the old height."
fi

if command -v herdr &> /dev/null && herdr server reload-config &> /dev/null; then
  echo "[ok] reloaded the running herdr server"
else
  echo "[skip] no running herdr server; the config loads on next start"
fi
