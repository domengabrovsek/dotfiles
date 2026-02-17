# ============================================================================
# Completions Configuration
# ============================================================================
# Smart autocompletion for various development tools

# Initialize completion system
autoload -Uz compinit

# Speed up compinit by only checking cache once per day
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

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

# ============================================================================
# Docker Completion
# ============================================================================

# Docker CLI completions (if Docker Desktop installed)
if [[ -d ~/.docker/completions ]]; then
  fpath=(~/.docker/completions $fpath)
fi

# ============================================================================
# Docker Compose Completion
# ============================================================================

# Docker Compose v2 completion
if command -v docker &> /dev/null; then
  # Enable docker compose completion (compose is now a subcommand)
  _docker_compose() {
    local -a compose_commands
    compose_commands=(
      'build:Build or rebuild services'
      'up:Create and start containers'
      'down:Stop and remove containers'
      'ps:List containers'
      'logs:View output from containers'
      'exec:Execute a command in a running container'
      'start:Start services'
      'stop:Stop services'
      'restart:Restart services'
      'pull:Pull service images'
      'push:Push service images'
    )
    _describe 'docker compose commands' compose_commands
  }
fi

# ============================================================================
# Kubernetes (kubectl) Completion
# ============================================================================

if command -v kubectl &> /dev/null; then
  # Cache kubectl completions to file (regenerates when binary changes)
  _kubectl_comp_cache="${HOME}/.zsh/cache/kubectl_completion.zsh"
  if [[ ! -f "$_kubectl_comp_cache" || "$(which kubectl)" -nt "$_kubectl_comp_cache" ]]; then
    kubectl completion zsh > "$_kubectl_comp_cache" 2>/dev/null
  fi
  [[ -f "$_kubectl_comp_cache" ]] && source "$_kubectl_comp_cache"

  # Alias completion for k=kubectl
  compdef k=kubectl
  compdef kg=kubectl
  compdef kd=kubectl
  compdef ka=kubectl
fi

# ============================================================================
# AWS CLI Completion
# ============================================================================

if command -v aws &> /dev/null; then
  # Find aws_completer location
  typeset aws_completer_path=$(which aws_completer 2>/dev/null)

  if [[ -z "$aws_completer_path" ]]; then
    # Try common locations
    if [[ -x /usr/local/bin/aws_completer ]]; then
      aws_completer_path="/usr/local/bin/aws_completer"
    elif [[ -x /opt/homebrew/bin/aws_completer ]]; then
      aws_completer_path="/opt/homebrew/bin/aws_completer"
    elif [[ -x /usr/local/aws-cli/v2/current/bin/aws_completer ]]; then
      aws_completer_path="/usr/local/aws-cli/v2/current/bin/aws_completer"
    fi
  fi

  # Only enable completion if we found the completer
  if [[ -n "$aws_completer_path" && -x "$aws_completer_path" ]]; then
    complete -C "$aws_completer_path" aws
  fi

  # Clean up variable
  unset aws_completer_path
fi

# ============================================================================
# GCP (gcloud) Completion
# ============================================================================

# Google Cloud SDK completions
if [[ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "${HOME}/google-cloud-sdk/completion.zsh.inc"
fi

# Common alternative locations
if [[ -f "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi

# ============================================================================
# NPM Completion
# ============================================================================

# NPM completion
if command -v npm &> /dev/null; then
  # Lazy load npm completion (faster shell startup)
  _npm_completion() {
    unfunction _npm_completion
    source <(npm completion)
  }
  compdef _npm_completion npm
fi

# ============================================================================
# Additional Tool Completions
# ============================================================================

# Terraform completion
if command -v terraform &> /dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C $(which terraform) terraform
fi

# Helm completion
if command -v helm &> /dev/null; then
  # Cache helm completions to file (regenerates when binary changes)
  _helm_comp_cache="${HOME}/.zsh/cache/helm_completion.zsh"
  if [[ ! -f "$_helm_comp_cache" || "$(which helm)" -nt "$_helm_comp_cache" ]]; then
    helm completion zsh > "$_helm_comp_cache" 2>/dev/null
  fi
  [[ -f "$_helm_comp_cache" ]] && source "$_helm_comp_cache"
fi

