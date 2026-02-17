# ============================================================================
# Main .zshrc Configuration File
# ============================================================================
# Author: Domen Gabrovsek
# Repository: https://github.com/domengabrovsek/dotfiles
#
# Structure:
#   ~/.zsh/modules/  - All configuration modules
#   ~/.zshrc.local   - Machine-specific overrides (not tracked in git)
# ============================================================================

# ============================================================================
# Performance Monitoring
# ============================================================================

# Capture shell start time for performance monitoring
zmodload zsh/datetime
shell_start_time=$EPOCHREALTIME

# ============================================================================
# Homebrew Environment (must be early for PATH setup)
# ============================================================================

if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ============================================================================
# Oh My Zsh Configuration
# ============================================================================

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Oh My Zsh theme (we're using custom prompt from modules/prompt.zsh)
# Set to empty or "random" if you want Oh My Zsh themes instead
ZSH_THEME=""

# Oh My Zsh NVM lazy loading (must be set before plugins are loaded)
zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:nvm' autoload yes
zstyle ':omz:plugins:nvm' silent-autoload yes

# Oh My Zsh plugins
# Note: completions are also managed in modules/completions.zsh
plugins=(
  git
  docker
  docker-compose
  npm
  nvm
  kubectl
  terraform
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ============================================================================
# Load Modules
# ============================================================================

for module in environment completions aliases functions prompt gcp; do
  [[ -f ~/.zsh/modules/${module}.zsh ]] && source ~/.zsh/modules/${module}.zsh
done

# ============================================================================
# Local Overrides (Not Tracked in Git)
# ============================================================================

# Load local configuration that won't be committed to git
# Useful for machine-specific settings, API keys, etc.
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# ============================================================================
# Performance Monitoring
# ============================================================================

# Show shell startup time
printf "Shell loaded in: %.0fms\n" $(( ($EPOCHREALTIME - shell_start_time) * 1000 ))

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
