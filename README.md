# Dotfiles

Personal shell and git setup for a Mac and a few Linux hosts. It has two
independent parts, each with its own installer; use either one alone.

| Part | Sets up | Docs |
|---|---|---|
| `zsh/` | Oh My Zsh, one module per tool, the prompt, `zhelp`, CLI tools, nvm with a pinned Node, cloud CLIs on macOS | [zsh/README.md](zsh/README.md), [zsh/ARCHITECTURE.md](zsh/ARCHITECTURE.md) |
| `git/` | GitHub SSH key and config, git identity with a per-folder work email (macOS) | [git/README.md](git/README.md) |

## How the repo reaches your home folder

The installers link files into `$HOME` instead of copying them, so the repo
stays the only copy. Edits show up in `git diff`, and `git pull` updates the
machine. A regular file already at a link's path is renamed to
`<file>.backup-<timestamp>` first.

| In `$HOME` | Points to | Created by |
|---|---|---|
| `~/.zsh` | `zsh/` | `zsh/install.sh` |
| `~/.zshrc`, `~/.zshenv` | `~/.zsh/.zshrc`, `~/.zsh/.zshenv` | `zsh/install.sh` |
| `~/.aws/config` | `zsh/aws/config.local`, on macOS once that file exists; re-run the installer after creating it | `zsh/install.sh` |
| `~/.gitconfig` | `git/gitconfig` | `git/install.sh` |
| `Include` line in `~/.ssh/config` | `git/ssh.config` | `git/install.sh` |

## What stays out of git

The repo is public. Anything specific to a machine, an employer or an account
lives in a file git ignores (`*.local` in `.gitignore`) or outside the repo:
`~/.zshrc.local`, `~/.gitconfig.local`, `zsh/aws/config.local` and
`zsh/gcp/configurations.local`. They do not sync, so copy them to each machine.
[zsh/ARCHITECTURE.md](zsh/ARCHITECTURE.md#files-that-stay-out-of-git) and
[git/README.md](git/README.md#work-identity) say what goes in each.

## Setup

Clone over SSH, then run the installer for each part you want:

```bash
git clone git@github.com:domengabrovsek/dotfiles.git ~/dev/personal/dotfiles
~/dev/personal/dotfiles/zsh/install.sh
~/dev/personal/dotfiles/git/install.sh
```

A machine without a GitHub SSH key cannot clone yet. Read the bootstrap in
[git/README.md](git/README.md) on GitHub; it creates the key first. Both
installers are safe to re-run. Afterwards, open a new terminal or run
`exec zsh`.

## Pull requests

Every change lands through a pull request. `main` requires one status check,
`Gate`, from `.github/workflows/pull-request.yml`, and resolved review
conversations; it needs no approving review. `Gate` always passes, because the
repo has no tests; it exists because branch protection requires a check.
Dependabot (`.github/dependabot.yml`) groups GitHub Actions updates into one
monthly pull request.
