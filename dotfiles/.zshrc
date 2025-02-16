# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Enable autocompletion
autoload -Uz compinit
compinit

# Generate completion for aliases
setopt COMPLETE_ALIASES

# Plugins
plugins=(
  git
  docker
  docker-compose
  npm
  nvm
  node
  kubectl
  terraform
)

source $ZSH/oh-my-zsh.sh

# Custom prompt function to show Node.js version
function node_version() {
  if command -v node >/dev/null 2>&1; then
    echo "%F{yellow}⬢ $(node -v)%f"
  fi
}

# Custom prompt - using full path (%~ instead of %c) and git icon (±)
PROMPT='%{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)$(node_version) %{$fg[blue]%}→%{$reset_color%} '

# Git prompt settings with icon
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}±(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

# User configuration

# Load aliases file
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# Create completion cache directory
zstyle ':completion:*' cache-path ~/.zsh/cache

# Function to clean up node_modules and npm cache
cleanup_node() {
    echo "🧹 Starting cleanup of Node.js projects..."
    
    # Remove node_modules directories and show paths
    find . -name "node_modules" -type d -prune | while read dir; do
        echo "📦 Removing: $dir"
        rm -rf "$dir"
    done
    
    # Clear npm cache
    echo "📦 Removing npm cache ..."
    npm cache clean --force

    echo "✨ Cleanup complete!"
}

# Add completion for custom functions
compdef _gnu_generic cleanup-node

# import z
. /Users/domengabrovsek/z.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# AWS
export AWS_REGION=eu-central-1

# nvm
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion