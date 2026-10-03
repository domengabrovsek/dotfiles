# Zsh Configuration

A modular zsh setup on Oh My Zsh, with one module per tool, a prompt that shows
the host, folder, git branch, cloud account and Node version, and `zhelp` to
search every command. It runs on macOS and on Debian/Ubuntu.

For how it loads and why it is built this way, see
[ARCHITECTURE.md](ARCHITECTURE.md).

## Setup

On a machine that already has its GitHub SSH key:

```bash
git clone git@github.com:domengabrovsek/dotfiles.git ~/dev/personal/dotfiles
cd ~/dev/personal/dotfiles/zsh && ./install.sh
```

On a machine without one, follow the bootstrap in
[git/README.md](../git/README.md) first.

`install.sh` is safe to re-run; each step skips what is already in place.

| Step | macOS | Debian / Ubuntu |
|---|---|---|
| Package manager | Homebrew, installed if missing | apt; zsh installed if missing |
| Oh My Zsh and plugins | zsh-autosuggestions, zsh-syntax-highlighting | Same |
| CLI tools: fzf, eza, bat, zoxide | Homebrew | apt, skipping any the release does not package (Debian 12 has no eza) |
| nvm and Node | nvm into `~/.nvm`, Node pinned by `NODE_VERSION` | Same |
| Cloud CLIs: aws, gcloud, session-manager-plugin | Installed; AWS and gcloud configs set up from the `*.local` files | Skipped |
| Links into `$HOME` | `~/.zsh`, `~/.zshrc`, `~/.zshenv`, `~/.aws/config` | `~/.zsh`, `~/.zshrc`, `~/.zshenv` |
| Login shell | Already zsh | Changed to zsh, effective at next login |

Homebrew is not used on Linux because it has no ARM64 Linux bottles, so every
formula would compile from source on ARM Linux hosts. The cloud CLIs stay on
the workstation, so those hosts hold no cloud credentials. The modules only
source cloud files that exist, so the shell still loads without them.

Node is pinned to one exact version so every machine runs the same toolchain.
To move them all, change `NODE_VERSION` in `install.sh` and re-run it on each
machine.

`~/.zsh` links to this folder, so edits under `~/.zsh` change the repo, and
`git pull` updates the shell. The link must stay at `~/.zsh`; see
[ARCHITECTURE.md](ARCHITECTURE.md#decisions-that-are-easy-to-undo-by-accident).

After install, open a new terminal or run `exec zsh`.

## Prompt

```
💻 hostname · 📁 folder · ±(branch) · ☁︎ aws · ☁︎ gcp (account) · ⬢ node (npm) →
```

```
💻 server · 📁 repos · ⬢ v24.21.0 (11.19.0) →
💻 domen-mbp · 📁 dotfiles · ±(main) · ☁︎ my-project (me@example.com) · ⬢ v24.21.0 (11.19.0) →
```

- **Glyphs.** Every section has one, so you can find a section without reading
  the others.
- **Dots.** A dot sits between every pair of sections, in a grey used nowhere
  else, so boundaries stand out. Each segment brings its own dot, so outside a
  repo, or on a machine with no Node, the segment and its dot disappear
  together.
- **Hostname first.** The same config runs on the Mac and the Linux hosts, and
  they reach each other over SSH, so the prompt says which machine you are on.
  It uses `%m`, the short hostname. If a machine reports something too long,
  set `ZSH_PROMPT_HOST=mbp` in `~/.zshrc.local`.
- **Folder.** Only the current folder (`%1~`).
- **Branch.** The current git branch, only inside a repo.
- **Cloud segments.** AWS shows `$AWS_PROFILE` (or `$AWS_DEFAULT_PROFILE`) in
  orange, only while one is set. GCP shows the active gcloud configuration and
  its account in blue, and hides itself while the configuration is named
  `default`. Both use the `☁︎` glyph, so the colour tells them apart.
- **Node.** The Node version, with npm's in parentheses when found.

## Help

```bash
zhelp            # fzf search over every command (less without fzf)
zhelp docker     # filter by keyword
```

## Key bindings

| Shortcut | Action |
|---|---|
| `Ctrl+R` | Fuzzy history search (fzf) |
| `Ctrl+T` | Fuzzy file finder (fzf) |
| `Alt+C` | Fuzzy cd into a subfolder (fzf) |
| `→` or `Ctrl+E` | Accept the whole autosuggestion |
| `Ctrl+→` | Accept one word of it |
| `Ctrl+U` | Clear it |

Autosuggestions come from history and completions, fetched asynchronously, for
input up to 20 characters. The settings are in `modules/environment.zsh`.

## Cloud accounts

The cloud commands exist on macOS only, where `install.sh` installs the CLIs.
Create the two `*.local` files below before running `install.sh`, or run its
steps by hand afterwards: `ln -sf ~/.zsh/aws/config.local ~/.aws/config` and
`~/.zsh/gcp/configurations.sh`.

`install.sh` links `~/.aws/config` to `aws/config.local`, which git ignores.
Start it from `aws/config.example`, which defines the `personal` SSO session,
then log in with `aws sso login --sso-session personal`.

| Command | Action |
|---|---|
| `awsp` | Pick a profile with fzf; the preview shows its account and role |
| `awsp <name>` | Switch to that profile; other text pre-fills the picker |
| `awsp off` | Clear `AWS_PROFILE` |
| `awsc` | Show the profile and `sts get-caller-identity` |

`awsp` runs `aws sso login` only when the cached session has expired. The
profile is per terminal, so two terminals can use two accounts.

`gcp/configurations.sh` creates the gcloud configurations listed in
`gcp/configurations.local`, which git ignores, one
`<name> <account> <project> <region> <zone>` per line. Log in to each account
once with `gcloud auth login <account>`.

| Command | Action |
|---|---|
| `gcpp [name]` | Pick a gcloud configuration with fzf; an exact name switches directly, other text pre-fills the picker |
| `gcpa [account]` | Same, for the account on the active configuration |
| `gcpc` | Show configuration, account, project and region |

Switch with `gcpp` or `gcpa` rather than `gcloud config` directly, so the
prompt updates.

## Common commands

`zhelp` lists them all. A sample:

| Area | Commands |
|---|---|
| Git | `gs`, `gaa`, `gcm "msg"`, `gp`, `gl`, `gsw`/`gswc`, `glog`, `qpush "msg"`, `fbr` (fzf branch switcher), `flog` |
| Docker | `dc`, `dcup`/`dcupd`/`dcdown`, `dps`, `dsh <ctr>` (shell into a container), `docker_nuke` |
| Kubernetes | `k`, `kgp`/`kgs`/`kgd`, `kl`, `kx`, `kctx`/`kns` |
| Cloud Run | `cr-find`, `cr-info`, `cr-logs`, `cr-errors`; `gcp-debug-help` lists the rest |
| Files | `ll`/`la`/`lt`, `tree` (with eza), `cat` (bat), `z <dir>` (zoxide), `mkcd`, `extract <file>` (tar, tgz, tbz2, gz, bz2, zip, 7z, rar, Z) |
| Utilities | `myip`, `ports`, `kill_port <p>`, `genpass [len]`, `weather [city]`, `flushdns` (macOS) |

## Customization

`~/.zshrc.local` sits outside the repo, and you create it yourself. It loads
after the modules, so it can override them. Use it for machine paths and
personal settings:

```bash
export ZSH_PROMPT_HOST=mbp          # shorter hostname in the prompt
export ZSH_USER_NAME="Your Name"    # name in the welcome banner
export ZSH_DISABLE_WELCOME=1        # no welcome banner
```

To add a command or a module, see
[ARCHITECTURE.md](ARCHITECTURE.md#making-a-change-safely).

## Updating

```bash
cd ~/.zsh && git pull && exec zsh
```

## Troubleshooting

- **Slow startup.** The shell prints its startup time. Compare with
  `time zsh -i -c exit`, then look for the change that added a subprocess at
  load time.
- **Completions broken.** Delete `~/.zcompdump*` and `~/.zsh/cache/*.zsh`, then
  run `exec zsh`. Oh My Zsh rebuilds the dump, and the shell regenerates the
  cache files, which git ignores. Don't run `compinit` by hand, because a
  second run drops every completion registered before it
  ([ARCHITECTURE.md](ARCHITECTURE.md#decisions-that-are-easy-to-undo-by-accident)).
- **Change not showing.** Run `exec zsh`.
