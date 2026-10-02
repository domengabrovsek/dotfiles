# Git Identities

Per-context git identity on one machine. Personal is the default. Work repos
switch their commit email by directory through `~/.gitconfig.local`, which is
not tracked. Both push with the same SSH key when the personal GitHub account
has access to the work org, so only the commit email differs.

## Setup (new machine) - full copy-paste flow

A fresh machine has no SSH key yet, so create the GitHub key first, register
it, then clone over SSH. Run these top to bottom:

```bash
# 1. Homebrew (also triggers the Xcode command line tools / git install)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Create the GitHub key. install.sh keeps it once it exists.
ssh-keygen -t ed25519 -C "domen@domengabrovsek.com" -f ~/.ssh/id_personal
pbcopy < ~/.ssh/id_personal.pub
```

Add the copied **public** key at <https://github.com/settings/keys>, then:

```bash
# 3. Verify SSH auth (~/.ssh/config does not name the key yet, hence -i)
ssh -i ~/.ssh/id_personal -T git@github.com    # expect: Hi domengabrovsek

# 4. Clone this repo over SSH with that key
GIT_SSH_COMMAND="ssh -i ~/.ssh/id_personal" \
  git clone git@github.com:domengabrovsek/dotfiles.git ~/dev/personal/dotfiles

# 5. Wire up git and ssh config (idempotent, safe to re-run)
cd ~/dev/personal/dotfiles/git && ./install.sh
```

Then add the work identity, as described below.

### What install.sh does

1. Generates `~/.ssh/id_personal` (ed25519) if missing
2. Adds an `Include` for `ssh.config` to the top of `~/.ssh/config`
3. Loads the key into the agent + macOS keychain
4. Symlinks `~/.gitconfig` -> `gitconfig`
5. Prints the public key to register on GitHub

## Work identity

`gitconfig` includes `~/.gitconfig.local` last, so anything there overrides it.
To commit as a work email inside one folder, keep the identity in its own file
and switch to it by directory:

```bash
printf '[user]\n\tname = <name>\n\temail = <work email>\n' > ~/.gitconfig-<client>
printf '[includeIf "gitdir:~/dev/work/<client>/"]\n\tpath = ~/.gitconfig-<client>\n' >> ~/.gitconfig.local
```

The trailing slash in `gitdir:` means "this folder and everything under it".
Confirm the active identity in any repo with `git config user.email`.

The SSH key does not switch. One key serves both contexts while the personal
account is a member of the work org.

## Separate GitHub account for a client

Only if a client requires a **separate GitHub account** do you need a second
key, because a key can be registered on exactly one account:

1. `ssh-keygen -t ed25519 -C "<client email>" -f ~/.ssh/id_<client>`
2. Add a `Host github-<client>` block pointing at that key, in `~/.ssh/config`
3. In `~/.gitconfig.local`, add a `url` rewrite mapping that client's org onto the alias
4. Register the pubkey on the client account before pushing anything, or every
   SSH operation against that org fails with `Permission denied (publickey)`
