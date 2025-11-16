# ============================================================================
# Environment Variables & Settings
# ============================================================================
# Common environment configuration shared across work and personal setups

# ============================================================================
# Path Configuration
# ============================================================================

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ============================================================================
# Editor Configuration
# ============================================================================

export EDITOR='vim'
export VISUAL='vim'

# ============================================================================
# History Configuration
# ============================================================================

export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# Share history between sessions
setopt SHARE_HISTORY
# Append to history file instead of replacing it
setopt APPEND_HISTORY
# Add commands to history as they are entered, not when shell exits
setopt INC_APPEND_HISTORY
# Do not store duplicate commands
setopt HIST_IGNORE_DUPS
# Remove superfluous blanks from history
setopt HIST_REDUCE_BLANKS
# Don't store commands that start with a space
setopt HIST_IGNORE_SPACE
# Show command with history expansion before running it
setopt HIST_VERIFY

# ============================================================================
# Directory Navigation
# ============================================================================

# Auto cd when typing just a directory name
setopt AUTO_CD
# Push directories onto stack automatically
setopt AUTO_PUSHD
# Don't push duplicate directories
setopt PUSHD_IGNORE_DUPS
# Don't print directory stack after pushd or popd
setopt PUSHD_SILENT

# ============================================================================
# Globbing
# ============================================================================

# Extended globbing (allows more complex pattern matching)
setopt EXTENDED_GLOB
# Case insensitive globbing
setopt NO_CASE_GLOB
# Numeric glob sort
setopt NUMERIC_GLOB_SORT

# ============================================================================
# Error Handling
# ============================================================================

# Beep on error
setopt BEEP
# Print error if pattern has no matches
setopt NOMATCH

# ============================================================================
# Node.js / NVM Configuration
# ============================================================================

export NVM_DIR="$HOME/.nvm"

# Automatically call nvm use when entering a directory with .nvmrc
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# ============================================================================
# Docker Configuration
# ============================================================================

# Enable docker compose build optimization
export COMPOSE_BAKE=true

# Docker BuildKit (faster builds)
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# ============================================================================
# AWS Configuration
# ============================================================================

export AWS_REGION=eu-central-1
export AWS_DEFAULT_REGION=eu-central-1

# AWS pager configuration (use less with colors)
export AWS_PAGER="less -R"

# ============================================================================
# Locale Configuration
# ============================================================================

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ============================================================================
# Less Configuration (for man pages, git logs, etc.)
# ============================================================================

# Make less more friendly for non-text input files
export LESS='-R -F -X -i -M'
# Colors for man pages
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# ============================================================================
# Grep Configuration
# ============================================================================

# Colorize grep output
export GREP_COLOR='1;32'

# ============================================================================
# Z (Jump Around)
# ============================================================================

# Load z for quick directory navigation
if [[ -f "$HOME/z.sh" ]]; then
  source "$HOME/z.sh"
fi

# ============================================================================
# Zsh Autosuggestions Configuration
# ============================================================================

# Suggest from history and completions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Suggestion color (dimmed gray)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# Accept suggestion with Right Arrow or End key
bindkey '^[[C' forward-char              # Right arrow
bindkey '^E' end-of-line                 # Ctrl+E
bindkey '^[[1;5C' forward-word           # Ctrl+Right arrow (accept word)

# Alternative: Accept with Ctrl+Space (uncomment if preferred)
# bindkey '^ ' autosuggest-accept

# Clear autosuggestion with Ctrl+U
bindkey '^U' autosuggest-clear

# Fetch suggestions asynchronously for better performance
ZSH_AUTOSUGGEST_USE_ASYNC=true

# Buffer max size for autosuggestions
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
