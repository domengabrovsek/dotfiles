# CLAUDE.md

## Project Overview

Modular zsh configuration. Symlink-based: `~/.zsh` -> this repo, `~/.zshrc` -> `~/.zsh/.zshrc`.

## Structure

- `.zshrc` - Main entry point. Loads Oh My Zsh, then the modules from an explicit, ordered list, then `~/.zshrc.local` overrides, then prints the startup time and the welcome banner. Load order and design reasons: [ARCHITECTURE.md](ARCHITECTURE.md).
- `modules/environment.zsh` - Env vars, history config, zoxide init, fzf setup, autosuggestion config, key bindings.
- `modules/git.zsh`, `docker.zsh`, `k8s.zsh`, `terraform.zsh`, `node.zsh`, `aws.zsh`, `gcp.zsh` - One domain each: aliases, functions, env, completion, and help entries.
- `modules/files.zsh` - Navigation, `ls`/`cat` (eza/bat if installed, standard tools otherwise), safe `cp`/`mv`/`rm`, file functions.
- `modules/system.zsh` - Network, VS Code, and utility aliases and functions.
- `modules/welcome.zsh` - `zsh_welcome`, shown at the end of `.zshrc`.
- `modules/help.zsh` - `_zhelp_register` and `zhelp`. Loaded first so every module can register its commands.
- `modules/completions.zsh` - Shared completion zstyles. Tool completions live in their domain modules; kubectl/helm completion is cached to `cache/` from `k8s.zsh`.
- `modules/prompt.zsh` - Custom prompt with hostname, cached node version (updated on PATH change via `precmd`), AWS profile display, git info.
- `modules/gcp.zsh` also holds the gcloud PATH include, `gcpp`/`gcpa`/`gcpc`, Cloud Run debugging shortcuts (cr-find, cr-image, cr-logs, etc.), Artifact Registry helpers, and gcp-debug-help. It loads before `prompt.zsh`, whose GCP segment needs gcloud on PATH.
- `install.sh` - Idempotent setup script. Installs Oh My Zsh, zsh plugins, CLI tools (fzf, eza, bat, zoxide), nvm + Node, creates symlinks. Platform-aware: Homebrew on macOS, apt on Debian/Ubuntu, where it also installs zsh and sets it as the login shell. Cloud CLIs are macOS-only.

## Key Design Decisions

- **NVM lazy loading**: Configured via `zstyle ':omz:plugins:nvm' lazy yes` before plugins array. NVM loads on first `node`/`npm`/`nvm` call, not at shell start.
- **Pinned Node version**: `NODE_VERSION` in `install.sh` sets the nvm default to an exact patch. A major-only alias (`default -> 24`) resolves against whatever is installed locally, so machines silently drift apart. `.zshenv` resolves the alias by path, so the value must be a plain version string, never `lts/*`.
- **Hostname in the prompt**: `prompt_host()` reads `ZSH_PROMPT_HOST` at render time, not load time, so `~/.zshrc.local` can override it despite being sourced after the modules. Falls back to `%m`, which is short on the Pis but expands to the full computer name on macOS.
- **Node version caching**: `prompt.zsh` caches the node version, updates on PATH change via `precmd` hook (catches `nvm use`, `nvm install`, `.nvmrc` auto-switch). Extracts version from NVM path string without subprocess. Cost: one PATH string comparison per prompt.
- **Completion caching**: kubectl/helm completions written to `cache/*.zsh` files, regenerated only when the binary is newer than the cache file (`-nt` test).
- **Performance timing**: Uses `zmodload zsh/datetime` + `$EPOCHREALTIME` (not `date +%s%N` which doesn't work on macOS).
- **Symlink-based**: `install.sh` creates symlinks, not copies. This means edits to `~/.zsh/` files directly modify the repo.
- **fzf-powered help**: modules register entries with `_zhelp_register <section> <<'HELP'`; `zhelp` pipes them to fzf.

## Common Tasks

- **Add an alias or function**: Put it in its domain module, or `system.zsh` if none fits. Add its help line to that module's `_zhelp_register` block.
- **Add a completion**: Put it in the tool's domain module. Use the `k8s.zsh` caching pattern for slow completions.
- **Add a new module**: Create `modules/<name>.zsh` and add the module name to the loading loop in `.zshrc`. A domain module holds its aliases, functions, env, completion, and `_zhelp_register` block.
- **Test changes**: `exec zsh` to reload. Check startup time printed on load.

## Things to Watch Out For

- macOS `date` doesn't support `%N` (nanoseconds). Use `$EPOCHREALTIME` from `zsh/datetime` module.
- `COMPLETE_ALIASES` setopt is intentionally removed - it breaks alias completion expansion.
- `fd()` was renamed to `fdir()` to avoid shadowing `fd-find` (`brew install fd`).
- Debian/Ubuntu install bat's binary as `batcat`. `files.zsh` checks both spellings; a bare `command -v bat` test silently does nothing on those hosts.
- Homebrew has no ARM64 Linux bottles, so it must not be used on the aarch64 homelab hosts - `brew install` would build from source. Use apt there.
- EDITOR is `code -w` when VS Code is installed, otherwise `vim`, otherwise `vi`, so headless hosts get a working editor. `-w` rather than `--wait` because `--wait` with spaces causes issues when used in shell aliases.
- Cache dir (`~/.zsh/cache/`) is gitignored and created by `install.sh`.
