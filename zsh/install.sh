#!/usr/bin/env bash
set -e

# ============================================================================
# Zsh Configuration Installer
# ============================================================================
# Usage: git clone <repo> && cd dotfiles/zsh && ./install.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "Setting up zsh config from: $SCRIPT_DIR"
echo ""

# ============================================================================
# 1. Homebrew (needed for everything else)
# ============================================================================

if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "[ok] Homebrew"
fi

# ============================================================================
# 2. Oh My Zsh
# ============================================================================

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "[ok] Oh My Zsh"
fi

# ============================================================================
# 3. Oh My Zsh plugins
# ============================================================================

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "[ok] zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "[ok] zsh-syntax-highlighting"
fi

# ============================================================================
# 4. CLI tools via Homebrew
# ============================================================================

tools=(fzf eza bat zoxide)
missing=()

for tool in "${tools[@]}"; do
  if ! command -v "$tool" &> /dev/null; then
    missing+=("$tool")
  else
    echo "[ok] $tool"
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "Installing: ${missing[*]}..."
  brew install "${missing[@]}"
fi

# ============================================================================
# 5. Symlink config
# ============================================================================

# Back up and replace ~/.zsh if it's not already pointing to the repo
if [ -L "$HOME/.zsh" ]; then
  current_target="$(readlink "$HOME/.zsh")"
  if [ "$current_target" = "$SCRIPT_DIR" ]; then
    echo "[ok] ~/.zsh -> $SCRIPT_DIR"
  else
    rm "$HOME/.zsh"
    ln -sf "$SCRIPT_DIR" "$HOME/.zsh"
    echo "[ok] ~/.zsh -> $SCRIPT_DIR (updated)"
  fi
elif [ -d "$HOME/.zsh" ]; then
  mv "$HOME/.zsh" "$HOME/.zsh.backup-$(date +%Y%m%d-%H%M%S)"
  ln -sf "$SCRIPT_DIR" "$HOME/.zsh"
  echo "[ok] ~/.zsh -> $SCRIPT_DIR (backed up old)"
else
  ln -sf "$SCRIPT_DIR" "$HOME/.zsh"
  echo "[ok] ~/.zsh -> $SCRIPT_DIR"
fi

# Back up and replace ~/.zshrc
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup-$(date +%Y%m%d-%H%M%S)"
fi
ln -sf "$HOME/.zsh/.zshrc" "$HOME/.zshrc"
echo "[ok] ~/.zshrc -> ~/.zsh/.zshrc"

# Ensure cache dir exists
mkdir -p "$SCRIPT_DIR/cache"

# ============================================================================
# Done
# ============================================================================

echo ""
echo "Done! Open a new terminal or run: exec zsh"
echo ""
echo "  zhelp          - search all commands"
