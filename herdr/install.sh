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
# config.toml, and only writes that file after a resize. Its name is the FNV-1a
# hash of the client socket path, so the installer can create it on a fresh
# machine. 0.1 is herdr's minimum, which leaves the most room for agents.
SECTION_SPLIT=0.1
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/herdr/client-shell"
python3 - "$STATE_DIR" "$HERDR_DIR/herdr-client.sock" "$SECTION_SPLIT" <<'PY'
import glob, json, os, sys
state_dir, socket_path, split = sys.argv[1], sys.argv[2], float(sys.argv[3])
digest = 0xcbf29ce484222325
for byte in socket_path.encode():
    digest = ((digest ^ byte) * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF
os.makedirs(state_dir, exist_ok=True)
paths = set(glob.glob(os.path.join(state_dir, "local-*.json")))
paths.add(os.path.join(state_dir, f"local-{digest:016x}.json"))
for path in sorted(paths):
    prefs = {}
    if os.path.exists(path):
        with open(path) as handle:
            prefs = json.load(handle)
    prefs["sidebar_section_split"] = split
    with open(path + ".tmp", "w") as handle:
        json.dump(prefs, handle, indent=2)
    os.replace(path + ".tmp", path)
    print(f"[ok] sidebar height {split} in {path}")
PY
echo "     Detach and reattach herdr to apply it; a running window keeps the old height."

if command -v herdr &> /dev/null && herdr server reload-config &> /dev/null; then
  echo "[ok] reloaded the running herdr server"
else
  echo "[skip] no running herdr server; the config loads on next start"
fi
