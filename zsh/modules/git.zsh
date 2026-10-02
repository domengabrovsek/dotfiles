# ============================================================================
# Git
# ============================================================================

# --- Aliases ---

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

# --- Functions ---

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

# Delete merged branches (keeps main, master, develop, current branch, and keep/*)
git_clean_branches() {
  local branches
  branches=$(git branch --merged | grep -v "\*" | grep -v -E "^\s*(main|master|develop)$" | grep -v -E "^\s*keep")

  if [[ -z "$branches" ]]; then
    echo "No branches to delete."
    return 0
  fi

  echo "Branches to delete:"
  echo "$branches"
  echo ""
  read -q "confirm?Delete these branches? (y/n) " || { echo ""; return 0; }
  echo ""
  echo "$branches" | xargs -n 1 git branch -d
}

# Undo last commit (keep changes)
git_undo_commit() {
  git reset --soft HEAD~1
}

# --- fzf pickers ---

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

# --- Help ---

_zhelp_register git <<'HELP'
g             git
gs            git status
ga / gaa      git add / git add .
gc / gcm      git commit / git commit -m
gca           git commit --amend
gp / gpf      git push / push --force-with-lease
gl / gf       git pull / git fetch
gco / gcb     git checkout / checkout -b
gsw / gswc    git switch / switch -c (modern)
grs / grss    git restore / restore --staged (modern)
gb / gbd / gbD  git branch / branch -d / branch -D
gd / gds      git diff / diff --staged
glog / gloga  git log --oneline --graph
gst / gstp / gstl  git stash / stash pop / stash list
gm / gr       git merge / git rebase
grc / gra     rebase --continue / --abort
gnb <name>    create + switch to new branch
qcommit <msg> git add . && commit -m
qpush <msg>   git add . && commit && push
git_tree      log --graph --oneline --all
git_clean_branches  delete merged branches (keeps main/master/develop/keep/*)
git_undo_commit     reset --soft HEAD~1
fbr           fzf branch switcher
flog          fzf git log browser
HELP
