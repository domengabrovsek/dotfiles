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
#    ssh-keygen asks for a passphrase here; install.sh would create the key without one.
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

After step 5, `ssh`, `git pull` and `git push` find the key through the
Include, so `-i` and `GIT_SSH_COMMAND` are no longer needed. Then add the work
identity, as described below.

### What install.sh does

| Step | What | Why |
|---|---|---|
| 1 | Creates `~/.ssh` (mode 700) and `~/.ssh/id_personal` (ed25519, mode 600) if missing | ssh rejects a private key that other users can read |
| 2 | Adds `Include <clone>/git/ssh.config` as the first line of `~/.ssh/config`, after a timestamped backup | ssh uses the first value it finds for each option, so the Include must come before any existing `Host` block |
| 3 | Loads the key into the agent and the macOS keychain | `ssh.config` sets `UseKeychain`, so the key unlocks once per login |
| 4 | Links `~/.gitconfig` to `gitconfig`, backing up a regular file first | Edits in the repo apply at once |
| 5 | Prints the public key and the next commands | You register the key on GitHub by hand |

`install.sh` and `ssh.config` target macOS, because `--apple-use-keychain` and
`UseKeychain` exist only there, and ssh on Linux rejects a config that sets
`UseKeychain`. Don't run `install.sh` on Linux, because its Include would make
every `ssh` command fail. Do its steps by hand instead. Replace the clone path
if yours differs, and rename a regular `~/.gitconfig` to `~/.gitconfig.backup`
first; `ln -sf` replaces an existing link but would also overwrite a real file.
Put the `Host github.com` block above any `Host *` block in `~/.ssh/config`
(create it with mode 600 if missing), for the same first-value reason as the
Include. Print the public key with `cat ~/.ssh/id_personal.pub`,
then register and test it as in step 3 above.

```bash
ssh-keygen -t ed25519 -C "domen@domengabrovsek.com" -f ~/.ssh/id_personal
ln -sf ~/dev/personal/dotfiles/git/gitconfig ~/.gitconfig
```

The block for `~/.ssh/config`:

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_personal
    IdentitiesOnly yes
    AddKeysToAgent yes
```

A re-run with the repo in the same place changes nothing, because every step
first checks whether its result already exists. The Include line
(`Include <clone>/git/ssh.config`) and the `~/.gitconfig` link hold the clone's
absolute path, so after moving the repo, run `install.sh` again. It points
`~/.gitconfig` at the new path and adds a new Include line. Delete the line with
the old path from `~/.ssh/config`; left in place, it points at a file that no
longer exists. On Linux, run the `ln -sf` line again with the new path.

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

1. Create the key: `ssh-keygen -t ed25519 -C "<client email>" -f ~/.ssh/id_<client>`.
2. Register its public key on the client account before pushing anything, or
   every SSH operation against that org fails with `Permission denied (publickey)`.
3. Add an alias for it to `~/.ssh/config`. The alias has its own name, so its
   position relative to the Include does not matter:

   ```
   Host github-<client>
       HostName github.com
       User git
       IdentityFile ~/.ssh/id_<client>
       IdentitiesOnly yes
   ```

4. Route that org through the alias in `~/.gitconfig.local`:

   ```
   [url "git@github-<client>:<client-org>/"]
       insteadOf = git@github.com:<client-org>/
   ```

The work email for those repos still comes from the `includeIf` above.
