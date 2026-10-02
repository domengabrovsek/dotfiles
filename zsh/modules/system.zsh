# ============================================================================
# System
# ============================================================================

# --- Aliases ---

alias path='echo $PATH | tr ":" "\n"'
alias reload='source ~/.zshrc'
alias zshrc='code ~/.zshrc'

# Network
alias ports='lsof -i -P | grep LISTEN'

# Linux hosts keep their own `ip` from iproute2, and lack the macOS tools below.
if [[ "$OSTYPE" == darwin* ]]; then
  alias ip='ifconfig | grep "inet " | grep -v 127.0.0.1'
  alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "DNS cache flushed"'
  alias hosts='sudo code /etc/hosts'
fi

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

# --- VS Code ---

alias c.='code .'
alias cr='code -r .'            # Reuse existing window
alias cdiff='code --diff'       # VS Code diff viewer
alias cext='code --list-extensions'  # List installed extensions

# --- Functions ---

# Show weather
weather() {
  local city="${1:-Ljubljana}"
  curl "wttr.in/${city}?format=3"
}

# Show most used commands
hist_stats() {
  history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
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

# --- Help ---

_zhelp_register vscode <<'HELP'
c. / cr       code . / code -r . (reuse window)
cdiff         code --diff
cext          code --list-extensions
HELP

_zhelp_register net <<'HELP'
myip          public IP address
port_check <p>  check if port is in use
kill_port <p>   kill process on port
ports         list listening ports
flushdns      flush macOS DNS cache
ip            show local IP addresses
hosts         edit /etc/hosts (macOS)
HELP

_zhelp_register util <<'HELP'
reload        source ~/.zshrc
zshrc         open zshrc in editor
path          print PATH entries
genpass [len] random password (default: 16)
hist_stats    top 20 most used commands
weather [city]  weather (default: Ljubljana)
now / nowdate / nowtime  current time/date
zhelp [term]  search this list
c / cls       clear screen
grep / egrep / fgrep  coloured output
HELP
