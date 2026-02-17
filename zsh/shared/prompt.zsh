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
# GCP Profile Display (cached to avoid slow gcloud calls on every prompt)
# ============================================================================

_cached_gcp_config=""

_update_gcp_config_cache() {
  if command -v gcloud >/dev/null 2>&1; then
    _cached_gcp_config=$(gcloud config configurations list --filter="IS_ACTIVE=true" --format="value(name)" 2>/dev/null)
  else
    _cached_gcp_config=""
  fi
}

function gcp_profile() {
  if [[ -n "$_cached_gcp_config" && "$_cached_gcp_config" != "default" ]]; then
    echo "%F{33}gcp:${_cached_gcp_config}%f "
  fi
}

# Initial cache load
_update_gcp_config_cache

# ============================================================================
# Prompt Definition
# ============================================================================

# Custom prompt - showing last directory (%1~) and git icon (±)
PROMPT='%{$fg[cyan]%}%1~%{$reset_color%} $(git_prompt_info)$(aws_profile)$(gcp_profile)$(node_version) %{$fg[blue]%}→%{$reset_color%} '

# Git prompt settings with icon
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}±(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
