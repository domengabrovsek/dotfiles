# ============================================================================
# Custom Functions
# ============================================================================
# Useful shell functions shared across work and personal setups

# ============================================================================
# Help System
# ============================================================================

# Build a searchable list of all custom commands
_zhelp_data() {
  cat <<'HELP'
[git]       g             git
[git]       gs            git status
[git]       ga / gaa      git add / git add .
[git]       gc / gcm      git commit / git commit -m
[git]       gca           git commit --amend
[git]       gp / gpf      git push / push --force-with-lease
[git]       gl / gf       git pull / git fetch
[git]       gco / gcb     git checkout / checkout -b
[git]       gsw / gswc    git switch / switch -c (modern)
[git]       grs / grss    git restore / restore --staged (modern)
[git]       gb / gbd      git branch / branch -d
[git]       gd / gds      git diff / diff --staged
[git]       glog / gloga  git log --oneline --graph
[git]       gst / gstp    git stash / stash pop
[git]       gm / gr       git merge / git rebase
[git]       grc / gra     rebase --continue / --abort
[git]       gnb <name>    create + switch to new branch
[git]       qcommit <msg> git add . && commit -m
[git]       qpush <msg>   git add . && commit && push
[git]       git_tree      log --graph --oneline --all
[git]       git_clean_branches  delete merged branches
[git]       git_undo_commit     reset --soft HEAD~1
[git]       fbr           fzf branch switcher
[git]       flog          fzf git log browser
[docker]    d / dc        docker / docker compose
[docker]    dps / dpsa    docker ps / ps -a
[docker]    di / dex      docker images / exec -it
[docker]    dlogs / dstop docker logs -f / stop
[docker]    drm / drmi    docker rm / rmi
[docker]    dprune        docker system prune -af --volumes
[docker]    dcup / dcupd  compose up / up -d
[docker]    dcdown        compose down
[docker]    dcbuild       compose build
[docker]    dcps / dclogs compose ps / logs -f
[docker]    dcexec        compose exec
[docker]    dcrestart     compose restart
[docker]    dsh <ctr>     exec into container (bash/sh)
[docker]    docker_stop_all       stop all containers
[docker]    docker_clean_images   remove dangling images
[docker]    docker_nuke           full cleanup (with confirm)
[docker]    docker_disk_usage     show disk usage
[k8s]       k / kg / kd   kubectl / get / describe
[k8s]       kdel / ka     kubectl delete / apply -f
[k8s]       kl / kx       kubectl logs -f / exec -it
[k8s]       kgp / kgs     get pods / services
[k8s]       kgd / kgn     get deployments / nodes
[k8s]       kgns          get namespaces
[k8s]       kdp / kds     describe pod / service
[k8s]       kdd           describe deployment
[k8s]       klogp <ns> <pod>   logs with namespace
[k8s]       kexecp <ns> <pod>  exec into pod
[k8s]       kctx [ctx]    switch kubectl context
[k8s]       kns [ns]      switch kubectl namespace
[npm]       ni / nid      npm install / --save-dev
[npm]       nig / nun     npm install -g / uninstall
[npm]       nup / nls     npm update / list --depth=0
[npm]       nrun / ndev   npm run / run dev
[npm]       nstart / ntest  npm start / test
[npm]       nbuild        npm run build
[npm]       cleanup_node  rm node_modules + clear cache
[npm]       npm_globals   list global packages
[npm]       npm_init      init project with .nvmrc + .gitignore
[aws]       aws-whoami    sts get-caller-identity
[aws]       awsp / awsc   switch profile / show current
[aws]       aws_switch    interactive profile switcher
[aws]       aws_current   show current profile + identity
[aws]       s3_list_buckets  list buckets with sizes
[terraform] tf / tfi      terraform / init
[terraform] tfp / tfa     plan / apply
[terraform] tfd / tfv     destroy / validate
[terraform] tff / tfw     fmt / workspace
[gcp]       gcp-whoami    gcloud config get-value account
[gcp]       gcp-project   gcloud config get-value project
[gcp]       gcp-projects  gcloud projects list
[gcp]       gcpp / gcpc   switch profile / show current
[gcp]       gcp_switch    interactive profile switcher
[gcp]       gcp_current   show current profile + identity
[nav]       .. / ... / ....  cd up 1/2/3 levels
[nav]       z <dir>       smart jump (zoxide)
[nav]       zi            interactive dir picker (zoxide+fzf)
[nav]       mkcd <dir>    mkdir + cd
[nav]       up [n]        go up n directories
[files]     ls / ll / la  eza with icons + git
[files]     lt / tree     sort by modified / tree view
[files]     cat / catp    bat (syntax highlight) / with pager
[files]     ff <name>     find file by name
[files]     fdir <name>   find directory by name
[files]     extract <f>   extract any archive
[files]     backup <f>    timestamped backup copy
[files]     dirsize [dir] show directory size
[vscode]    c. / cr       code . / code -r . (reuse window)
[vscode]    cdiff         code --diff
[vscode]    cext          code --list-extensions
[net]       myip          public IP address
[net]       port_check <p>  check if port is in use
[net]       kill_port <p>   kill process on port
[net]       ports         list listening ports
[net]       flushdns      flush macOS DNS cache
[net]       ip            show local IP addresses
[util]      reload        source ~/.zshrc
[util]      zshrc         open zshrc in editor
[util]      path          print PATH entries
[util]      genpass [len] random password (default: 16)
[util]      hist_stats    top 20 most used commands
[util]      weather [city]  weather (default: Ljubljana)
[util]      now / nowdate / nowtime  current time/date
[fzf]       Ctrl+R        fuzzy history search
[fzf]       Ctrl+T        fuzzy file finder
[fzf]       Alt+C         fuzzy cd into subdir
[config]    zsh_mode      show current mode
[config]    zsh_switch    switch work/personal mode
[config]    zsh_welcome   show welcome message
HELP
}

# Main help: no args = show all (or fzf if available), with args = filter
zhelp() {
  if [[ -n "$1" ]]; then
    _zhelp_data | grep -i "$1"
  elif command -v fzf >/dev/null 2>&1; then
    _zhelp_data | fzf --height 50% --reverse --border --header="Type to search commands (ESC to close)"
  else
    _zhelp_data | less -R
  fi
}

# ============================================================================
# Welcome/Greeting Functions
# ============================================================================

# Display welcome message with system info
zsh_welcome() {
  # Configurable name (override in ~/.zshrc.local with: export ZSH_USER_NAME="Your Name")
  local user_name="${ZSH_USER_NAME:-Domen}"

  # Time-based greeting
  local hour=$(date +%H)
  local greeting
  if [[ $hour -lt 12 ]]; then
    greeting="Good morning"
  elif [[ $hour -lt 18 ]]; then
    greeting="Good afternoon"
  else
    greeting="Good evening"
  fi

  local mode_icon
  local mode_color
  local mode_message

  if [[ "$ZSH_CONFIG_MODE" == "work" ]]; then
    mode_icon="🏢"
    mode_color="%F{blue}"
    mode_message="Time to get things done!"
  else
    mode_icon="🏠"
    mode_color="%F{green}"
    mode_message="Happy coding!"
  fi

  echo ""
  echo "╔════════════════════════════════════════════════════════════════╗"
  print -P "║     ${greeting}, %F{cyan}${user_name}%f! Welcome back 👋                       ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""

  # Show current mode
  print -P "${mode_icon} Mode: ${mode_color}${ZSH_CONFIG_MODE}%f - ${mode_message}"

  # Show Node.js version if available
  if command -v node >/dev/null 2>&1; then
    print -P "⬢  Node.js: %F{yellow}$(node -v)%f"
  fi

  # Show current directory
  print -P "📂 Directory: %F{cyan}%~%f"

  # Show git branch if in a git repo
  if git rev-parse --git-dir > /dev/null 2>&1; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then
      print -P "±  Git branch: %F{red}${branch}%f"
    fi
  fi

  # Show current date and time
  print -P "🕐 Time: %F{magenta}$(date '+%A, %B %d, %Y - %H:%M')%f"

  echo ""
  print -P "%F{240}💡 Type 'zhelp' to see available commands%f"
  print -P "%F{240}⚙️  Type 'zsh_switch' to change modes%f"
  echo ""
}

# Show loading progress (called from .zshrc)
zsh_loading_message() {
  local component="$1"
  local icon="$2"

  if [[ -z "$icon" ]]; then
    icon="📦"
  fi

  print -P "%F{240}${icon} Loading ${component}...%f"
}

# ============================================================================
# Node.js / NPM Functions
# ============================================================================

# Clean up node_modules and npm cache
cleanup_node() {
  echo "🧹 Starting cleanup of Node.js projects..."

  # Remove node_modules directories and show paths
  find . -name "node_modules" -type d -prune | while read dir; do
    echo "📦 Removing: $dir"
    rm -rf "$dir"
  done

  # Clear npm cache
  echo "📦 Clearing npm cache..."
  npm cache clean --force

  echo "✨ Cleanup complete!"
}

# Find and remove all node_modules in current directory tree and show size saved
cleanup_node_with_size() {
  echo "🧹 Calculating size of node_modules directories..."

  local total_size=$(du -sh $(find . -name "node_modules" -type d -prune) 2>/dev/null | awk '{sum+=$1} END {print sum}')

  if [[ -z "$total_size" || "$total_size" == "0" ]]; then
    echo "No node_modules directories found."
    return
  fi

  echo "📦 Total size to be freed: ${total_size}"
  echo "🗑️  Removing node_modules directories..."

  find . -name "node_modules" -type d -prune | while read dir; do
    echo "  Removing: $dir"
    rm -rf "$dir"
  done

  npm cache clean --force
  echo "✨ Cleanup complete! Freed approximately ${total_size}."
}

# Show installed global npm packages
npm_globals() {
  npm list -g --depth=0
}

# Update all global npm packages
npm_update_globals() {
  npm update -g
}

# Initialize a new Node.js project with sensible defaults
npm_init() {
  npm init -y
  echo "📦 Package.json created!"

  if [[ -f ".nvmrc" ]]; then
    echo "✓ .nvmrc already exists"
  else
    node -v > .nvmrc
    echo "✓ Created .nvmrc with current Node version"
  fi

  if [[ -f ".gitignore" ]]; then
    echo "✓ .gitignore already exists"
  else
    echo "node_modules/\n.env\n.DS_Store\ndist/\nbuild/\n*.log" > .gitignore
    echo "✓ Created .gitignore"
  fi
}

# ============================================================================
# Docker Functions
# ============================================================================

# Stop all running containers
docker_stop_all() {
  docker stop $(docker ps -q)
}

# Remove all stopped containers
docker_clean_containers() {
  docker rm $(docker ps -aq)
}

# Remove all dangling images
docker_clean_images() {
  docker rmi $(docker images -f "dangling=true" -q)
}

# Complete Docker cleanup (containers, images, volumes, networks)
docker_nuke() {
  echo "⚠️  This will remove all Docker containers, images, volumes, and networks!"
  echo -n "Are you sure? (y/N): "
  read confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    docker system prune -af --volumes
    echo "✨ Docker cleanup complete!"
  else
    echo "Cancelled."
  fi
}

# Show Docker disk usage
docker_disk_usage() {
  docker system df -v
}

# Enter a running container with sh or bash
dsh() {
  if [[ -z "$1" ]]; then
    echo "Usage: dsh <container_name_or_id>"
    return 1
  fi

  # Try bash first, fall back to sh
  docker exec -it "$1" bash 2>/dev/null || docker exec -it "$1" sh
}

# ============================================================================
# Git Functions
# ============================================================================

# Create a new branch and switch to it
gnb() {
  if [[ -z "$1" ]]; then
    echo "Usage: gnb <branch_name>"
    return 1
  fi
  git checkout -b "$1"
}

# Quick commit with message
qcommit() {
  if [[ -z "$1" ]]; then
    echo "Usage: qcommit <message>"
    return 1
  fi
  git add .
  git commit -m "$1"
}

# Quick commit and push
qpush() {
  if [[ -z "$1" ]]; then
    echo "Usage: qpush <message>"
    return 1
  fi
  git add .
  git commit -m "$1"
  git push
}

# Show git branch in tree format
git_tree() {
  git log --graph --oneline --all --decorate
}

# Delete merged branches
git_clean_branches() {
  git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | xargs -n 1 git branch -d
}

# Undo last commit (keep changes)
git_undo_commit() {
  git reset --soft HEAD~1
}

# ============================================================================
# Directory & File Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Go up N directories
up() {
  local d=""
  local limit=${1:-1}
  for ((i=1; i<=limit; i++)); do
    d="../$d"
  done
  cd $d
}

# Find file by name
ff() {
  find . -type f -name "*$1*"
}

# Find directory by name (named fdir to avoid shadowing fd-find)
fdir() {
  find . -type d -name "*$1*"
}

# Extract any archive type
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <archive_file>"
    return 1
  fi

  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ============================================================================
# Kubernetes Functions
# ============================================================================

# Note: kgpa (get pods all namespaces) is provided by Oh My Zsh kubectl plugin

# Get pod logs with namespace
klogp() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: klogp <namespace> <pod_name>"
    return 1
  fi
  kubectl logs -f -n "$1" "$2"
}

# Execute command in pod
kexecp() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: kexecp <namespace> <pod_name>"
    return 1
  fi
  kubectl exec -it -n "$1" "$2" -- sh
}

# Switch kubectl context
kctx() {
  if [[ -z "$1" ]]; then
    kubectl config get-contexts
  else
    kubectl config use-context "$1"
  fi
}

# Switch kubectl namespace
kns() {
  if [[ -z "$1" ]]; then
    kubectl get namespaces
  else
    kubectl config set-context --current --namespace="$1"
  fi
}

# ============================================================================
# AWS Functions
# ============================================================================

# Switch AWS profile with interactive selection
aws_switch() {
  # Get list of available profiles
  local profiles=()
  if [[ -f ~/.aws/config ]]; then
    # Extract profiles from ~/.aws/config using grep and sed
    while IFS= read -r profile_name; do
      if [[ -n "$profile_name" ]]; then
        profiles+=("$profile_name")
      fi
    done < <(grep -E '^\[profile ' ~/.aws/config | sed 's/\[profile \(.*\)\]/\1/')

    # Check for [default] section
    if grep -q '^\[default\]' ~/.aws/config; then
      profiles+=("default")
    fi
  fi

  # Also check ~/.aws/credentials for additional profiles
  if [[ -f ~/.aws/credentials ]]; then
    while IFS= read -r profile_name; do
      if [[ -n "$profile_name" ]]; then
        # Add if not already in array
        if [[ ! " ${profiles[@]} " =~ " ${profile_name} " ]]; then
          profiles+=("$profile_name")
        fi
      fi
    done < <(grep -E '^\[' ~/.aws/credentials | sed 's/\[\(.*\)\]/\1/')
  fi

  # If no argument provided, show interactive selection
  if [[ -z "$1" ]]; then
    if [[ ${#profiles[@]} -eq 0 ]]; then
      echo "❌ No AWS profiles found in ~/.aws/config or ~/.aws/credentials"
      return 1
    fi

    echo "☁️  Available AWS Profiles:"
    echo ""

    # Show current profile
    if [[ -n "$AWS_PROFILE" ]]; then
      echo "   Current: %F{green}$AWS_PROFILE%f (active)" | sed 's/%F{green}/\x1b[32m/g' | sed 's/%f/\x1b[0m/g'
    else
      echo "   Current: (none set)"
    fi
    echo ""

    # List all profiles with numbers
    local i=1
    for profile in "${profiles[@]}"; do
      if [[ "$profile" == "$AWS_PROFILE" ]]; then
        printf "   \x1b[32m%2d) %s ✓\x1b[0m\n" $i "$profile"
      else
        printf "   %2d) %s\n" $i "$profile"
      fi
      ((i++))
    done

    echo ""
    echo "   0) Clear profile (unset AWS_PROFILE)"
    echo ""
    echo -n "Select profile number (or press Enter to cancel): "
    read selection

    # Handle selection
    if [[ -z "$selection" ]]; then
      echo "Cancelled."
      return 0
    elif [[ "$selection" == "0" ]]; then
      unset AWS_PROFILE
      echo "✓ Cleared AWS_PROFILE"
      return 0
    elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#profiles[@]} ]]; then
      local selected_profile="${profiles[$selection]}"
      export AWS_PROFILE="$selected_profile"
      echo ""
      echo "✓ Switched to AWS profile: $selected_profile"
      echo ""

      # Show caller identity if AWS CLI is available
      if command -v aws &> /dev/null; then
        echo "Verifying credentials..."
        if aws sts get-caller-identity 2>/dev/null; then
          echo ""
          echo "✓ Profile verified successfully!"
        else
          echo "⚠️  Warning: Could not verify credentials. Check your AWS configuration."
        fi
      fi
    else
      echo "❌ Invalid selection: $selection"
      return 1
    fi
  else
    # Direct profile switch (legacy behavior)
    local profile_name="$1"

    # Check if profile exists
    if [[ ! " ${profiles[@]} " =~ " ${profile_name} " ]]; then
      echo "❌ Profile '$profile_name' not found."
      echo ""
      echo "Available profiles:"
      for profile in "${profiles[@]}"; do
        echo "  - $profile"
      done
      return 1
    fi

    export AWS_PROFILE="$profile_name"
    echo "✓ Switched to AWS profile: $profile_name"

    # Show caller identity if AWS CLI is available
    if command -v aws &> /dev/null; then
      aws sts get-caller-identity 2>/dev/null || echo "⚠️  Could not verify credentials"
    fi
  fi
}

# Quick alias to show current AWS profile
aws_current() {
  if [[ -n "$AWS_PROFILE" ]]; then
    echo "Current AWS Profile: $AWS_PROFILE"
    if command -v aws &> /dev/null; then
      echo ""
      aws sts get-caller-identity 2>/dev/null || echo "⚠️  Could not verify credentials"
    fi
  else
    echo "No AWS profile set (using default credentials)"
  fi
}

# List S3 buckets with human-readable sizes
s3_list_buckets() {
  aws s3 ls | while read -r line; do
    bucket_name=$(echo $line | awk '{print $3}')
    bucket_size=$(aws s3 ls s3://$bucket_name --recursive --summarize | grep "Total Size" | awk '{print $3}')
    echo "$bucket_name: $bucket_size bytes"
  done
}

# ============================================================================
# GCP Functions
# ============================================================================

# Switch GCP configuration with interactive selection
gcp_switch() {
  local configs=()
  local active_config

  # Get list of configurations
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      configs+=("$line")
    fi
  done < <(gcloud config configurations list --format="value(name)" 2>/dev/null)

  active_config=$(gcloud config configurations list --filter="IS_ACTIVE=true" --format="value(name)" 2>/dev/null)

  # If no argument provided, show interactive selection
  if [[ -z "$1" ]]; then
    if [[ ${#configs[@]} -eq 0 ]]; then
      echo "No GCP configurations found."
      echo ""
      echo "Create one with: gcloud config configurations create <name>"
      return 1
    fi

    echo "GCP Configurations:"
    echo ""

    if [[ -n "$active_config" ]]; then
      local active_project=$(gcloud config get-value project 2>/dev/null)
      echo "   Current: \x1b[32m${active_config}\x1b[0m (project: ${active_project:-none})"
    fi
    echo ""

    # List all configs with numbers
    local i=1
    for config in "${configs[@]}"; do
      local project=$(gcloud config configurations describe "$config" --format="value(properties.core.project)" 2>/dev/null)
      if [[ "$config" == "$active_config" ]]; then
        printf "   \x1b[32m%2d) %s (project: %s) ✓\x1b[0m\n" $i "$config" "${project:-none}"
      else
        printf "   %2d) %s (project: %s)\n" $i "$config" "${project:-none}"
      fi
      ((i++))
    done

    echo ""
    echo -n "Select configuration number (or press Enter to cancel): "
    read selection

    # Handle selection
    if [[ -z "$selection" ]]; then
      echo "Cancelled."
      return 0
    elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#configs[@]} ]]; then
      local selected="${configs[$selection]}"
      gcloud config configurations activate "$selected" 2>/dev/null
      _update_gcp_config_cache
      echo ""
      echo "Switched to GCP configuration: $selected"
      gcp_current
    else
      echo "Invalid selection: $selection"
      return 1
    fi
  else
    # Direct config switch
    if gcloud config configurations activate "$1" 2>/dev/null; then
      _update_gcp_config_cache
      echo "Switched to GCP configuration: $1"
      gcp_current
    else
      echo "Configuration '$1' not found."
      echo ""
      echo "Available configurations:"
      gcloud config configurations list --format="table(name, is_active, properties.core.project, properties.core.account)" 2>/dev/null
      return 1
    fi
  fi
}

# Show current GCP profile and identity
gcp_current() {
  local config=$(gcloud config configurations list --filter="IS_ACTIVE=true" --format="value(name)" 2>/dev/null)
  local project=$(gcloud config get-value project 2>/dev/null)
  local account=$(gcloud config get-value account 2>/dev/null)
  local region=$(gcloud config get-value compute/region 2>/dev/null)

  echo ""
  echo "GCP Configuration: ${config:-default}"
  echo "  Account: ${account:-(not set)}"
  echo "  Project: ${project:-(not set)}"
  echo "  Region:  ${region:-(not set)}"
}

# ============================================================================
# fzf-powered Functions (requires: brew install fzf)
# ============================================================================

# Interactive git branch switcher
fbr() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required. Install with: brew install fzf"
    return 1
  fi
  local branch
  branch=$(git branch --all --sort=-committerdate | fzf --height 40% --reverse) || return
  branch=$(echo "$branch" | sed 's/^[* ]*//' | sed 's|^remotes/origin/||')
  git switch "$branch" 2>/dev/null || git switch -c "$branch" --track "origin/$branch"
}

# Interactive git log browser
flog() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required. Install with: brew install fzf"
    return 1
  fi
  git log --oneline --graph --decorate --all | fzf --preview 'git show {+1}' --no-sort
}

# ============================================================================
# Utility Functions
# ============================================================================

# Show weather
weather() {
  local city="${1:-Ljubljana}"
  curl "wttr.in/${city}?format=3"
}

# Create a backup of a file
backup() {
  if [[ -z "$1" ]]; then
    echo "Usage: backup <file>"
    return 1
  fi
  cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# Show most used commands
hist_stats() {
  history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
}

# Show directory size
dirsize() {
  du -sh "${1:-.}" | awk '{print $1}'
}

# Generate random password
genpass() {
  local length="${1:-16}"
  openssl rand -base64 48 | cut -c1-${length}
}

# Show public IP
myip() {
  curl -s ifconfig.me
}

# Port check - check if a port is open
port_check() {
  if [[ -z "$1" ]]; then
    echo "Usage: port_check <port>"
    return 1
  fi
  lsof -i :"$1"
}

# Kill process on port
kill_port() {
  if [[ -z "$1" ]]; then
    echo "Usage: kill_port <port>"
    return 1
  fi
  lsof -ti:"$1" | xargs kill -9
}
