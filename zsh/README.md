# Modular Zsh Configuration

A clean, modular zsh configuration with modern CLI tools (fzf, eza, bat, zoxide), lazy-loaded NVM, cached completions, and an fzf-powered help system.

## Why Use This Over a Default Shell?

**Default shell:**
```bash
ls                          # plain file list, no colors, no git info
cat config.yaml             # raw text, no syntax highlighting
cd ~/projects/my-app        # you need to remember the exact path
history | grep docker       # scroll through wall of text
git add . && git commit -m "msg" && git push   # every single time
```

**With this config:**
```bash
ll                          # colored file list with icons, git status, human-readable sizes
cat config.yaml             # syntax-highlighted with line numbers (bat)
z my-app                    # smart jump from anywhere (zoxide remembers your dirs)
Ctrl+R                      # fuzzy search history instantly (fzf)
qpush "msg"                 # one command: add, commit, push
```

**More examples:**
```bash
zhelp port                  # forgot a command? fuzzy search all custom commands
dsh my-container            # shell into a Docker container (tries bash, falls back to sh)
kctx                        # list k8s contexts, kctx prod to switch
cr-info my-service          # full Cloud Run summary in one command
kill_port 3000              # kill whatever is hogging port 3000
extract archive.tar.gz      # works with any archive format, no flags to remember
```

You also get **live autosuggestions** as you type (from history + completions), **syntax highlighting** (green = valid command, red = typo), and **tab completion** for kubectl, docker, gcloud, terraform, and more - all cached for fast startup.

## Setup

```bash
git clone git@github.com:domengabrovsek/dotfiles.git ~/dev/personal/dotfiles
cd ~/dev/personal/dotfiles/zsh && ./install.sh
```

On a machine without an SSH key yet, follow the bootstrap in [git/README.md](../git/README.md) first.

The install script handles everything: Oh My Zsh, plugins, CLI tools (fzf, eza, bat, zoxide), nvm + Node, and symlinks. It's idempotent and safe to re-run.

Node is pinned to an exact version by `NODE_VERSION` in `install.sh`, so every machine runs the same toolchain. Bump that one line and re-run the script on each machine to move them all together.

It detects the platform and adapts:

| | macOS | Debian / Ubuntu |
|---|---|---|
| CLI tools from | Homebrew | apt |
| zsh | already present | installed, and set as the login shell |
| Cloud CLIs (aws, gcloud, session-manager-plugin) | installed, AWS SSO and gcloud accounts seeded | skipped |

Homebrew is not used on Linux: it publishes no ARM64 bottles, so every formula would compile from source, and apt carries all four tools. The cloud CLIs are workstation-only, so the homelab hosts don't hold cloud credentials. Every path they set up is guarded in `environment.zsh` and `completions.zsh`, so skipping them leaves a working shell.

After install, open a new terminal or run `exec zsh`. On Linux the login shell change takes effect at the next login.

### How It Works (Symlink-Based)

The entire config lives in the git repo. The installer creates two symlinks:

```
~/.zsh     ->  ~/path/to/dotfiles/zsh    (the repo directory)
~/.zshrc   ->  ~/.zsh/.zshrc             (the main entry point)
```

This means any edit you make in `~/.zsh/` directly modifies the repo - you can `git diff` to see changes, commit them, and `git pull` on another machine to sync. No copying files around, no manual syncing. Clone the repo on a new machine, run `install.sh`, and you have the exact same shell setup.

## Directory Structure

```
~/.zsh/                     # Symlink -> repo
├── .zshrc                  # Main entry point
├── install.sh              # Setup script for new machines
└── modules/                # All configuration modules
    ├── help.zsh            # zhelp and _zhelp_register
    ├── environment.zsh     # PATH, editor, history, fzf, zoxide
    ├── completions.zsh     # Shared completion settings
    ├── files.zsh           # Navigation, ls/cat, file functions
    ├── system.zsh          # Network, VS Code, utilities
    ├── git.zsh             # Git aliases, functions, fzf pickers
    ├── docker.zsh          # Docker and compose
    ├── k8s.zsh             # kubectl and helm
    ├── terraform.zsh       # Terraform
    ├── gcp.zsh             # gcloud switchers + Cloud Run shortcuts
    ├── node.zsh            # npm, .nvmrc at startup
    ├── aws.zsh             # AWS profiles and SSO
    ├── prompt.zsh          # Custom prompt
    └── welcome.zsh         # Welcome banner
```

## Features

- **fzf-powered help** - `zhelp` opens interactive fuzzy search of all commands
- **Modern CLI tools** - eza (ls), bat (cat), fzf (fuzzy finder), zoxide (smart cd)
- **Lazy NVM** - Node version manager loads on first use, not at shell start
- **Cached completions** - kubectl/helm completions cached to files
- **Autosuggestions** - Fish-style suggestions from history and completions
- **Syntax highlighting** - Commands colored as you type (green=valid, red=invalid)
- **GCP Cloud Run tools** - Debug Cloud Run services, images, logs, and revisions
- **Custom prompt** - Hostname, directory, git branch, AWS profile, node version

## Usage

### Prompt

```
💻 hostname · 📁 current · ±(branch) · ☁︎ aws · ☁︎ gcp · ⬢ node →
```

```
💻 server · 📁 repos · ⬢ v24.18.0 →
💻 domen-mbp · 📁 dotfiles · ±(main) · ☁︎ my-project (me@example.com) · ⬢ v24.18.0 →
```

Every section carries a glyph, so you can find one without reading the others.

A dot sits between every pair of sections. They all share one grey, used by
nothing else in the prompt, so the boundaries are findable without reading the
words. Each segment past the directory carries its own leading dot, so a dot
only ever appears between two segments that are both present - outside a repo,
or on a machine with no node, the segment and its dot vanish together.

The hostname leads because the same config runs on the Mac and every homelab
host, and they are all reachable from each other, so the prompt has to say
which machine you are typing on. It defaults to `%m`, the short hostname,
already short on the Linux hosts. If a machine reports something too
long, shorten it in `~/.zshrc.local`:

```bash
ZSH_PROMPT_HOST=mbp
```

The directory is `%1~`, only the current folder.

AWS and GCP share the `☁︎` glyph and are told apart by colour - 208 for AWS
orange, 33 for Google blue - so two cloud segments read as one idea with two
providers rather than two unrelated things. The GCP segment also shows the
active account in parentheses.

### Help System

```bash
zhelp            # Interactive fzf search (or less fallback)
zhelp docker     # Filter by keyword
zhelp port       # Search for port-related commands
zhelp gcp        # Search for GCP-related commands
```

### Key Bindings (fzf)

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Fuzzy history search |
| `Ctrl+T` | Fuzzy file finder |
| `Alt+C` | Fuzzy cd into subdirectory |

### Autosuggestions

| Shortcut | Action |
|----------|--------|
| `→` (Right Arrow) | Accept full suggestion |
| `Ctrl+E` | Accept full suggestion |
| `Ctrl+→` | Accept one word |
| `Ctrl+U` | Clear suggestion |

Suggestions come from history and completions, fetched asynchronously, for
buffers up to 20 characters. The settings live in `modules/environment.zsh`.
Override them in `~/.zshrc.local`, for example
`ZSH_AUTOSUGGEST_STRATEGY=(history)`.

### Cloud Accounts

`install.sh` symlinks `~/.aws/config` to `aws/config.local`, which holds the SSO
session and profiles. It is gitignored; start it from `aws/config.example`.

| Command | Action |
|---|---|
| `awsp` | Pick a profile with fzf; the preview shows its account and role |
| `awsp <name>` | Switch to that profile; other text pre-fills the picker |
| `awsp off` | Clear `AWS_PROFILE` |
| `awsc` | Show the profile and `sts get-caller-identity` |

`awsp` runs `aws sso login` only when the cached session has expired. The
profile is per terminal, so two terminals can use two accounts.

`gcp/configurations.sh` seeds the gcloud configurations listed in the gitignored
`gcp/configurations.local`, one `<name> <account> <project> <region> <zone>` per line. Log in to each account
once with `gcloud auth login <account>`.

| Command | Action |
|---|---|
| `gcpp [name]` | Switch gcloud configuration (numbered list without a name) |
| `gcpa [account]` | Switch the account on the active configuration |
| `gcpc` | Show configuration, account, project, and region |

## Common Commands

Run `zhelp` for the full searchable list. Highlights:

### Git
`gs` status, `ga`/`gaa` add, `gcm "msg"` commit, `gp` push, `gl` pull, `gco`/`gcb` checkout, `gsw`/`gswc` switch (modern), `grs`/`grss` restore (modern), `glog` log graph, `qpush "msg"` add+commit+push, `fbr` fzf branch switcher, `flog` fzf log browser

### Docker
`d` docker, `dc` compose, `dcup`/`dcupd`/`dcdown` compose up/up -d/down, `dps` ps, `dex` exec, `dsh <ctr>` shell into container, `docker_nuke` full cleanup

### Kubernetes
`k` kubectl, `kgp`/`kgs`/`kgd` get pods/services/deployments, `kl` logs, `kx` exec, `kctx`/`kns` switch context/namespace

### GCP Cloud Run
`cr-find` search services, `cr-image` get Docker image, `cr-logs` view logs, `cr-errors` view errors, `cr-info` full summary, `gcp-debug-help` show all GCP commands

### Navigation & Files
`ll`/`la`/`lt` eza listings, `tree` eza tree, `cat` bat with syntax highlighting, `z <dir>` zoxide smart jump, `mkcd` mkdir+cd, `extract <file>` any archive

### VS Code
`c.` code ., `cr` code -r . (reuse window), `cdiff` code --diff, `cext` list extensions

### Utilities
`myip`, `kill_port <p>`, `ports`, `flushdns`, `weather [city]`, `genpass [len]`, `hist_stats`

## Customization

### Machine-Specific Settings

Create `~/.zshrc.local` for settings that shouldn't be in git (API keys, machine-specific paths, etc.). It's auto-loaded if present.

```bash
export ZSH_USER_NAME="Your Name"    # Customize welcome greeting
export ZSH_DISABLE_WELCOME=1        # Disable welcome message
```

### Adding a New Module

Create `modules/<name>.zsh` and add the module name to the loading loop in `.zshrc`.

## Syncing Across Machines

On a new machine:

```bash
git clone git@github.com:domengabrovsek/dotfiles.git ~/dev/personal/dotfiles
cd ~/dev/personal/dotfiles/zsh && ./install.sh
```

To update:

```bash
cd ~/.zsh && git pull && exec zsh
```

## Troubleshooting

**Slow startup?** Check with `time zsh -i -c exit`. NVM is lazy-loaded. If still slow, disable unused plugins in `.zshrc`.

**Completions broken?** Run `rm -f ~/.zcompdump && compinit` and `rm ~/.zsh/cache/*.zsh` to regenerate caches.

**Changes not taking effect?** Run `exec zsh` or `source ~/.zshrc`.
