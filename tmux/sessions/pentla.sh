#!/usr/bin/env bash
# Builds (or attaches to) the "pentla" tmux session: one window (tab) per repo
# with a defined pane layout, so opening Ghostty always lands the same folders
# in the same splits. Idempotent - re-running just reattaches to the existing
# session. Edit `repos` or the local-env block to change folders/layout.

set -euo pipefail

# Homebrew's tmux is not on PATH when Ghostty launches this script directly.
export PATH="/opt/homebrew/bin:$PATH"

SESSION="pentla"
ROOT="$HOME/dev/pentla"

build_session() {
  # Each of these gets its own tab with two stacked (top/bottom) panes.
  local repos=(pentla pentla-api pentla-frontend pentla-bot pentla-infra pentla-specs)

  for repo in "${repos[@]}"; do
    # The "pentla" repo lives at the root itself, not a nested pentla/pentla.
    local dir
    if [ "$repo" = "pentla" ]; then
      dir="$ROOT"
    else
      dir="$ROOT/$repo"
    fi

    if [ "$repo" = "pentla" ]; then
      tmux new-session -d -s "$SESSION" -n "$repo" -c "$dir"
    else
      # Trailing colon = "this session"; -a appends after the current window so
      # tab order is preserved. Bare -t "$SESSION" would resolve to the window
      # named pentla (same as the session) and collide on index.
      tmux new-window -a -t "$SESSION:" -n "$repo" -c "$dir"
    fi
    tmux split-window -v -t "$SESSION:$repo" -c "$dir"
    # Leave focus on the top pane (index-agnostic, works with any pane-base-index).
    tmux select-pane -t "$SESSION:$repo" -U
  done

  # pentla-local-env: 2x2 grid of equal panes. Left column both pentla-api,
  # right column both pentla-frontend. Build it structurally (split into two
  # columns, then split each column) - that yields equal panes in the right
  # spots. `select-layout tiled` is avoided on purpose: it reorders panes
  # row-major and would turn the columns into rows. Pane ids keep splits stable.
  local api="$ROOT/pentla-api"
  local fe="$ROOT/pentla-frontend"
  local api_top fe_top
  api_top=$(tmux new-window -a -t "$SESSION:" -P -F '#{pane_id}' -n pentla-local-env -c "$api")
  fe_top=$(tmux split-window -h -P -F '#{pane_id}' -t "$api_top" -c "$fe")
  tmux split-window -v -t "$api_top" -c "$api"
  tmux split-window -v -t "$fe_top" -c "$fe"

  tmux select-window -t "$SESSION:pentla"
}

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  build_session
fi

# switch-client when already inside tmux, attach otherwise (e.g. Ghostty launch).
if [ -n "${TMUX:-}" ]; then
  exec tmux switch-client -t "$SESSION"
else
  exec tmux attach -t "$SESSION"
fi
