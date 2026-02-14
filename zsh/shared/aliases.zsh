# ============================================================================
# Aliases Configuration
# ============================================================================
# Common aliases shared across work and personal setups

# ============================================================================
# Navigation & Directory Listing
# ============================================================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# List directory contents - use eza if available, otherwise standard ls
if command -v eza &> /dev/null; then
  alias ls='eza --icons'
  alias ll='eza -lh --icons --git'
  alias la='eza -lah --icons --git'
  alias l='eza -F'
  alias lt='eza -lh --icons --git --sort=modified'
  alias tree='eza --tree --icons --git-ignore'
else
  alias ls='ls -G'
  alias ll='ls -lh'
  alias la='ls -lAh'
  alias l='ls -CF'
  alias lt='ls -lhtr'
fi

# Modern cat replacement (if bat is installed)
if command -v bat &> /dev/null; then
  alias cat='bat --paging=never'
  alias catp='bat'  # bat with pager
fi

# ============================================================================
# File Operations
# ============================================================================

alias cp='cp -i'    # Confirm before overwriting
alias mv='mv -i'    # Confirm before overwriting
alias rm='rm -i'    # Confirm before deleting
alias mkdir='mkdir -p'  # Create parent directories as needed

# ============================================================================
# Git Aliases
# ============================================================================

alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias gf='git fetch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --graph --decorate'
alias gloga='git log --oneline --graph --decorate --all'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gm='git merge'
alias gr='git rebase'
alias grc='git rebase --continue'
alias gra='git rebase --abort'

# Modern git commands (git 2.23+ replacements for checkout)
alias gsw='git switch'
alias gswc='git switch -c'
alias grs='git restore'
alias grss='git restore --staged'

# ============================================================================
# Docker Aliases
# ============================================================================

alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dstop='docker stop'
alias drm='docker rm'
alias drmi='docker rmi'
alias dprune='docker system prune -af --volumes'

# Docker Compose
alias dcup='docker compose up'
alias dcupd='docker compose up -d'
alias dcdown='docker compose down'
alias dcbuild='docker compose build'
alias dcps='docker compose ps'
alias dclogs='docker compose logs -f'
alias dcexec='docker compose exec'
alias dcrestart='docker compose restart'

# ============================================================================
# Kubernetes Aliases
# ============================================================================

alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias ka='kubectl apply -f'
alias kl='kubectl logs -f'
alias kx='kubectl exec -it'

# Common kubectl get commands
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'

# Describe shortcuts
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'

# ============================================================================
# NPM / Node.js Aliases
# ============================================================================

alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nun='npm uninstall'
alias nup='npm update'
alias nls='npm list --depth=0'
alias nrun='npm run'
alias nstart='npm start'
alias ntest='npm test'
alias nbuild='npm run build'
alias ndev='npm run dev'

# ============================================================================
# AWS CLI Aliases
# ============================================================================

alias aws-whoami='aws sts get-caller-identity'
alias aws-regions='aws ec2 describe-regions --output table'
alias aws-profile='export AWS_PROFILE='
alias awsp='aws_switch'  # Quick profile switcher
alias awsc='aws_current'  # Show current profile

# ============================================================================
# GCP Aliases
# ============================================================================

alias gcp-whoami='gcloud config get-value account'
alias gcp-project='gcloud config get-value project'
alias gcp-projects='gcloud projects list'
alias gcp-set-project='gcloud config set project'
alias gcpp='gcp_switch'   # Quick profile switcher (like awsp)
alias gcpc='gcp_current'  # Show current profile (like awsc)

# ============================================================================
# Terraform Aliases
# ============================================================================

alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tfw='terraform workspace'

# ============================================================================
# System Utilities
# ============================================================================

alias path='echo $PATH | tr ":" "\n"'
alias reload='source ~/.zshrc'
alias zshrc='code ~/.zshrc'

# Process management
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psgrep='ps aux | grep'

# Network
alias ip='ifconfig | grep "inet " | grep -v 127.0.0.1'
alias ports='lsof -i -P | grep LISTEN'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "DNS cache flushed"'

# Disk usage
alias dus='du -sh * | sort -h'
alias df='df -h'

# ============================================================================
# Miscellaneous
# ============================================================================

# Quick edit hosts file
alias hosts='sudo code /etc/hosts'

# Clear screen
alias c='clear'
alias cls='clear'

# Make grep colorful
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Time and date
alias now='date +"%T"'
alias nowdate='date +"%Y-%m-%d"'
alias nowtime='date +"%Y-%m-%d %T"'

# ============================================================================
# VS Code
# ============================================================================

alias c.='code .'
alias cr='code -r .'            # Reuse existing window
alias cdiff='code --diff'       # VS Code diff viewer
alias cext='code --list-extensions'  # List installed extensions
