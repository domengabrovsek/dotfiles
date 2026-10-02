# How the zsh config works

This explains how the shell loads, why the pieces sit where they do, and which
rules keep a change safe. For setup and day-to-day commands, see
[README.md](README.md).

The config is one directory, linked to `~/.zsh`, that zsh reads through two
entry points: `.zshenv` for every zsh process and `.zshrc` for interactive
shells. `.zshrc` loads Oh My Zsh, then a fixed list of modules, one per domain.

## Two entry points

| File | Runs for | Job |
|---|---|---|
| `.zshenv` | Every zsh, including `zsh -c`, editors, cron, CI and agent tools | Puts nvm's default Node on `PATH` |
| `.zshrc` | Interactive shells | Everything else: Oh My Zsh, modules, prompt, welcome |

`.zshenv` exists because non-interactive shells never read `.zshrc`, yet tools
they start still need `node`. It resolves `~/.nvm/alias/default` to a version
directory by path instead of sourcing nvm, so it starts no subprocess. Because
it cannot resolve a glob alias, the Node pin in `install.sh` must be a plain
version such as `24.21.0`, never `lts/*`.

## What `.zshrc` does, in order

| Step | What | Why it sits here |
|---|---|---|
| 1 | Record the start time (`zsh/datetime`) | The timer must start before anything else to measure startup |
| 2 | `brew shellenv` on macOS | Later steps find tools on `PATH` |
| 3 | Oh My Zsh settings (`zstyle`, `plugins`) | Oh My Zsh reads them when it loads in step 4 |
| 4 | Source Oh My Zsh | Runs `compinit` and loads the plugins |
| 5 | Load the modules, in the order below | Modules call `compdef` and Oh My Zsh helpers |
| 6 | Source `~/.zshrc.local` if present | After the modules, so it can override them |
| 7 | Print `Shell loaded in: <ms>` | Measures steps 1 to 6 |
| 8 | Show the welcome banner unless `ZSH_DISABLE_WELCOME` is set | After step 6, so `.zshrc.local` can turn it off |

### Oh My Zsh settings and their reasons

- **nvm loads lazily, in interactive shells only.** The first `node`, `npm` or
  `nvm` call loads it, which keeps it off the startup path. Non-interactive
  shells load it eagerly, because the lazy wrapper prints a
  `_omz_nvm_setup_completion: command not found` error into tool output.
- **`autoload` is on**, so after nvm loads, entering a folder with `.nvmrc`
  switches Node and leaving it switches back to the default.
- **`async-prompt force`** is set because Oh My Zsh only computes the git branch
  when it finds the literal `$(git_prompt_info)` in `PROMPT`. The prompt calls
  it through the `git_segment` wrapper, so without `force` the branch never
  shows.
- **The `git` and `kubectl` plugins are left out.** `git.zsh` and `k8s.zsh`
  define those aliases, and the plugins defined over 200 more, some with a
  different meaning (`gst` is `git stash` here). The prompt's
  `git_prompt_info` comes from Oh My Zsh's core library, not the git plugin.

## Modules

`.zshrc` loads the modules from an explicit list, not a glob, because order
matters. A module that is missing is skipped.

| Order | Module | Owns |
|---|---|---|
| 1 | `help.zsh` | `zhelp` and `_zhelp_register` |
| 2 | `environment.zsh` | `PATH` additions, editor, history and directory options, zoxide, fzf, autosuggestion settings |
| 3 | `completions.zsh` | Completion styles shared by every tool |
| 4 | `files.zsh` | Navigation, `ls` and `cat` replacements, file functions |
| 5 | `system.zsh` | Network, VS Code and utility commands |
| 6-9 | `git.zsh`, `docker.zsh`, `k8s.zsh`, `terraform.zsh` | One tool each |
| 10 | `gcp.zsh` | gcloud `PATH` and completion, `gcpp`/`gcpa`/`gcpc`, Cloud Run helpers |
| 11 | `node.zsh` | npm commands, the startup `.nvmrc` lookup |
| 12 | `aws.zsh` | AWS profile switching and region defaults |
| 13 | `prompt.zsh` | The prompt and its caches |
| 14 | `welcome.zsh` | The welcome banner |

Ordering rules:

- `help.zsh` loads first, because every other module calls `_zhelp_register`
  as it loads.
- `gcp.zsh` loads before `prompt.zsh`. The prompt asks `gcloud` for the active
  configuration as it loads, and `gcp.zsh` is what puts `gcloud` on `PATH`.
- `gcp.zsh` loads before `node.zsh`, because both prepend to `PATH` and the
  project's Node from `.nvmrc` must end up first.
- `welcome.zsh` reads the Node version that `prompt.zsh` caches, so it shows the
  version without starting `node`. Starting it would load nvm at every shell
  start.

### A domain module's shape

Each tool module keeps everything for that tool in one file, under
`# --- Section ---` headings: environment variables, aliases, functions,
completion, then its help block:

```zsh
_zhelp_register docker <<'HELP'
dsh <ctr>     exec into container (bash/sh)
HELP
```

`zhelp` lists only what the loaded modules registered, so a command and its
help line change together. A module that does not load leaves no stale entry.

## Caches

The prompt redraws before every command, so anything slow is computed once and
kept in a shell variable or a file.

| Cache | Kept in | Refreshed when |
|---|---|---|
| Node and npm version | Shell variables in `prompt.zsh` | `PATH` changes, checked before each prompt. The Node version is read from the nvm path and npm's from its `package.json`, with no subprocess. |
| Active gcloud configuration and account | Shell variables in `prompt.zsh` | At shell start, and by `gcpp` or `gcpa` only |
| kubectl and helm completion | `~/.zsh/cache/*.zsh` | The binary is newer than the cache file |

The gcloud cache does not see changes made another way. After
`gcloud config configurations activate`, or a switch in another terminal, the
prompt shows the old value until `gcpp`, `gcpa` or a new shell. The segment is
hidden while the active configuration is named `default`.

## Decisions that are easy to undo by accident

| Decision | Why | Where |
|---|---|---|
| `compinit` runs once, inside Oh My Zsh | A second run costs about 400 ms and drops every completion registered before it, such as gcloud's | `modules/completions.zsh` |
| `EXTENDED_GLOB` is off | nvm is POSIX sh and runs with this shell's options. With it on, `#` becomes a glob operator, nvm cannot resolve `default`, and switching back after an `.nvmrc` project fails. | `modules/environment.zsh` |
| No `COMPLETE_ALIASES` | Without it, aliases such as `gco` complete like the command they expand to | `modules/completions.zsh` |
| `fdir`, not `fd` | `fd` would hide the `fd` file finder | `modules/files.zsh` |
| `bat` or `batcat` | Debian installs bat as `batcat` | `modules/files.zsh` |
| `ip`, `flushdns`, `hosts` on macOS only | Linux keeps its own `ip`, and lacks the macOS tools these call | `modules/system.zsh` |
| The repo must be reachable as `~/.zsh` | `.zshrc` and the completion caches use that path | `.zshrc`, `modules/k8s.zsh` |
| Hostname read when the prompt draws | `~/.zshrc.local` loads after the modules and can still set `ZSH_PROMPT_HOST` | `modules/prompt.zsh` |

## Files that stay out of git

The repo is public, so anything specific to a machine, an employer or an
account lives in a file that git ignores (`*.local` in `.gitignore`) or outside
the repo.

| File | Read by | Holds |
|---|---|---|
| `~/.zshrc.local` | `.zshrc`, after the modules | Machine `PATH` entries, overrides such as `ZSH_PROMPT_HOST` |
| `aws/config.local` | `~/.aws/config`, which `install.sh` links to it | AWS SSO session and profiles; start from `aws/config.example` |
| `gcp/configurations.local` | `gcp/configurations.sh` | One gcloud configuration per line: `<name> <account> <project> <region> <zone>` |
| `cache/` | `k8s.zsh`, completion styles | Generated completion files |

These files do not sync between machines. Copy them once per machine.

## Making a change safely

- **New command:** add it to its domain module, or `system.zsh` if none fits,
  and add a line to that module's help block.
- **New module:** create `modules/<name>.zsh` with a `_zhelp_register` block
  for its commands, and add the name to the list in `.zshrc`. Place it after
  every module whose functions it calls while loading, and before
  `welcome.zsh`, which stays last.
- **Slow tool output in the prompt:** cache it, and decide what refreshes the
  cache, as the table above does.
- **Check:** `zsh -n modules/<name>.zsh`, then `exec zsh`. The shell prints its
  startup time, so a slow change shows at once.
