# CLAUDE.md

## Project Overview

Modular zsh configuration. Symlink-based: `~/.zsh` -> this repo, `~/.zshrc` -> `~/.zsh/.zshrc`.

## Structure

- `.zshrc` - Main entry point. Loads Oh My Zsh, then sources all `modules/*.zsh` files via a loop. Ends with `~/.zshrc.local` overrides.
- `modules/environment.zsh` - Env vars, history config, zoxide init, fzf setup, autosuggestion config, key bindings.
- `modules/aliases.zsh` - All aliases (git, docker, k8s, npm, terraform, aws, gcp, navigation, VS Code). Uses conditional eza/bat if installed, falls back to standard tools.
- `modules/functions.zsh` - Help system (`_zhelp_data` heredoc + `zhelp` function), welcome message, utility functions (git, docker, k8s, aws, fzf-powered, file ops, networking).
- `modules/completions.zsh` - Cached completions for kubectl/helm (written to `cache/` dir), lazy npm completion, Docker/AWS/GCP/Terraform completions.
- `modules/prompt.zsh` - Custom prompt with cached node version (updated on `chpwd`), AWS profile display, git info.
- `modules/gcp.zsh` - GCP Cloud Run debugging shortcuts (cr-find, cr-image, cr-logs, etc.), Artifact Registry helpers, gcp-debug-help.
- `install.sh` - Idempotent setup script. Installs Homebrew, Oh My Zsh, zsh plugins, CLI tools (fzf, eza, bat, zoxide), creates symlinks.

## Key Design Decisions

- **NVM lazy loading**: Configured via `zstyle ':omz:plugins:nvm' lazy yes` before plugins array. NVM loads on first `node`/`npm`/`nvm` call, not at shell start.
- **Node version caching**: `prompt.zsh` caches `node -v` result, updates only on directory change (`chpwd` hook) to avoid subprocess per prompt render.
- **Completion caching**: kubectl/helm completions written to `cache/*.zsh` files, regenerated only when the binary is newer than the cache file (`-nt` test).
- **Performance timing**: Uses `zmodload zsh/datetime` + `$EPOCHREALTIME` (not `date +%s%N` which doesn't work on macOS).
- **Symlink-based**: `install.sh` creates symlinks, not copies. This means edits to `~/.zsh/` files directly modify the repo.
- **fzf-powered help**: `zhelp` reads from a single `_zhelp_data` heredoc and pipes to fzf for interactive search.

## Common Tasks

- **Add an alias**: Edit `modules/aliases.zsh`. Update `_zhelp_data` in `modules/functions.zsh` to include it in help.
- **Add a function**: Edit `modules/functions.zsh`. Update `_zhelp_data` heredoc.
- **Add a completion**: Edit `modules/completions.zsh`. Use caching pattern for slow completions.
- **Add a new module**: Create `modules/<name>.zsh` and add the module name to the loading loop in `.zshrc`.
- **Test changes**: `exec zsh` to reload. Check startup time printed on load.

## Things to Watch Out For

- macOS `date` doesn't support `%N` (nanoseconds). Use `$EPOCHREALTIME` from `zsh/datetime` module.
- `COMPLETE_ALIASES` setopt is intentionally removed - it breaks alias completion expansion.
- `fd()` was renamed to `fdir()` to avoid shadowing `fd-find` (`brew install fd`).
- EDITOR is set to `code -w` (not `code --wait`) because `--wait` with spaces causes issues when used in shell aliases.
- Cache dir (`~/.zsh/cache/`) is gitignored and created by `install.sh`.
