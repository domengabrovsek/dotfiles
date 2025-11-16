# ============================================================================
# Main .zshrc Configuration File
# ============================================================================
# Author: Domen Gabrovsek
# Repository: https://github.com/domengabrovsek/dotfiles
#
# This modular configuration allows switching between work and personal setups
# while sharing common configurations.
#
# Usage:
#   - Default mode is 'personal'
#   - To use work config: export ZSH_CONFIG_MODE=work (in ~/.zprofile or set below)
#   - To switch modes temporarily, run: zsh_switch work|personal
#
# Structure:
#   ~/.zsh/shared/    - Common configs used by both work and personal
#   ~/.zsh/work/      - Work-specific overrides and additions
#   ~/.zsh/personal/  - Personal-specific overrides and additions
# ============================================================================

# ============================================================================
# Configuration Mode Selection
# ============================================================================

# Set your default mode here, or export ZSH_CONFIG_MODE in ~/.zprofile
# Options: "work" or "personal"
export ZSH_CONFIG_MODE="${ZSH_CONFIG_MODE:-personal}"

# ============================================================================
# Oh My Zsh Configuration
# ============================================================================

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Oh My Zsh theme (we're using custom prompt from shared/prompt.zsh)
# Set to empty or "random" if you want Oh My Zsh themes instead
ZSH_THEME=""

# Oh My Zsh plugins
# Note: completions are also managed in shared/completions.zsh
plugins=(
  git
  docker
  docker-compose
  npm
  node
  kubectl
  terraform
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ============================================================================
# Load Shared Configurations (Always Loaded)
# ============================================================================

# Load in specific order for proper initialization

# 1. Environment variables first (needed by other configs)
[[ -f ~/.zsh/shared/environment.zsh ]] && source ~/.zsh/shared/environment.zsh

# 2. Completions (tools and CLI completions)
[[ -f ~/.zsh/shared/completions.zsh ]] && source ~/.zsh/shared/completions.zsh

# 3. Aliases
[[ -f ~/.zsh/shared/aliases.zsh ]] && source ~/.zsh/shared/aliases.zsh

# 4. Functions (loaded before prompt so welcome function is available)
[[ -f ~/.zsh/shared/functions.zsh ]] && source ~/.zsh/shared/functions.zsh

# 5. Prompt (loaded last so it can use functions defined above)
[[ -f ~/.zsh/shared/prompt.zsh ]] && source ~/.zsh/shared/prompt.zsh

# ============================================================================
# Load Mode-Specific Configurations
# ============================================================================

case "$ZSH_CONFIG_MODE" in
  work)
    [[ -f ~/.zsh/work/environment.zsh ]] && source ~/.zsh/work/environment.zsh
    [[ -f ~/.zsh/work/aliases.zsh ]] && source ~/.zsh/work/aliases.zsh
    [[ -f ~/.zsh/work/functions.zsh ]] && source ~/.zsh/work/functions.zsh
    ;;
  personal)
    [[ -f ~/.zsh/personal/environment.zsh ]] && source ~/.zsh/personal/environment.zsh
    [[ -f ~/.zsh/personal/aliases.zsh ]] && source ~/.zsh/personal/aliases.zsh
    [[ -f ~/.zsh/personal/functions.zsh ]] && source ~/.zsh/personal/functions.zsh
    ;;
  *)
    echo "⚠️  Unknown ZSH_CONFIG_MODE: $ZSH_CONFIG_MODE (using personal as fallback)"
    export ZSH_CONFIG_MODE=personal
    [[ -f ~/.zsh/personal/environment.zsh ]] && source ~/.zsh/personal/environment.zsh
    [[ -f ~/.zsh/personal/aliases.zsh ]] && source ~/.zsh/personal/aliases.zsh
    [[ -f ~/.zsh/personal/functions.zsh ]] && source ~/.zsh/personal/functions.zsh
    ;;
esac

# ============================================================================
# Mode Switching Function
# ============================================================================

# Function to switch between work and personal configs
zsh_switch() {
  if [[ -z "$1" ]]; then
    echo "Current mode: $ZSH_CONFIG_MODE"
    echo "Usage: zsh_switch [work|personal]"
    return 1
  fi

  case "$1" in
    work|personal)
      export ZSH_CONFIG_MODE="$1"
      echo "Switched to $1 mode. Reloading shell..."
      exec zsh
      ;;
    *)
      echo "Invalid mode: $1"
      echo "Available modes: work, personal"
      return 1
      ;;
  esac
}

# Function to check current mode
zsh_mode() {
  echo "Current configuration mode: $ZSH_CONFIG_MODE"
}

# ============================================================================
# Local Overrides (Not Tracked in Git)
# ============================================================================

# Load local configuration that won't be committed to git
# Useful for machine-specific settings, API keys, etc.
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# ============================================================================
# Welcome Message
# ============================================================================

# Control welcome message display
# Set ZSH_DISABLE_WELCOME=1 in ~/.zshrc.local to disable
if [[ -z "$ZSH_DISABLE_WELCOME" ]]; then
  # Only show welcome for interactive shells
  if [[ -o interactive ]]; then
    zsh_welcome
  fi
fi

# Alternative: Simple welcome message (uncomment and disable zsh_welcome above)
# echo "👋 Welcome! Running in $ZSH_CONFIG_MODE mode. Type 'zhelp' for help."
