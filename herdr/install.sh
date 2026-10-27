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

if command -v herdr &> /dev/null && herdr server reload-config &> /dev/null; then
  echo "[ok] reloaded the running herdr server"
else
  echo "[skip] no running herdr server; the config loads on next start"
fi
