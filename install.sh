#!/usr/bin/env bash
set -e

# ============================================================================
# Ghostty + tmux installer
# ============================================================================
# Symlinks the Ghostty and tmux configs into ~/.config and makes the session
# script executable. Idempotent - safe to re-run. For the zsh setup, see
# zsh/install.sh.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# tmux is required for the pentla session layout.
if ! command -v tmux &> /dev/null; then
  echo "Installing tmux..."
  brew install tmux
else
  echo "[ok] tmux"
fi

# Symlink a whole config dir, backing up any existing real file/dir first.
link_dir() {
  local src="$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "[ok] $dest -> $src"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.backup-$(date +%Y%m%d-%H%M%S)"
    echo "     backed up existing $dest"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -sf "$src" "$dest"
  echo "[ok] $dest -> $src"
}

chmod +x "$SCRIPT_DIR/tmux/sessions/"*.sh

link_dir "$SCRIPT_DIR/ghostty" "$HOME/.config/ghostty"
link_dir "$SCRIPT_DIR/tmux"    "$HOME/.config/tmux"

# Ghostty also reads the macOS Application Support path and loads it last (it
# would override the git-tracked XDG config). Move the default template aside.
APPSUP="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
if [ -f "$APPSUP" ] && [ ! -L "$APPSUP" ]; then
  mv "$APPSUP" "$APPSUP.backup-$(date +%Y%m%d-%H%M%S)"
  echo "     backed up macOS Ghostty template -> XDG config is now authoritative"
fi

echo ""
echo "Done. Open a new Ghostty window to launch the pentla session,"
echo "or run: $SCRIPT_DIR/tmux/sessions/pentla.sh"
