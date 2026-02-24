# ============================================================================
# Prompt Configuration
# ============================================================================
# Custom prompt with git info and Node.js version

# ============================================================================
# Cached Node.js Version (avoids subprocess on every prompt render)
# ============================================================================

_cached_node_version=""
_cached_node_bin_path=""
_prompt_last_path=""

_update_node_version_cache() {
  local node_bin
  # whence -p bypasses shell functions (e.g. nvm lazy wrappers) and finds the binary in PATH
  node_bin="$(whence -p node 2>/dev/null)"

  # Skip if the resolved binary path hasn't changed
  [[ "$node_bin" == "$_cached_node_bin_path" ]] && return
  _cached_node_bin_path="$node_bin"

  if [[ "$node_bin" == *"/.nvm/versions/node/"* ]]; then
    # Extract version from NVM path without subprocess
    # e.g., /Users/x/.nvm/versions/node/v24.0.0/bin/node -> v24.0.0
    _cached_node_version="${${node_bin%/bin/node}##*/}"
  elif [[ -n "$node_bin" ]]; then
    _cached_node_version="$("$node_bin" -v 2>/dev/null)"
  else
    _cached_node_version=""
  fi
}

function node_version() {
  if [[ -n "$_cached_node_version" ]]; then
    echo "%F{yellow}⬢ ${_cached_node_version}%f"
  fi
}

# Check for node version changes before each prompt render.
# nvm use/install changes PATH, so a PATH comparison catches all switches.
# Cost: one string comparison per prompt; only calls _update_node_version_cache when PATH changed.
_check_node_version() {
  if [[ "$PATH" != "$_prompt_last_path" ]]; then
    _prompt_last_path="$PATH"
    _update_node_version_cache
  fi
}

autoload -U add-zsh-hook
add-zsh-hook precmd _check_node_version

# Initial cache population
_update_node_version_cache
_prompt_last_path="$PATH"

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
