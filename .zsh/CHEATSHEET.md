# Zsh Configuration Cheat Sheet

Quick reference for the most useful commands, aliases, and functions.

## Getting Help

```bash
zhelp              # Show all help categories
zhelp git          # Git commands
zhelp docker       # Docker commands
zhelp k8s          # Kubernetes commands
zhelp node         # Node.js/NPM commands
zhelp search port  # Search for "port" in all commands
```

## Configuration

```bash
zsh_mode           # Check current mode (work/personal)
zsh_switch work    # Switch to work mode
zsh_switch personal # Switch to personal mode
zsh_welcome        # Show welcome message
reload             # Reload configuration
```

## Git (Most Used)

```bash
gs          # git status
ga <file>   # git add
gaa         # git add .
gc          # git commit
gcm "msg"   # git commit -m "message"
gp          # git push
gl          # git pull
gco <branch> # git checkout
gcb <branch> # git checkout -b (create new branch)
glog        # Pretty git log
gd          # git diff
gds         # git diff --staged

# Functions
qcommit "msg"       # Add all + commit
qpush "msg"         # Add all + commit + push
git_clean_branches  # Delete merged branches
```

## Docker (Most Used)

```bash
d           # docker
dc          # docker compose
dcup        # docker compose up
dcupd       # docker compose up -d
dcdown      # docker compose down
dps         # docker ps
dpsa        # docker ps -a
dclogs      # docker compose logs -f
dex <container> # docker exec -it

# Functions
dsh <container>     # Enter container shell
docker_nuke         # Clean everything (asks for confirmation)
docker_disk_usage   # Show disk usage
```

## Kubernetes (Most Used)

```bash
k           # kubectl
kg          # kubectl get
kgp         # kubectl get pods
kgs         # kubectl get services
kgd         # kubectl get deployments
kd <resource> # kubectl describe
kl          # kubectl logs -f
kx          # kubectl exec -it

# Functions
kctx [context]      # Switch context (no args = list)
kns [namespace]     # Switch namespace (no args = list)
klogp <ns> <pod>    # Get pod logs
kexecp <ns> <pod>   # Exec into pod
```

## Node.js / NPM (Most Used)

```bash
# NPM
ni          # npm install
nrun        # npm run
nstart      # npm start
ndev        # npm run dev
nbuild      # npm run build

# pnpm
pi          # pnpm install
prun        # pnpm run
pdev        # pnpm run dev

# Functions
cleanup_node        # Remove all node_modules + clear cache
npm_globals         # List global packages
```

## Navigation

```bash
..          # cd ..
...         # cd ../..
....        # cd ../../..

ll          # ls -lh (detailed list)
la          # ls -lAh (all files)
lt          # ls -lhtr (sorted by time)

# Functions
mkcd <dir>  # Create directory and cd into it
up [n]      # Go up n directories
```

## Utilities

```bash
# Network
myip                # Show public IP
port_check <port>   # Check if port is in use
kill_port <port>    # Kill process on port

# Files
ff <name>           # Find file by name
fd <name>           # Find directory by name
extract <file>      # Extract any archive
backup <file>       # Create timestamped backup

# System
path                # Show PATH nicely formatted
dirsize [path]      # Show directory size
genpass [length]    # Generate random password
hist_stats          # Show most used commands
weather [city]      # Show weather
```

## AWS

```bash
# Aliases
aws-whoami          # Get current identity
awsp                # Interactive profile switcher (shows menu)
awsc                # Show current profile

# Functions
aws_switch          # Interactive menu to select profile
aws_switch <name>   # Switch to specific profile
aws_current         # Show current profile and verify credentials

# Your prompt shows: ☁︎ profile-name (when AWS_PROFILE is set)
```

## Tips

1. **Tab completion**: Press TAB after any command for smart suggestions
2. **History search**: Use Ctrl+R to search command history
3. **Previous directory**: Use `cd -` to go back to previous directory
4. **Command help**: Most functions show usage if called without arguments
5. **Disable welcome**: Add `export ZSH_DISABLE_WELCOME=1` to `~/.zshrc.local`

## Quick Examples

```bash
# Start working on a project
mkcd my-new-project
npm_init
gcb feature/my-feature

# Clean up Docker
docker_nuke

# Quick commit and push
qpush "Add new feature"

# Switch Kubernetes context and namespace
kctx production
kns my-app

# Find and kill a process on port 3000
kill_port 3000
```

## Customization

- **Work config**: `~/.zsh/work/`
- **Personal config**: `~/.zsh/personal/`
- **Shared config**: `~/.zsh/shared/`
- **Local overrides**: `~/.zshrc.local` (not committed to git)

## Learn More

- Full documentation: `cat ~/.zsh/README.md`
- Interactive help: `zhelp`
- Quick start: `cat ~/.zsh/QUICKSTART.md`
