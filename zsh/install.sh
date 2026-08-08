#!/usr/bin/env bash
set -e

# ============================================================================
# Zsh Configuration Installer
# ============================================================================
# Usage: git clone <repo> && cd dotfiles/zsh && ./install.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

case "$(uname -s)" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *) echo "Unsupported platform: $(uname -s)"; exit 1 ;;
esac

echo "Setting up zsh config from: $SCRIPT_DIR ($PLATFORM)"
echo ""

# ============================================================================
# 1. Package manager + zsh
# ============================================================================
# macOS ships zsh and gets its CLI tools from Homebrew. Debian/Ubuntu ships
# neither, and Homebrew publishes no ARM64 Linux bottles - every formula would
# compile from source - so apt provides both there.

if [ "$PLATFORM" = "macos" ]; then
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "[ok] Homebrew"
  fi
else
  if ! command -v apt-get &> /dev/null; then
    echo "This installer supports Debian/Ubuntu on Linux (needs apt-get)."
    exit 1
  fi
  # Oh My Zsh aborts if zsh is missing, so it has to land before step 2.
  if ! command -v zsh &> /dev/null; then
    echo "Installing zsh..."
    sudo apt-get update -qq
    sudo apt-get install -y zsh
  else
    echo "[ok] zsh"
  fi
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
  if command -v "$tool" &> /dev/null; then
    echo "[ok] $tool"
  # Debian/Ubuntu ship bat's binary as batcat, to avoid a clash with an
  # unrelated package of the same name. aliases.zsh handles both spellings.
  elif [ "$tool" = "bat" ] && command -v batcat &> /dev/null; then
    echo "[ok] bat (installed as batcat)"
  else
    missing+=("$tool")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  if [ "$PLATFORM" = "macos" ]; then
    echo "Installing: ${missing[*]}..."
    brew install "${missing[@]}"
  else
    # Repos differ by release - Ubuntu 24.04 and later carry eza, Debian 12 does
    # not. Filter to what this distro actually has, because one unknown package
    # name makes apt-get exit non-zero, and under `set -e` that would abort the
    # run before the symlinks and login shell are ever set up.
    sudo apt-get update -qq
    available=()
    unavailable=()
    for tool in "${missing[@]}"; do
      if apt-cache show "$tool" > /dev/null 2>&1; then
        available+=("$tool")
      else
        unavailable+=("$tool")
      fi
    done

    if [ ${#available[@]} -gt 0 ]; then
      echo "Installing: ${available[*]}..."
      sudo apt-get install -y "${available[@]}"
    fi

    if [ ${#unavailable[@]} -gt 0 ]; then
      echo "[warn] not packaged for $(. /etc/os-release && echo "$PRETTY_NAME"): ${unavailable[*]}"
      echo "       aliases.zsh falls back to the standard tools, so the shell still works"
    fi
  fi
fi

# ============================================================================
# 5. nvm + Node
# ============================================================================

# The whole config (.zshenv, environment.zsh, prompt.zsh, OMZ nvm plugin) assumes
# the classic ~/.nvm layout, so install nvm there rather than via Homebrew (whose
# nvm.sh lives outside NVM_DIR and is skipped once NVM_DIR is pinned).
NVM_VERSION="v0.40.6"
export NVM_DIR="$HOME/.nvm"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo "Installing nvm $NVM_VERSION..."
  # PROFILE=/dev/null stops nvm's installer from editing the symlinked .zshrc/.zshenv
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | PROFILE=/dev/null bash
else
  echo "[ok] nvm"
fi

# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"

if [ ! -s "$NVM_DIR/alias/default" ]; then
  echo "Installing Node LTS and setting it as default..."
  nvm install --lts
  # Pin the default to the major version (e.g. "24"), the form .zshenv resolves
  # against ~/.nvm/versions/node. An "lts/*" glob default is not resolvable there.
  node_major="$(nvm current)"; node_major="${node_major#v}"; node_major="${node_major%%.*}"
  nvm alias default "$node_major"
  unset node_major
else
  echo "[ok] Node ($(nvm version default))"
fi

# ============================================================================
# 6. Cloud CLIs + accounts (AWS, GCP)
# ============================================================================

# Workstation-only. gcloud and session-manager-plugin ship as casks, which are
# macOS-only, and the homelab hosts have no reason to hold cloud credentials.
# environment.zsh and completions.zsh already guard every path this section
# creates, so skipping it leaves a working shell rather than a broken one.
if [ "$PLATFORM" = "macos" ]; then
  if command -v aws &> /dev/null; then echo "[ok] awscli"; else echo "Installing awscli..."; brew install awscli; fi
  if command -v gcloud &> /dev/null; then echo "[ok] gcloud"; else echo "Installing google-cloud-sdk..."; brew install --cask google-cloud-sdk; fi
  if command -v session-manager-plugin &> /dev/null; then echo "[ok] session-manager-plugin"; else echo "Installing session-manager-plugin..."; brew install --cask session-manager-plugin; fi

  # Symlink the SSO config (no secrets in it) so `aws sso login --sso-session personal` works.
  mkdir -p "$HOME/.aws"
  if [ -f "$HOME/.aws/config" ] && [ ! -L "$HOME/.aws/config" ]; then
    mv "$HOME/.aws/config" "$HOME/.aws/config.backup-$(date +%Y%m%d-%H%M%S)"
  fi
  ln -sf "$SCRIPT_DIR/aws/config" "$HOME/.aws/config"
  echo "[ok] ~/.aws/config -> $SCRIPT_DIR/aws/config"

  # Seed gcloud configurations (idempotent - creates each only if missing).
  if [ -x "$SCRIPT_DIR/gcp/configurations.sh" ]; then
    "$SCRIPT_DIR/gcp/configurations.sh"
  fi
else
  echo "[skip] cloud CLIs (workstation only)"
fi

# ============================================================================
# 7. Symlink config
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

# Back up and replace ~/.zshenv (non-interactive shells read this)
if [ -f "$HOME/.zshenv" ] && [ ! -L "$HOME/.zshenv" ]; then
  mv "$HOME/.zshenv" "$HOME/.zshenv.backup-$(date +%Y%m%d-%H%M%S)"
fi
ln -sf "$HOME/.zsh/.zshenv" "$HOME/.zshenv"
echo "[ok] ~/.zshenv -> ~/.zsh/.zshenv"

# Ensure cache dir exists
mkdir -p "$SCRIPT_DIR/cache"

# ============================================================================
# 8. Login shell
# ============================================================================
# macOS already defaults to zsh. Debian/Ubuntu defaults to bash, so without this
# the config only loads when zsh is started by hand.

if [ "$PLATFORM" = "linux" ] && [ "$(basename "${SHELL:-}")" != "zsh" ]; then
  zsh_path="$(command -v zsh)"
  grep -qxF "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
  # via sudo because plain chsh prompts for the account password, which breaks
  # any non-interactive run
  if sudo chsh -s "$zsh_path" "$USER"; then
    echo "[ok] login shell -> $zsh_path (takes effect next login)"
  else
    echo "[warn] could not change login shell; run: chsh -s $zsh_path"
  fi
else
  echo "[ok] login shell is zsh"
fi

# ============================================================================
# Done
# ============================================================================

echo ""
echo "Done! Open a new terminal or run: exec zsh"
echo ""
echo "  zhelp          - search all commands"
