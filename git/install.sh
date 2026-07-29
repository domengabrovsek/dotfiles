#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Git + SSH identity installer (personal + pentla)
# ============================================================================
# Usage: git clone <dotfiles> && cd dotfiles/git && ./install.sh
# Idempotent - safe to re-run. Generates keys locally; nothing secret is
# ever written back into the repo.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
INCLUDE_LINE="Include $SCRIPT_DIR/ssh.config"

# key file -> commit email used as the key comment
PERSONAL_KEY="$SSH_DIR/id_personal"
PENTLA_KEY="$SSH_DIR/id_pentla"
PERSONAL_EMAIL="domen@domengabrovsek.com"
PENTLA_EMAIL="domen@pentla.tech"

echo "Setting up git identities from: $SCRIPT_DIR"
echo ""

# ============================================================================
# 1. SSH directory
# ============================================================================

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
echo "[ok] ~/.ssh (700)"

# ============================================================================
# 2. Generate ed25519 keys (one per context)
# ============================================================================

gen_key() {
  local path="$1" email="$2"
  if [ -f "$path" ]; then
    echo "[ok] key exists: $path"
  else
    echo "Generating key: $path ($email)"
    ssh-keygen -t ed25519 -C "$email" -f "$path" -N ""
  fi
  chmod 600 "$path"
  chmod 644 "$path.pub"
}

gen_key "$PERSONAL_KEY" "$PERSONAL_EMAIL"
gen_key "$PENTLA_KEY" "$PENTLA_EMAIL"

# ============================================================================
# 3. Wire ssh.config into ~/.ssh/config via an Include at the very top
# ============================================================================
# ssh applies the FIRST matching value for most options, so the Include has to
# come before any pre-existing Host blocks to win.

if [ -f "$SSH_CONFIG" ] && grep -qF "$INCLUDE_LINE" "$SSH_CONFIG"; then
  echo "[ok] ssh Include already present"
else
  if [ -f "$SSH_CONFIG" ]; then
    cp "$SSH_CONFIG" "$SSH_CONFIG.backup-$(date +%Y%m%d-%H%M%S)"
    printf '%s\n\n%s' "$INCLUDE_LINE" "$(cat "$SSH_CONFIG")" > "$SSH_CONFIG"
  else
    printf '%s\n' "$INCLUDE_LINE" > "$SSH_CONFIG"
  fi
  chmod 600 "$SSH_CONFIG"
  echo "[ok] added Include to ~/.ssh/config"
fi

# ============================================================================
# 4. Load keys into the agent + macOS keychain
# ============================================================================

if ssh-add --apple-use-keychain "$PERSONAL_KEY" "$PENTLA_KEY" 2>/dev/null; then
  echo "[ok] keys added to agent + keychain"
else
  echo "[warn] could not add keys to agent (is ssh-agent running?)"
fi

# ============================================================================
# 5. Symlink git config files
# ============================================================================

link() {
  local src="$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "[ok] $dest -> $src"
    return
  fi
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.backup-$(date +%Y%m%d-%H%M%S)"
    echo "     backed up existing $dest"
  fi
  ln -sf "$src" "$dest"
  echo "[ok] $dest -> $src"
}

link "$SCRIPT_DIR/gitconfig" "$HOME/.gitconfig"
link "$SCRIPT_DIR/gitconfig-pentla" "$HOME/.gitconfig-pentla"

# ============================================================================
# 6. Public keys to register on GitHub
# ============================================================================

echo ""
echo "============================================================"
echo "Add each PUBLIC key to the matching GitHub account:"
echo "  https://github.com/settings/keys"
echo "============================================================"
echo ""
echo "--- PERSONAL (github.com / domengabrovsek) ---"
cat "$PERSONAL_KEY.pub"
echo ""
echo "--- PENTLA (github.com / Pentla-tech account) ---"
cat "$PENTLA_KEY.pub"
echo ""

if command -v pbcopy >/dev/null 2>&1; then
  echo "Tip: pbcopy < ~/.ssh/id_personal.pub   (then paste into GitHub)"
  echo "     pbcopy < ~/.ssh/id_pentla.pub"
  echo ""
fi

echo "After adding the keys, verify with:"
echo "  ssh -T git@github.com        # expect: Hi domengabrovsek"
echo "  ssh -T git@github-pentla     # expect: Hi <your pentla user>"
echo ""
echo "Then clone into the right folder, e.g.:"
echo "  git clone git@github.com:domengabrovsek/personal-api.git  ~/dev/personal/personal-api"
echo "  git clone git@github.com:Pentla-tech/pentla-api.git       ~/dev/work/pentla/pentla-api"
echo ""
echo "Done."
