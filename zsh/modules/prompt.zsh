# ============================================================================
# Prompt Configuration
# ============================================================================
# Custom prompt with git info and Node.js / npm versions

# ============================================================================
# Cached Node.js / npm Versions (avoids subprocess on every prompt render)
# ============================================================================

_cached_node_version=""
_cached_npm_version=""
_cached_node_bin_path=""
_prompt_last_path=""

# npm ships its version in its own package.json, so reading that file beats
# running `npm -v`, which pays a full Node startup on every version switch.
_npm_version_from_prefix() {
  local pkg="$1/lib/node_modules/npm/package.json" line
  [[ -r "$pkg" ]] || return 1
  while IFS= read -r line; do
    if [[ "$line" == *'"version"'* ]]; then
      line="${line#*\"version\"}"
      line="${line#*:}"
      line="${line#*\"}"
      echo "${line%%\"*}"
      return 0
    fi
  done < "$pkg"
  return 1
}

_update_node_version_cache() {
  local node_bin npm_bin
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

  # npm bundled with this Node sits under the same prefix as bin/node; fall back
  # to whatever npm PATH resolves to when the layout differs (Homebrew, Volta).
  _cached_npm_version=""
  if [[ -n "$node_bin" ]]; then
    _cached_npm_version="$(_npm_version_from_prefix "${node_bin%/bin/node}")"
  fi
  if [[ -z "$_cached_npm_version" ]]; then
    npm_bin="$(whence -p npm 2>/dev/null)"
    [[ -n "$npm_bin" ]] && _cached_npm_version="$("$npm_bin" -v 2>/dev/null)"
  fi
}

function node_version() {
  if [[ -n "$_cached_node_version" ]]; then
    if [[ -n "$_cached_npm_version" ]]; then
      echo " $(prompt_sep) %F{yellow}⬢ ${_cached_node_version} (${_cached_npm_version})%f"
    else
      echo " $(prompt_sep) %F{yellow}⬢ ${_cached_node_version}%f"
    fi
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
  local profile="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"
  if [[ -n "$profile" ]]; then
    echo " $(prompt_sep) %F{208}☁︎ $profile%f"
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
    # Same glyph as AWS, distinguished by colour: 208 is AWS orange, 33 is
    # Google blue. Two cloud segments read as one idea with two providers.
    echo " $(prompt_sep) %F{33}☁︎ ${_cached_gcp_config}%f"
  fi
}

# Initial cache load
_update_gcp_config_cache

# ============================================================================
# Section Separator
# ============================================================================

# Both dots share one colour, and that colour is used by nothing else in the
# prompt, so section boundaries are findable without reading the content.
# Grey 244 sits behind the segments it divides rather than competing with them.
PROMPT_SEP_COLOR="244"

function prompt_sep() {
  echo "%F{$PROMPT_SEP_COLOR}·%f"
}

# ============================================================================
# Hostname Display
# ============================================================================

# This config is shared across the Mac and the homelab hosts, and every one of
# them is reachable from the others, so the prompt has to say which machine you
# are on. Read at render time, so setting ZSH_PROMPT_HOST in ~/.zshrc.local
# takes effect regardless of load order - needed on macOS, where %m expands to
# the full computer name (Domens-MacBook-Pro) rather than a short one.

function prompt_host() {
  echo "%F{magenta}💻 ${ZSH_PROMPT_HOST:-%m}%f"
}

# ============================================================================
# Prompt Definition
# ============================================================================

# git_prompt_info comes from Oh My Zsh and cannot emit its own separator, so
# wrap it. Outside a repo it returns empty and the dot goes with it.
function git_segment() {
  local info
  info="$(git_prompt_info)"
  if [[ -n "$info" ]]; then
    echo " $(prompt_sep) $info"
  fi
}

# 💻 hostname · 📁 parent/current · ±(branch) · ☁︎ aws · ☁︎ gcp · ⬢ node (npm) →
# Every section carries a glyph, so the eye can find one without reading any of
# the others. Every segment past the directory supplies its own leading
# separator, so a dot only ever appears between two segments that are present.
# %2~ keeps the parent directory, which disambiguates the many same-named leaf
# dirs across repos (src, modules, docs) that %1~ collapsed to one word.
PROMPT='$(prompt_host) $(prompt_sep) %{$fg[cyan]%}📁 %2~%{$reset_color%}$(git_segment)$(aws_profile)$(gcp_profile)$(node_version) %{$fg[blue]%}→%{$reset_color%} '

# Git prompt settings with icon. No trailing space in the suffix - spacing is
# owned by git_segment so the separator logic stays in one place.
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}±(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
