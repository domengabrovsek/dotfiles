# Dotfiles

Personal zsh configuration with work/personal mode switching, modern CLI tools, and an fzf-powered help system.

## Setup

```bash
git clone https://github.com/domengabrovsek/dotfiles.git
cd dotfiles/zsh && ./install.sh
```

The install script is idempotent (safe to re-run) and handles:

1. **Homebrew** - installs if missing
2. **Oh My Zsh** - installs if missing
3. **Zsh plugins** - zsh-autosuggestions, zsh-syntax-highlighting
4. **CLI tools** via Homebrew - fzf, eza, bat, zoxide
5. **Symlinks** - `~/.zsh` -> repo, `~/.zshrc` -> `~/.zsh/.zshrc`
6. **Cache directory** - for kubectl/helm completion caching

Open a new terminal or run `exec zsh` when done.

## Structure

```
dotfiles/
└── zsh/
    ├── .zshrc              # Main entry point
    ├── install.sh          # Setup script
    ├── shared/             # Common configs (always loaded)
    │   ├── aliases.zsh     # Git, Docker, K8s, npm, VS Code, etc.
    │   ├── environment.zsh # Env vars, history, fzf, zoxide
    │   ├── functions.zsh   # Utility functions + zhelp system
    │   ├── completions.zsh # Cached completions (kubectl, helm, etc.)
    │   └── prompt.zsh      # Custom prompt
    ├── work/               # Work-specific overrides
    └── personal/           # Personal-specific overrides
```

## Usage

```bash
zhelp                # Interactive fuzzy search of all commands
zhelp docker         # Filter by keyword
zsh_switch work      # Switch to work mode
```

## Documentation

- [Zsh Configuration](zsh/README.md)
- [AWS Profile Management](zsh/AWS_GUIDE.md)
- [Autosuggestions Guide](zsh/AUTOSUGGESTIONS.md)
