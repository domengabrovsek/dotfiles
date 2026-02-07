# ============================================================================
# Prompt Configuration
# ============================================================================
# Custom prompt with git info and Node.js version

# ============================================================================
# Cached Node.js Version (avoids subprocess on every prompt render)
# ============================================================================

_cached_node_version=""

_update_node_version_cache() {
  if command -v node >/dev/null 2>&1; then
    _cached_node_version="$(node -v)"
  else
    _cached_node_version=""
  fi
}

function node_version() {
  if [[ -n "$_cached_node_version" ]]; then
    echo "%F{yellow}⬢ ${_cached_node_version}%f"
  fi
}

# Update cache on directory change (handles .nvmrc switches)
autoload -U add-zsh-hook
add-zsh-hook chpwd _update_node_version_cache
_update_node_version_cache

# ============================================================================
# AWS Profile Display
# ============================================================================

function aws_profile() {
  if [[ -n "$AWS_PROFILE" ]]; then
    echo "%F{208}☁︎ $AWS_PROFILE%f "
  elif [[ -n "$AWS_DEFAULT_PROFILE" ]]; then
    echo "%F{208}☁︎ $AWS_DEFAULT_PROFILE%f "
  fi
}

# ============================================================================
# Prompt Definition
# ============================================================================

# Custom prompt - using full path (%~ instead of %c) and git icon (±)
PROMPT='%{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)$(aws_profile)$(node_version) %{$fg[blue]%}→%{$reset_color%} '

# Git prompt settings with icon
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}±(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
