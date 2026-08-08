# CLAUDE.md

## Project Overview

Modular zsh configuration. Symlink-based: `~/.zsh` -> this repo, `~/.zshrc` -> `~/.zsh/.zshrc`.

## Structure

- `.zshrc` - Main entry point. Loads Oh My Zsh, then sources all `modules/*.zsh` files via a loop. Ends with `~/.zshrc.local` overrides.
- `modules/environment.zsh` - Env vars, history config, zoxide init, fzf setup, autosuggestion config, key bindings.
- `modules/aliases.zsh` - All aliases (git, docker, k8s, npm, terraform, aws, gcp, navigation, VS Code). Uses conditional eza/bat if installed, falls back to standard tools.
- `modules/functions.zsh` - Help system (`_zhelp_data` heredoc + `zhelp` function), welcome message, utility functions (git, docker, k8s, aws, fzf-powered, file ops, networking).
- `modules/completions.zsh` - Cached completions for kubectl/helm (written to `cache/` dir), lazy npm completion, Docker/AWS/GCP/Terraform completions.
- `modules/prompt.zsh` - Custom prompt with hostname, cached node version (updated on PATH change via `precmd`), AWS profile display, git info.
- `modules/gcp.zsh` - GCP Cloud Run debugging shortcuts (cr-find, cr-image, cr-logs, etc.), Artifact Registry helpers, gcp-debug-help.
- `install.sh` - Idempotent setup script. Installs Oh My Zsh, zsh plugins, CLI tools (fzf, eza, bat, zoxide), nvm + Node, creates symlinks. Platform-aware: Homebrew on macOS, apt on Debian/Ubuntu, where it also installs zsh and sets it as the login shell. Cloud CLIs are macOS-only.

## Key Design Decisions

- **NVM lazy loading**: Configured via `zstyle ':omz:plugins:nvm' lazy yes` before plugins array. NVM loads on first `node`/`npm`/`nvm` call, not at shell start.
- **Pinned Node version**: `NODE_VERSION` in `install.sh` sets the nvm default to an exact patch. A major-only alias (`default -> 24`) resolves against whatever is installed locally, so machines silently drift apart. `.zshenv` resolves the alias by path, so the value must be a plain version string, never `lts/*`.
- **Hostname in the prompt**: `prompt_host()` reads `ZSH_PROMPT_HOST` at render time, not load time, so `~/.zshrc.local` can override it despite being sourced after the modules. Falls back to `%m`, which is short on the Pis but expands to the full computer name on macOS.
- **Node version caching**: `prompt.zsh` caches the node version, updates on PATH change via `precmd` hook (catches `nvm use`, `nvm install`, `.nvmrc` auto-switch). Extracts version from NVM path string without subprocess. Cost: one PATH string comparison per prompt.
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
- Debian/Ubuntu install bat's binary as `batcat`. `aliases.zsh` checks both spellings; a bare `command -v bat` test silently does nothing on those hosts.
- Homebrew has no ARM64 Linux bottles, so it must not be used on the aarch64 homelab hosts - `brew install` would build from source. Use apt there.
- EDITOR is set to `code -w` (not `code --wait`) because `--wait` with spaces causes issues when used in shell aliases.
- Cache dir (`~/.zsh/cache/`) is gitignored and created by `install.sh`.
