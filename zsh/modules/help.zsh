# ============================================================================
# Help System
# ============================================================================

# Each module registers its commands next to their definitions, so zhelp lists
# what is actually loaded.
typeset -ga _zhelp_entries

# Usage: _zhelp_register <section> <<'HELP' ... HELP
_zhelp_register() {
  local line entry
  while IFS= read -r line; do
    printf -v entry '%-11s %s' "[$1]" "$line"
    _zhelp_entries+=("$entry")
  done
}

_zhelp_data() {
  print -rl -- "${_zhelp_entries[@]}"
}

# No args: fzf if available, else a pager. With args: filter.
zhelp() {
  if [[ -n "$1" ]]; then
    _zhelp_data | grep -i "$1"
  elif command -v fzf >/dev/null 2>&1; then
    _zhelp_data | fzf --height 50% --reverse --border --header="Type to search commands (ESC to close)"
  else
    _zhelp_data | less -R
  fi
}
