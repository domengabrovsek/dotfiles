# ============================================================================
# Prompt Configuration
# ============================================================================
# Custom prompt with git info and Node.js version

# Custom prompt function to show Node.js version
function node_version() {
  if command -v node >/dev/null 2>&1; then
    echo "%F{yellow}⬢ $(node -v)%f"
  fi
}

# Custom prompt function to show AWS profile
function aws_profile() {
  if [[ -n "$AWS_PROFILE" ]]; then
    echo "%F{208}☁︎ $AWS_PROFILE%f "
  elif [[ -n "$AWS_DEFAULT_PROFILE" ]]; then
    echo "%F{208}☁︎ $AWS_DEFAULT_PROFILE%f "
  fi
}

# Custom prompt - using full path (%~ instead of %c) and git icon (±)
PROMPT='%{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)$(aws_profile)$(node_version) %{$fg[blue]%}→%{$reset_color%} '

# Git prompt settings with icon
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}±(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
