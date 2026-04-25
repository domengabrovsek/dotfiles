#!/usr/bin/env zsh
# Loaded by every zsh invocation, including non-interactive shells (Claude Code,
# editors, cron, CI runners). Pins PATH to nvm's default node version so child
# processes see the right toolchain without sourcing nvm lazily.

export NVM_DIR="$HOME/.nvm"

if [ -s "$NVM_DIR/alias/default" ]; then
  _NVM_DEFAULT="$(cat "$NVM_DIR/alias/default")"
  while [ -f "$NVM_DIR/alias/$_NVM_DEFAULT" ]; do
    _NVM_DEFAULT="$(cat "$NVM_DIR/alias/$_NVM_DEFAULT")"
  done
  if [ -d "$NVM_DIR/versions/node/v$_NVM_DEFAULT" ]; then
    export PATH="$NVM_DIR/versions/node/v$_NVM_DEFAULT/bin:$PATH"
  else
    _NVM_LATEST="$(ls -1 "$NVM_DIR/versions/node" 2>/dev/null | grep "^v$_NVM_DEFAULT" | sort -V | tail -1)"
    [ -n "$_NVM_LATEST" ] && export PATH="$NVM_DIR/versions/node/$_NVM_LATEST/bin:$PATH"
  fi
  unset _NVM_DEFAULT _NVM_LATEST
fi
