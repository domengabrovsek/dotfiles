# ============================================================================
# Files and Navigation
# ============================================================================

# --- Navigation and listing ---

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
  # -G is the colour flag on BSD ls (macOS) but means "hide the group column" on
  # GNU coreutils, so the flag has to be chosen per implementation rather than
  # assumed. Reached on Debian 12, which does not package eza.
  if ls --color=auto . > /dev/null 2>&1; then
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -lAh --color=auto'
    alias l='ls -CF --color=auto'
    alias lt='ls -lhtr --color=auto'
  else
    alias ls='ls -G'
    alias ll='ls -lhG'
    alias la='ls -lAhG'
    alias l='ls -CFG'
    alias lt='ls -lhtrG'
  fi
fi

# Modern cat replacement (if bat is installed)
# Debian/Ubuntu install the binary as batcat, to avoid a clash with an unrelated
# package that already owns the name bat.
if command -v bat &> /dev/null; then
  alias cat='bat --paging=never'
  alias catp='bat'  # bat with pager
elif command -v batcat &> /dev/null; then
  alias cat='batcat --paging=never'
  alias catp='batcat'
fi

# --- File operations ---

alias cp='cp -i'    # Confirm before overwriting
alias mv='mv -i'    # Confirm before overwriting
alias rm='rm -i'    # Confirm before deleting
alias mkdir='mkdir -p'  # Create parent directories as needed

alias dus='du -sh * | sort -h'
alias df='df -h'

# --- Functions ---

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Go up N directories
up() {
  local d="" i
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

# Create a backup of a file
backup() {
  if [[ -z "$1" ]]; then
    echo "Usage: backup <file>"
    return 1
  fi
  cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# Show directory size
dirsize() {
  du -sh "${1:-.}" | awk '{print $1}'
}

# --- Help ---

_zhelp_register nav <<'HELP'
.. / ... / .... / .....  cd up 1/2/3/4 levels
z <dir>       smart jump (zoxide)
zi            interactive dir picker (zoxide+fzf)
mkcd <dir>    mkdir + cd
up [n]        go up n directories
HELP

_zhelp_register files <<'HELP'
ls / l / ll / la  eza with icons + git
lt / tree     sort by modified / tree view
cat / catp    bat (syntax highlight) / with pager
ff <name>     find file by name
fdir <name>   find directory by name
extract <f>   extract any archive
backup <f>    timestamped backup copy
dirsize [dir] show directory size
cp / mv / rm  ask before overwriting or deleting
mkdir         creates parent directories
dus           sizes of entries here, sorted
df            disk free, human-readable
HELP
