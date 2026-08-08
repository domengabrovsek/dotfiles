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

## Homelab Raspberry Pis

`ssh.config` also defines aliases for the homelab hosts, so `ssh pi5` / `ssh pi4`
/ `ssh air` work on a new machine the moment the config is Included. Each host
has two aliases - the bare name for the LAN IP, and `<name>-remote` for the
Tailscale IP:

| Host | Login user | LAN alias | LAN IP | Remote alias | Tailscale IP |
|---|---|---|---|---|---|
| pi5 (Raspberry Pi 5) | `pi` | `pi5` | `192.168.0.2` | `pi5-remote` | `100.108.45.53` |
| pi4 (Raspberry Pi 4) | `domengabrovsek` | `pi4` | `192.168.0.3` | `pi4-remote` | `100.108.62.122` |
| air (M1 MacBook Air, Asahi) | `pi` | `air` | `192.168.0.108` | `air-remote` | `100.117.139.53` |

The login user differs per host - pi4 predates the convention and uses
`domengabrovsek` where the others use `pi`. The aliases encode this, so `ssh pi4`
works without remembering it.

The aliases share one key, `~/.ssh/id_rpi5`, which is **not** in
this repo (it is a private key). Running `git/install.sh` installs the config
but cannot install the key - that is the one manual step below.

### New-machine setup (recommended: per-machine key)

Each machine gets its own keypair, so a lost or retired laptop is revoked by
deleting one line on each Pi - no shared private key travels over the network.
The new key is saved at the path `ssh.config` already expects
(`~/.ssh/id_rpi5`), so `ssh pi5` / `ssh pi4` work with zero config
edits; the pubkey **comment** (not the filename) is what tells the machines
apart in `authorized_keys`.

Run top to bottom on the **new machine**:

```bash
# 1. Config: install.sh wires ssh.config's Include (skip if already run for git).
cd ~/dev/personal/dotfiles/git && ./install.sh

# 2. Tailscale, so the `-remote` (100.x) aliases resolve off the home network.
#    The Pis are already on the tailnet; only the new machine needs joining.
brew install --cask tailscale && open -a Tailscale   # then log in via the menu-bar app
#    or headless: brew install tailscale && sudo tailscale up

# 3. Generate a fresh key. The -C comment identifies THIS machine (use for revoke).
#    LocalHostName, not ComputerName: ComputerName can hold spaces, apostrophes,
#    and emoji, which produce an unreadable authorized_keys comment.
ssh-keygen -t ed25519 -C "id_rpi5_$(scutil --get LocalHostName)" \
  -f ~/.ssh/id_rpi5
ssh-add --apple-use-keychain ~/.ssh/id_rpi5   # or just re-run ./install.sh

# 4. Show the PUBLIC key - authorize it on each Pi using one bridge below.
cat ~/.ssh/id_rpi5.pub
```

The new machine can't SSH in yet, so authorize its **public** key through one
trusted bridge:

**Bridge A - the old machine still reaches the Pis.** Copy the new `.pub` to the
old machine (`pbcopy < ~/.ssh/id_rpi5.pub`, then paste into a temp
file there), and from the **old machine** push it onto each Pi:

```bash
ssh-copy-id -i /path/to/new_machine.pub pi5   # User pi
ssh-copy-id -i /path/to/new_machine.pub pi4   # User domengabrovsek
```

**Bridge B - no old machine; run this on each Pi directly** (physical keyboard
or an existing session). Paste the pubkey line printed in step 4:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo 'ssh-ed25519 AAAA...paste-the-pubkey... id_rpi5_<new-machine>' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

That paste is the only thing that runs on the Pi itself - no `sshd_config`
changes, the Pis already do key auth.

### Verify (on the new machine)

```bash
ssh pi5           # LAN       (192.168.0.2, user pi)
ssh pi4           # LAN       (192.168.0.3, user domengabrovsek)
ssh air           # LAN       (192.168.0.108, user pi)
ssh pi5-remote    # Tailscale (100.x, works off-network)
ssh pi4-remote
ssh air-remote
```

If LAN works but `-remote` hangs, the new machine isn't on the tailnet (re-check
step 2). If both hang, the pubkey didn't land in the Pi's `authorized_keys`.

### Retiring the old machine

Revoke its key so a decommissioned laptop can't get back in - on **each Pi**,
delete the old machine's line from `~/.ssh/authorized_keys` (find it by its `-C`
comment). If both laptops stay in service, leave both pubkeys in place.

Audit what is currently authorized across the homelab from the Mac:

```bash
for h in pi5 pi4 air; do
  echo "### $h"
  ssh "$h" 'ssh-keygen -lf ~/.ssh/authorized_keys'
done
```

Every line should map to a machine still in service. To check whether a key is
actually in use before removing it, look at what has logged in recently - a key
with no logins is safe to drop, one with hundreds is load-bearing:

```bash
ssh pi5 'sudo journalctl -u ssh --since "30 days ago" --no-pager \
  | awk "/Accepted publickey/ {print \$(NF-5), \$NF}" | sort | uniq -c | sort -rn'
```

That prints `count  source-ip  fingerprint`, which also identifies *which*
machine a mystery key belongs to.

### Alternative: reuse the existing key

Simplest, no Pi changes, but copies a private key over the network and can't be
revoked per machine - prefer the per-machine key above. From the machine that
still has it:

```bash
scp ~/.ssh/id_rpi5 <new-machine>:~/.ssh/
```

On the new machine, load it (or just re-run `./install.sh`, which now does this):

```bash
chmod 600 ~/.ssh/id_rpi5
ssh-add --apple-use-keychain ~/.ssh/id_rpi5
```

### GitHub keys on the homelab hosts

Two different directions of access are easy to confuse, so keep them apart:

- **Mac -> host** is `id_rpi5`, generated on the Mac, authorized in each host's
  `authorized_keys`. Covered above.
- **Host -> GitHub** is a *separate* key that lives only on that host, so the
  Pis can `git pull` and `git push` their own clones. Covered here.

Each host keeps its own GitHub key at `~/.ssh/id_github_<hostname>`, and every
one of them is registered on the same `domengabrovsek` GitHub account:

| Host | Key file | Fingerprint |
|---|---|---|
| pi5 | `~/.ssh/id_github_rpi5` | `SHA256:7NBRZFhlU7Me8iHFXkH8tvwMnSWl/NKxhylMRcd9GEw` |
| pi4 | `~/.ssh/id_github_rpi4` | `SHA256:HErq5lFm6mP4eyXiHz1j0j2+OIgGmH+4ZvMbNle2624` |
| air | `~/.ssh/id_github_air` | `SHA256:Zl6UHPiDzYDkRSnTyHASx/z4Kk/CHKN/pwJXx/XVLB4` |

The `id_github_<hostname>` name is the convention - one key per host means a
compromised or retired host is revoked by deleting a single key at
<https://github.com/settings/keys>, without touching the others. The `-C`
comment is the account email on all of them, because the filename already
carries the host.

These hosts run Linux and do not Include this repo's `ssh.config` (it is
macOS-flavoured: `UseKeychain`, the Pi host aliases). Each keeps a small
hand-written `~/.ssh/config`. That is the fragile part - a typo there is only
discovered the next time a push fails - so set it up by copy-paste:

```bash
# On the host itself. Replace <hostname> with pi5 / pi4 / air.
ssh-keygen -t ed25519 -C "domen@domengabrovsek.com" -f ~/.ssh/id_github_<hostname>
cat >> ~/.ssh/config <<'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_github_<hostname>
    IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config
cat ~/.ssh/id_github_<hostname>.pub   # add this at github.com/settings/keys
ssh -T git@github.com                 # expect: Hi domengabrovsek
```

To audit every host at once from the Mac:

```bash
for h in pi5 pi4 air; do
  printf '%-5s ' "$h"
  ssh "$h" 'ssh -o BatchMode=yes -T git@github.com 2>&1 | head -1'
done
```

A `no such identity` line in that output means the host's `~/.ssh/config`
points at a filename that does not exist - compare it against the table above.

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
