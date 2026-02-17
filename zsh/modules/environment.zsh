# ============================================================================
# Environment Variables & Settings
# ============================================================================
# Common environment configuration shared across work and personal setups

# ============================================================================
# Path Configuration
# ============================================================================

# Ensure common tool directories are in PATH (deduplicated)
# Order matters: earlier entries take priority
_path_prepend() {
  for dir in "$@"; do
    if [[ -d "$dir" ]]; then
      case ":$PATH:" in
        *":$dir:"*) ;;
        *) export PATH="$dir:$PATH" ;;
      esac
    fi
  done
}

_path_prepend \
  /usr/local/bin \
  "$HOME/.local/bin" \
  "$HOME/.docker/bin" \
  /Applications/Docker.app/Contents/Resources/bin

unfunction _path_prepend

# ============================================================================
# Google Cloud SDK
# ============================================================================

# Source gcloud PATH and completions (installed via brew --cask google-cloud-sdk)
if [[ -f /opt/homebrew/share/google-cloud-sdk/path.zsh.inc ]]; then
  source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
fi
if [[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ]]; then
  source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
fi

# ============================================================================
# Editor Configuration
# ============================================================================

export EDITOR='code -w'
export VISUAL='code -w'

# ============================================================================
# History Configuration
# ============================================================================

export HISTFILE=~/.zsh_history
export HISTSIZE=50000
export SAVEHIST=50000

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
# Don't show duplicate entries when searching history
setopt HIST_FIND_NO_DUPS
# Expire duplicate entries first when trimming history
setopt HIST_EXPIRE_DUPS_FIRST

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
# NVM loading and .nvmrc auto-switching handled by Oh My Zsh nvm plugin
# with lazy loading (see .zshrc zstyle configuration)

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
# Smart Directory Jumping (zoxide or z.sh fallback)
# ============================================================================

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
elif [[ -f "$HOME/z.sh" ]]; then
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

# Clear autosuggestion with Ctrl+U
bindkey '^U' autosuggest-clear

# Fetch suggestions asynchronously for better performance
ZSH_AUTOSUGGEST_USE_ASYNC=true

# Buffer max size for autosuggestions
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ============================================================================
# fzf Configuration (fuzzy finder)
# ============================================================================

if command -v fzf >/dev/null 2>&1; then
  # Set up fzf key bindings (Ctrl-R for history, Ctrl-T for files, Alt-C for cd)
  source <(fzf --zsh)

  # Default options
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi
