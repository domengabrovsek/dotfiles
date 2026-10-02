# ============================================================================
# Node.js
# ============================================================================

# --- Environment ---

# .zshenv already puts nvm's default node on PATH, and Oh My Zsh's nvm plugin
# switches on .nvmrc once nvm loads. This covers the gap before that: a shell
# opened inside a project uses the project's node for child processes.
if [[ -f .nvmrc && -d "$NVM_DIR/versions/node" ]]; then
  _nvm_target=$(<.nvmrc)
  _nvm_node_bin=$(ls -d "$NVM_DIR/versions/node"/v${_nvm_target#v}*/bin 2>/dev/null | sort -V | tail -1)
  [[ -n "$_nvm_node_bin" ]] && export PATH="$_nvm_node_bin:$PATH"
  unset _nvm_target _nvm_node_bin
fi

# --- Aliases ---

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

# --- Functions ---

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

# Show installed global npm packages
npm_globals() {
  npm list -g --depth=0
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

# --- Completion ---

# NPM completion
if command -v npm &> /dev/null; then
  # Lazy load npm completion (faster shell startup)
  _npm_completion() {
    unfunction _npm_completion
    source <(npm completion)
  }
  compdef _npm_completion npm
fi

# --- Help ---

_zhelp_register npm <<'HELP'
ni / nid      npm install / --save-dev
nig / nun     npm install -g / uninstall
nup / nls     npm update / list --depth=0
nrun / ndev   npm run / run dev
nstart / ntest  npm start / test
nbuild        npm run build
cleanup_node  rm node_modules + clear cache
npm_globals   list global packages
npm_init      init project with .nvmrc + .gitignore
HELP
