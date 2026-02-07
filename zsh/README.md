# Modular Zsh Configuration

A clean, modular zsh configuration that supports work/personal mode switching with shared common configs. Includes modern CLI tools (fzf, eza, bat, zoxide), lazy-loaded NVM, cached completions, and an fzf-powered help system.

## Setup

```bash
git clone https://github.com/domengabrovsek/dotfiles.git
cd dotfiles/zsh
./install.sh
```

The install script handles everything: Homebrew, Oh My Zsh, plugins, CLI tools (fzf, eza, bat, zoxide), and symlinks (`~/.zsh` -> repo, `~/.zshrc` -> `~/.zsh/.zshrc`). It's idempotent and safe to re-run.

After install, open a new terminal or run `exec zsh`.

## Directory Structure

```
~/.zsh/                     # Symlink -> repo
├── .zshrc                  # Main entry point
├── install.sh              # Setup script for new machines
├── shared/                 # Common configs (always loaded)
│   ├── environment.zsh     # Env vars, history, fzf, zoxide
│   ├── completions.zsh     # Cached completions (kubectl, helm, etc.)
│   ├── aliases.zsh         # All aliases (git, docker, k8s, npm, etc.)
│   ├── functions.zsh       # Functions + zhelp data
│   └── prompt.zsh          # Custom prompt with cached node version
├── work/                   # Work-specific overrides
│   ├── environment.zsh
│   ├── aliases.zsh
│   └── functions.zsh
└── personal/               # Personal-specific overrides
    ├── environment.zsh
    ├── aliases.zsh
    └── functions.zsh
```

## Features

- **fzf-powered help** - `zhelp` opens interactive fuzzy search of all commands
- **Modern CLI tools** - eza (ls), bat (cat), fzf (fuzzy finder), zoxide (smart cd)
- **Lazy NVM** - Node version manager loads on first use, not at shell start
- **Cached completions** - kubectl/helm completions cached to files
- **Autosuggestions** - Fish-style suggestions from history and completions
- **Syntax highlighting** - Commands colored as you type (green=valid, red=invalid)
- **Work/personal modes** - `zsh_switch work|personal` with separate config dirs
- **Custom prompt** - Directory, git branch, AWS profile, node version

## Usage

### Help System

```bash
zhelp            # Interactive fzf search (or less fallback)
zhelp docker     # Filter by keyword
zhelp port       # Search for port-related commands
```

### Mode Switching

```bash
zsh_mode              # Check current mode
zsh_switch work       # Switch to work mode
zsh_switch personal   # Switch to personal mode
```

Set default in `~/.zprofile`: `export ZSH_CONFIG_MODE=work`

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

### Navigation & Files
`ll`/`la`/`lt` eza listings, `tree` eza tree, `cat` bat with syntax highlighting, `z <dir>` zoxide smart jump, `mkcd` mkdir+cd, `extract <file>` any archive

### VS Code
`c.` code ., `cr` code -r . (reuse window), `cdiff` code --diff, `cext` list extensions

### Utilities
`myip`, `kill_port <p>`, `ports`, `flushdns`, `weather [city]`, `genpass [len]`, `hist_stats`

## Customization

### Work/Personal Overrides

Add settings to the appropriate mode directory:

```bash
# ~/.zsh/work/environment.zsh
export AWS_PROFILE=work-profile

# ~/.zsh/work/aliases.zsh
alias ssh-bastion='ssh user@bastion.company.com'
```

### Machine-Specific Settings

Create `~/.zshrc.local` for settings that shouldn't be in git (API keys, machine-specific paths, etc.). It's auto-loaded if present.

```bash
export ZSH_USER_NAME="Your Name"    # Customize welcome greeting
export ZSH_DISABLE_WELCOME=1        # Disable welcome message
export ZSH_CONFIG_MODE=work          # Default to work mode
```

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
