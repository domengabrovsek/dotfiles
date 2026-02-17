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
git clone https://github.com/domengabrovsek/dotfiles.git
cd dotfiles/zsh
./install.sh
```

The install script handles everything: Homebrew, Oh My Zsh, plugins, CLI tools (fzf, eza, bat, zoxide), and symlinks. It's idempotent and safe to re-run.

After install, open a new terminal or run `exec zsh`.

### How It Works (Symlink-Based)

The entire config lives in the git repo. The installer creates two symlinks:

```
~/.zsh     ->  ~/path/to/dotfiles/zsh    (the repo directory)
~/.zshrc   ->  ~/.zsh/.zshrc             (the main entry point)
```

This means any edit you make in `~/.zsh/` directly modifies the repo — you can `git diff` to see changes, commit them, and `git pull` on another machine to sync. No copying files around, no manual syncing. Clone the repo on a new machine, run `install.sh`, and you have the exact same shell setup.

## Directory Structure

```
~/.zsh/                     # Symlink -> repo
├── .zshrc                  # Main entry point
├── install.sh              # Setup script for new machines
└── modules/                # All configuration modules
    ├── environment.zsh     # Env vars, history, fzf, zoxide
    ├── completions.zsh     # Cached completions (kubectl, helm, etc.)
    ├── aliases.zsh         # All aliases (git, docker, k8s, npm, etc.)
    ├── functions.zsh       # Functions + zhelp data
    ├── prompt.zsh          # Custom prompt with cached node version
    └── gcp.zsh             # GCP Cloud Run debugging shortcuts
```

## Features

- **fzf-powered help** - `zhelp` opens interactive fuzzy search of all commands
- **Modern CLI tools** - eza (ls), bat (cat), fzf (fuzzy finder), zoxide (smart cd)
- **Lazy NVM** - Node version manager loads on first use, not at shell start
- **Cached completions** - kubectl/helm completions cached to files
- **Autosuggestions** - Fish-style suggestions from history and completions
- **Syntax highlighting** - Commands colored as you type (green=valid, red=invalid)
- **GCP Cloud Run tools** - Debug Cloud Run services, images, logs, and revisions
- **Custom prompt** - Directory, git branch, AWS profile, node version

## Usage

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
git clone https://github.com/domengabrovsek/dotfiles.git
cd dotfiles/zsh && ./install.sh
```

To update:

```bash
cd ~/.zsh && git pull && exec zsh
```

## Troubleshooting

**Slow startup?** Check with `time zsh -i -c exit`. NVM is lazy-loaded. If still slow, disable unused plugins in `.zshrc`.

**Completions broken?** Run `rm -f ~/.zcompdump && compinit` and `rm ~/.zsh/cache/*.zsh` to regenerate caches.

**Changes not taking effect?** Run `exec zsh` or `source ~/.zshrc`.
