# Dotfiles

Personal shell and git setup, shared across a Mac and the homelab hosts.

| Directory | What it sets up | Installer | Docs |
|---|---|---|---|
| `zsh/` | Oh My Zsh, one module per domain, prompt, `zhelp`, CLI tools, nvm + pinned Node, cloud CLIs (macOS) | `zsh/install.sh` | [zsh/README.md](zsh/README.md) |
| `git/` | Git identities by directory, GitHub SSH key and config | `git/install.sh` | [git/README.md](git/README.md) |

## Setup

```bash
git clone git@github.com:domengabrovsek/dotfiles.git ~/dev/personal/dotfiles
cd ~/dev/personal/dotfiles/zsh && ./install.sh
cd ~/dev/personal/dotfiles/git && ./install.sh
```

Both installers are idempotent. `zsh/install.sh` uses Homebrew on macOS and apt on Debian/Ubuntu. On a machine without an SSH key yet, follow the bootstrap in [git/README.md](git/README.md) instead; it creates the key before cloning.

Open a new terminal or run `exec zsh` when done, then run `zhelp` to search every command.
