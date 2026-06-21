# Dotfiles

Personal zsh configuration with modern CLI tools and an fzf-powered help system,
plus a git-tracked Ghostty + tmux setup that reopens the same workspace layout.

## Setup

```bash
git clone https://github.com/domengabrovsek/dotfiles.git
cd dotfiles/zsh && ./install.sh   # zsh, plugins, CLI tools
cd .. && ./install.sh             # Ghostty + tmux configs
```

Both scripts are idempotent (safe to re-run). `zsh/install.sh` handles:

1. **Homebrew** - installs if missing
2. **Oh My Zsh** - installs if missing
3. **Zsh plugins** - zsh-autosuggestions, zsh-syntax-highlighting
4. **CLI tools** via Homebrew - fzf, eza, bat, zoxide
5. **Symlinks** - `~/.zsh` -> repo, `~/.zshrc` -> `~/.zsh/.zshrc`
6. **Cache directory** - for kubectl/helm completion caching

The root `install.sh` handles the terminal workspace:

1. **tmux** via Homebrew (installs if missing)
2. **Symlinks** - `~/.config/ghostty` and `~/.config/tmux` -> repo
3. **Backups** - moves the default macOS Ghostty config aside so the
   git-tracked one wins

Open a new terminal or run `exec zsh` when done.

## Ghostty + tmux workspace

Ghostty launches straight into a persistent `pentla` tmux session defined in
[`tmux/sessions/pentla.sh`](tmux/sessions/pentla.sh): one tab per repo with a
fixed pane layout, so every launch lands the same folders in the same splits.
The session create-or-attaches, so it survives app restarts. Edit the `repos`
list (or the local-env block) in that script to change tabs, folders, or layout.

## Structure

```
dotfiles/
├── install.sh             # Ghostty + tmux installer
├── ghostty/
│   └── config             # Ghostty config (launches the tmux session)
├── tmux/
│   ├── tmux.conf          # Base tmux settings
│   └── sessions/
│       └── pentla.sh      # Tab/pane/folder layout for the pentla workspace
└── zsh/
    ├── .zshrc              # Main entry point
    ├── install.sh          # Setup script
    └── modules/            # All configuration modules
        ├── aliases.zsh     # Git, Docker, K8s, npm, VS Code, etc.
        ├── environment.zsh # Env vars, history, fzf, zoxide
        ├── functions.zsh   # Utility functions + zhelp system
        ├── completions.zsh # Cached completions (kubectl, helm, etc.)
        ├── prompt.zsh      # Custom prompt
        └── gcp.zsh         # GCP Cloud Run debugging shortcuts
```

## Usage

```bash
zhelp                # Interactive fuzzy search of all commands
zhelp docker         # Filter by keyword
zhelp gcp            # Search GCP-related commands
```

## Documentation

- [Zsh Configuration](zsh/README.md)
- [AWS Profile Management](zsh/AWS_GUIDE.md)
- [Autosuggestions Guide](zsh/AUTOSUGGESTIONS.md)
