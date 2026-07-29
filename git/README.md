# Git Identities (personal + pentla)

Per-context git identity and SSH keys on one machine. Personal is the default;
work repos under `~/dev/work/pentla/` commit as Pentla and push with a separate
key. Structure extends to more clients by copying the pentla pieces.

## Setup (new machine) - full copy-paste flow

This repo is **private** and a fresh machine has no SSH key yet, so bootstrap
with the GitHub CLI (browser login, no key required), then let `install.sh`
create the per-context keys. Run these top to bottom:

```bash
# 1. Homebrew (also triggers the Xcode command line tools / git install)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. GitHub CLI + browser login: choose GitHub.com -> HTTPS -> login with a browser
brew install gh
gh auth login

# 3. Clone this private repo over the gh-authenticated HTTPS connection
gh repo clone domengabrovsek/dotfiles ~/dev/personal/dotfiles

# 4. Generate keys + wire up git and ssh config (idempotent, safe to re-run)
cd ~/dev/personal/dotfiles/git && ./install.sh
```

The script prints two **public** keys. Add each to GitHub at
<https://github.com/settings/keys> (both on the same account if that account is
your Pentla-tech org member), then:

```bash
# 5. Verify SSH auth for both identities
ssh -T git@github.com        # expect: Hi domengabrovsek
ssh -T git@github-pentla     # expect: Hi <pentla user>

# 6. Switch this dotfiles repo to SSH so future pulls use id_personal
git -C ~/dev/personal/dotfiles remote set-url origin git@github.com:domengabrovsek/dotfiles.git

# 7. Clone the rest into the folder that matches each identity
git clone git@github.com:domengabrovsek/personal-api.git ~/dev/personal/personal-api
git clone git@github.com:Pentla-tech/pentla-api.git      ~/dev/work/pentla/pentla-api
```

That is the entire setup - SSH is configured *by* the bootstrap, so nothing has
to be done by hand first.

### What install.sh does

1. Generates `~/.ssh/id_personal` and `~/.ssh/id_pentla` (ed25519) if missing
2. Adds an `Include` for `ssh.config` to the top of `~/.ssh/config`
3. Loads both keys into the agent + macOS keychain
4. Symlinks `~/.gitconfig` -> `gitconfig` and `~/.gitconfig-pentla` -> `gitconfig-pentla`
5. Prints both public keys to register on GitHub

## How it works

| Context | Folder | Email | Key | Host alias |
|---|---|---|---|---|
| Personal (default) | anywhere outside `work/pentla/` | `domen@domengabrovsek.com` | `id_personal` | `github.com` |
| Pentla | `~/dev/work/pentla/` | `domen@pentla.tech` | `id_pentla` | `github-pentla` |

- **Identity** switches by directory (`includeIf "gitdir:~/dev/work/pentla/"`).
- **SSH key** switches by a URL rewrite that maps the whole `Pentla-tech` org to
  the `github-pentla` alias, so cloning a Pentla-tech repo picks `id_pentla`
  regardless of the directory you run `git clone` from.

Clone into the folder that matches the identity:

```bash
git clone git@github.com:domengabrovsek/<repo>.git ~/dev/personal/<repo>
git clone git@github.com:Pentla-tech/<repo>.git    ~/dev/work/pentla/<repo>
```

Confirm the active identity in any repo with `git config user.email`.

## Adding another client

1. `ssh-keygen -t ed25519 -C "<client email>" -f ~/.ssh/id_<client>`
2. Add a `Host github-<client>` block to `ssh.config` pointing at that key
3. Add a `gitconfig-<client>` file with the client name/email
4. In `gitconfig`, add an `includeIf "gitdir:~/dev/work/<client>/"` and a `url`
   rewrite for that client's org

## Not carried over from the old machine

The old `~/.gitconfig` had a GitLab personal access token embedded in a
`url.insteadOf` rewrite (plaintext). It is intentionally excluded here. Revoke
that token in GitLab and, if GitLab is needed again, add an SSH key + host alias
the same way as pentla.
