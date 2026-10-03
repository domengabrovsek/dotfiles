# ============================================================================
# Completions Configuration
# ============================================================================
# Smart autocompletion for various development tools

# Oh My Zsh has already run compinit. Running it again costs ~400ms and drops
# every completion registered in between, such as gcloud's from gcp.zsh.

# ============================================================================
# Completion Settings
# ============================================================================

# Enable completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Enable auto menu completion (show menu on second tab press)
setopt AUTO_MENU

# Show completion menu on first tab press
setopt MENU_COMPLETE

# Move cursor to end of word after accepting completion
setopt ALWAYS_TO_END

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Better completion for kill command
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# Partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# Group matches and describe groups
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Allow arrow key driven completion menu
zstyle ':completion:*' menu select

# Fuzzy matching for typos
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# Note: COMPLETE_ALIASES removed - without it, alias expansion happens before
# completion lookup, so git aliases (gs, ga, etc.) get proper git completions
