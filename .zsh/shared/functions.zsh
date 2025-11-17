# ============================================================================
# Custom Functions
# ============================================================================
# Useful shell functions shared across work and personal setups

# ============================================================================
# Help System
# ============================================================================

# Main help function - shows available commands, aliases, and functions
zhelp() {
  local category="${1:-all}"

  case "$category" in
    all)
      echo "╔════════════════════════════════════════════════════════════════╗"
      echo "║          Zsh Configuration Help - Available Commands          ║"
      echo "╚════════════════════════════════════════════════════════════════╝"
      echo ""
      echo "Current mode: $ZSH_CONFIG_MODE"
      echo ""
      echo "📚 Available help categories:"
      echo "  zhelp aliases    - Show all aliases"
      echo "  zhelp functions  - Show all functions"
      echo "  zhelp git        - Git aliases and functions"
      echo "  zhelp docker     - Docker aliases and functions"
      echo "  zhelp k8s        - Kubernetes aliases and functions"
      echo "  zhelp node       - Node.js/NPM aliases and functions"
      echo "  zhelp aws        - AWS aliases and functions"
      echo "  zhelp utils      - Utility functions"
      echo ""
      echo "🔍 Search for specific command:"
      echo "  zhelp search <term>  - Search aliases and functions"
      echo ""
      echo "📋 Quick Reference:"
      echo "  cat ~/.zsh/CHEATSHEET.md       - View cheat sheet with most used commands"
      echo "  cat ~/.zsh/AWS_GUIDE.md        - AWS profile management guide"
      echo "  cat ~/.zsh/AUTOSUGGESTIONS.md  - Autosuggestions guide"
      echo ""
      echo "⚙️  Configuration:"
      echo "  zsh_mode         - Check current mode (work/personal)"
      echo "  zsh_switch       - Switch between work and personal modes"
      echo "  reload           - Reload zsh configuration"
      echo "  zsh_welcome      - Show welcome message again"
      echo ""
      echo "🎨 Customization:"
      echo "  Set ZSH_DISABLE_WELCOME=1 in ~/.zshrc.local to disable welcome"
      ;;

    aliases)
      _zhelp_aliases
      ;;

    functions)
      _zhelp_functions
      ;;

    git)
      _zhelp_git
      ;;

    docker)
      _zhelp_docker
      ;;

    k8s|kubectl|kubernetes)
      _zhelp_kubernetes
      ;;

    node|npm|nvm)
      _zhelp_node
      ;;

    aws)
      _zhelp_aws
      ;;

    utils|utilities)
      _zhelp_utils
      ;;

    search)
      if [[ -z "$2" ]]; then
        echo "Usage: zhelp search <term>"
        return 1
      fi
      _zhelp_search "$2"
      ;;

    *)
      echo "Unknown category: $category"
      echo "Run 'zhelp' to see available categories"
      return 1
      ;;
  esac
}

# Show all aliases
_zhelp_aliases() {
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║                      All Available Aliases                     ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "💡 Tip: Use 'zhelp git', 'zhelp docker', etc. for categorized help"
  echo ""
  alias | column -t -s='=' | sort
}

# Show all functions
_zhelp_functions() {
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║                    All Available Functions                     ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "Custom functions (type function name followed by -h or without args for help):"
  echo ""
  # List all functions defined in this shell
  print -l ${(ok)functions} | grep -v "^_" | grep -v "^compdef" | grep -v "^prompt" | column
}

# Git help
_zhelp_git() {
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║                     Git Aliases & Functions                    ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "📝 Basic Commands:"
  echo "  g          → git"
  echo "  gs         → git status"
  echo "  ga         → git add"
  echo "  gaa        → git add ."
  echo "  gc         → git commit"
  echo "  gcm        → git commit -m"
  echo "  gca        → git commit --amend"
  echo ""
  echo "🔄 Push/Pull:"
  echo "  gp         → git push"
  echo "  gpf        → git push --force-with-lease"
  echo "  gl         → git pull"
  echo "  gf         → git fetch"
  echo ""
  echo "🌿 Branches:"
  echo "  gb         → git branch"
  echo "  gco        → git checkout"
  echo "  gcb        → git checkout -b"
  echo "  gbd        → git branch -d"
  echo "  gbD        → git branch -D"
  echo ""
  echo "📊 Viewing:"
  echo "  gd         → git diff"
  echo "  gds        → git diff --staged"
  echo "  glog       → git log --oneline --graph --decorate"
  echo "  gloga      → git log --oneline --graph --decorate --all"
  echo ""
  echo "💾 Stash:"
  echo "  gst        → git stash"
  echo "  gstp       → git stash pop"
  echo "  gstl       → git stash list"
  echo ""
  echo "🔀 Merge/Rebase:"
  echo "  gm         → git merge"
  echo "  gr         → git rebase"
  echo "  grc        → git rebase --continue"
  echo "  gra        → git rebase --abort"
  echo ""
  echo "🔧 Functions:"
  echo "  gnb <name>        → Create new branch and switch to it"
  echo "  qcommit <msg>     → Quick add all and commit"
  echo "  qpush <msg>       → Quick commit and push"
  echo "  git_tree          → Show branch tree"
  echo "  git_clean_branches → Delete merged branches"
  echo "  git_undo_commit   → Undo last commit (keep changes)"
}

# Docker help
_zhelp_docker() {
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║                   Docker Aliases & Functions                   ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "🐳 Basic Commands:"
  echo "  d          → docker"
  echo "  dc         → docker compose"
  echo "  dps        → docker ps"
  echo "  dpsa       → docker ps -a"
  echo "  di         → docker images"
  echo "  dex        → docker exec -it"
  echo "  dlogs      → docker logs -f"
  echo "  dstop      → docker stop"
  echo "  drm        → docker rm"
  echo "  drmi       → docker rmi"
  echo "  dprune     → docker system prune -af --volumes"
  echo ""
  echo "🐙 Docker Compose:"
  echo "  dcup       → docker compose up"
  echo "  dcupd      → docker compose up -d"
  echo "  dcdown     → docker compose down"
  echo "  dcbuild    → docker compose build"
  echo "  dcps       → docker compose ps"
  echo "  dclogs     → docker compose logs -f"
  echo "  dcexec     → docker compose exec"
  echo "  dcrestart  → docker compose restart"
  echo ""
  echo "🔧 Functions:"
  echo "  docker_stop_all       → Stop all running containers"
  echo "  docker_clean_containers → Remove all stopped containers"
  echo "  docker_clean_images   → Remove dangling images"
  echo "  docker_nuke           → Complete Docker cleanup (with confirmation)"
  echo "  docker_disk_usage     → Show Docker disk usage"
  echo "  dsh <container>       → Enter container with bash/sh"
}

# Kubernetes help
_zhelp_kubernetes() {
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║                 Kubernetes Aliases & Functions                 ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "☸️  Basic Commands:"
  echo "  k          → kubectl"
  echo "  kg         → kubectl get"
  echo "  kd         → kubectl describe"
  echo "  kdel       → kubectl delete"
  echo "  ka         → kubectl apply -f"
  echo "  kl         → kubectl logs -f"
  echo "  kx         → kubectl exec -it"
  echo ""
  echo "📦 Get Resources:"
  echo "  kgp        → kubectl get pods"
  echo "  kgs        → kubectl get services"
  echo "  kgd        → kubectl get deployments"
  echo "  kgn        → kubectl get nodes"
  echo "  kgns       → kubectl get namespaces"
  echo ""
  echo "📋 Describe:"
  echo "  kdp        → kubectl describe pod"
  echo "  kds        → kubectl describe service"
  echo "  kdd        → kubectl describe deployment"
  echo ""
  echo "📝 Logs:"
  echo "  klp        → kubectl logs -f pod/"
  echo ""
  echo "🔧 Functions:"
  echo "  klogp <ns> <pod>        → Get pod logs with namespace"
  echo "  kexecp <ns> <pod>       → Execute command in pod"
  echo "  kctx [context]          → Switch kubectl context"
  echo "  kns [namespace]         → Switch kubectl namespace"
  echo ""
  echo "💡 Note: kgpa is provided by Oh My Zsh kubectl plugin"
}

# Node.js help
_zhelp_node() {
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║                  Node.js/NPM Aliases & Functions               ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "📦 NPM Aliases:"
  echo "  ni         → npm install"
  echo "  nid        → npm install --save-dev"
  echo "  nig        → npm install -g"
  echo "  nun        → npm uninstall"
  echo "  nup        → npm update"
  echo "  nls        → npm list --depth=0"
  echo "  nrun       → npm run"
  echo "  nstart     → npm start"
  echo "  ntest      → npm test"
  echo "  nbuild     → npm run build"
  echo "  ndev       → npm run dev"
  echo ""
  echo "⚡ pnpm Aliases:"
  echo "  pi         → pnpm install"
  echo "  pa         → pnpm add"
  echo "  pad        → pnpm add -D"
  echo "  pr         → pnpm remove"
  echo "  prun       → pnpm run"
  echo "  pstart     → pnpm start"
  echo "  ptest      → pnpm test"
  echo "  pbuild     → pnpm run build"
  echo "  pdev       → pnpm run dev"
  echo ""
  echo "🧶 Yarn Aliases:"
  echo "  yi         → yarn install"
  echo "  ya         → yarn add"
  echo "  yad        → yarn add --dev"
  echo "  yr         → yarn remove"
  echo "  yrun       → yarn run"
  echo "  ystart     → yarn start"
  echo "  ytest      → yarn test"
  echo "  ybuild     → yarn build"
  echo "  ydev       → yarn dev"
  echo ""
  echo "🔧 Functions:"
  echo "  cleanup_node              → Remove node_modules and clear npm cache"
  echo "  cleanup_node_with_size    → Same but shows size freed"
  echo "  npm_globals               → List global npm packages"
  echo "  npm_update_globals        → Update all global packages"
  echo "  npm_init                  → Initialize new Node.js project with defaults"
}

# AWS help
_zhelp_aws() {
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║                     AWS Aliases & Functions                    ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "☁️  AWS Aliases:"
  echo "  aws-whoami     → aws sts get-caller-identity"
  echo "  aws-regions    → aws ec2 describe-regions --output table"
  echo "  awsp           → Interactive AWS profile switcher (alias for aws_switch)"
  echo "  awsc           → Show current AWS profile (alias for aws_current)"
  echo ""
  echo "🔧 Functions:"
  echo "  aws_switch [profile]    → Switch AWS profile interactively"
  echo "                            (no args = show menu, or specify profile name)"
  echo "  aws_current             → Show current AWS profile and identity"
  echo "  s3_list_buckets         → List S3 buckets with sizes"
  echo ""
  echo "💡 Prompt:"
  echo "  Current AWS profile is shown in your prompt: ☁︎ profile-name"
}

# Utilities help
_zhelp_utils() {
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║                      Utility Functions                         ║"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  echo "📂 Navigation & Files:"
  echo "  mkcd <dir>        → Create directory and cd into it"
  echo "  up [n]            → Go up n directories (default: 1)"
  echo "  ff <name>         → Find file by name"
  echo "  fd <name>         → Find directory by name"
  echo "  extract <file>    → Extract any archive type"
  echo ""
  echo "🌐 Network:"
  echo "  myip              → Show public IP address"
  echo "  port_check <port> → Check if port is in use"
  echo "  kill_port <port>  → Kill process on specified port"
  echo ""
  echo "🔧 System:"
  echo "  backup <file>     → Create timestamped backup of file"
  echo "  dirsize [path]    → Show directory size"
  echo "  genpass [length]  → Generate random password (default: 16)"
  echo "  hist_stats        → Show most used commands"
  echo ""
  echo "🌤️  Fun:"
  echo "  weather [city]    → Show weather (default: Ljubljana)"
  echo ""
  echo "📁 Navigation Aliases:"
  echo "  ..        → cd .."
  echo "  ...       → cd ../.."
  echo "  ....      → cd ../../.."
  echo "  .....     → cd ../../../.."
  echo ""
  echo "📋 Listing Aliases:"
  echo "  ll        → ls -lh"
  echo "  la        → ls -lAh"
  echo "  lt        → ls -lhtr (sort by time)"
}

# Search function
_zhelp_search() {
  local search_term="$1"
  echo "🔍 Searching for: $search_term"
  echo ""
  echo "Aliases:"
  alias | grep -i "$search_term" | column -t -s='='
  echo ""
  echo "Functions:"
  print -l ${(ok)functions} | grep -v "^_" | grep -i "$search_term"
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

# Find directory by name
fd() {
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
