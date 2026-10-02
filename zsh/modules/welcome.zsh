# ============================================================================
# Welcome
# ============================================================================

# --- Banner ---

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

  echo ""
  local box_width=62
  local text="${greeting}, ${user_name}! Welcome back"
  # Display width: text chars + space before emoji (1) + emoji display width (2)
  local display_width=$((${#text} + 3))
  local pad_left=5
  local pad_right=$((box_width - pad_left - display_width))

  printf '╔'; printf '═%.0s' {1..$box_width}; printf '╗\n'
  printf '║%*s' $pad_left ''
  print -Pn "${greeting}, %F{cyan}${user_name}%f! Welcome back 👋"
  printf '%*s║\n' $pad_right ''
  printf '╚'; printf '═%.0s' {1..$box_width}; printf '╝\n'
  echo ""

  # Running node here would load the lazy nvm wrapper and cost ~350ms, so read
  # the version prompt.zsh already cached.
  if [[ -n "$_cached_node_version" ]]; then
    print -P "⬢  Node.js: %F{yellow}${_cached_node_version}%f"
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
  echo ""
}

# --- Help ---

_zhelp_register config <<'HELP'
zsh_welcome   show welcome message
HELP
