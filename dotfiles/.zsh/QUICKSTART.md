# Quick Start Guide

## Immediate Usage

Your zsh configuration is now ready to use! Here's what you need to know:

### 🆘 Getting Help

**The most important command to remember:**

```bash
zhelp           # Show all available help categories
```

**Browse by category:**
```bash
zhelp git       # Git aliases and functions
zhelp docker    # Docker aliases and functions
zhelp k8s       # Kubernetes aliases and functions
zhelp node      # Node.js/NPM aliases and functions
zhelp aws       # AWS aliases and functions
zhelp utils     # Utility functions
```

**View all aliases or functions:**
```bash
zhelp aliases   # Show all aliases
zhelp functions # Show all functions
```

**Search for specific commands:**
```bash
zhelp search docker    # Search for docker-related commands
zhelp search port      # Search for port-related commands
```

### Reload Your Shell

```bash
source ~/.zshrc
# or
exec zsh
```

When you reload, you'll see a personalized welcome message showing:
- **Time-based greeting** with your name (Good morning/afternoon/evening, Domen!)
- Your current mode (work/personal) with contextual message
- Node.js version
- Current directory
- Git branch (if applicable)
- Current date and time
- Quick tips about available commands

**To change your name**, add this to `~/.zshrc.local`:
```bash
export ZSH_USER_NAME="Your Full Name"
```

**To disable the welcome message**, add this to `~/.zshrc.local`:
```bash
export ZSH_DISABLE_WELCOME=1
```

### Check Your Current Mode

```bash
zsh_mode
```

### Switch Between Work and Personal

```bash
# Switch to work mode
zsh_switch work

# Switch to personal mode
zsh_switch personal
```

### 💡 Autosuggestions & Syntax Highlighting

**As you type, you'll see:**
- Gray suggestions from history and completions
- Real-time syntax highlighting (green = valid, red = invalid)

**Keyboard shortcuts:**
- `→` (Right Arrow) - Accept full suggestion
- `Ctrl+→` - Accept one word
- `Ctrl+U` - Clear suggestion

**Try it:**
```bash
# Start typing: npm run
# You'll see gray suggestions for scripts from package.json!

# Start typing: git checkout
# You'll see branch names from your repo!
```

## Essential Aliases

### Navigation
```bash
..          # Go up one directory
...         # Go up two directories
ll          # List files with details
la          # List all files including hidden
```

### Git
```bash
gs          # git status
ga          # git add
gc          # git commit
gp          # git push
gl          # git pull
glog        # Pretty git log
```

### Docker
```bash
d           # docker
dc          # docker compose
dcup        # docker compose up
dcdown      # docker compose down
dps         # docker ps
```

### Node.js
```bash
ni          # npm install
nrun        # npm run
pi          # pnpm install
prun        # pnpm run
```

### Kubernetes
```bash
k           # kubectl
kgp         # kubectl get pods
kgs         # kubectl get services
kgd         # kubectl get deployments
```

## Useful Functions

```bash
cleanup_node              # Remove all node_modules and clear npm cache
docker_nuke              # Complete Docker cleanup (with confirmation)
mkcd <directory>         # Create directory and cd into it
extract <archive>        # Extract any archive type
myip                     # Show your public IP
kill_port <port>         # Kill process on specified port
weather [city]           # Show weather (default: Ljubljana)
```

## Customization

### Add Work-Specific Settings

Edit: `~/.zsh/work/aliases.zsh`, `~/.zsh/work/functions.zsh`, `~/.zsh/work/environment.zsh`

### Add Personal Settings

Edit: `~/.zsh/personal/aliases.zsh`, `~/.zsh/personal/functions.zsh`, `~/.zsh/personal/environment.zsh`

### Add Shared Settings (Both Work & Personal)

Edit: `~/.zsh/shared/aliases.zsh`, `~/.zsh/shared/functions.zsh`, `~/.zsh/shared/environment.zsh`

## Git Repository Setup

### Initialize Git Repository

```bash
cd ~/.zsh
git init
git add .
git commit -m "Initial commit of modular zsh configuration"
```

### Push to GitHub

```bash
# Create a new repository on GitHub first, then:
git remote add origin https://github.com/YOUR-USERNAME/dotfiles-zsh.git
git branch -M main
git push -u origin main
```

### Clone on Another Machine

```bash
# Clone repository
cd ~
git clone https://github.com/YOUR-USERNAME/dotfiles-zsh.git .zsh

# Copy .zshrc to home directory
cp ~/.zsh/.zshrc ~/.zshrc

# Or create symlink (alternative)
ln -s ~/.zsh/.zshrc ~/.zshrc

# Reload shell
source ~/.zshrc
```

## File Structure

```
~/.zsh/
├── shared/          # Common configs (always loaded)
│   ├── completions.zsh
│   ├── environment.zsh
│   ├── aliases.zsh
│   ├── functions.zsh
│   └── prompt.zsh
├── work/            # Work-specific configs
│   ├── environment.zsh
│   ├── aliases.zsh
│   └── functions.zsh
└── personal/        # Personal-specific configs
    ├── environment.zsh
    ├── aliases.zsh
    └── functions.zsh
```

## Autocompletion

Press `TAB` after typing commands for smart autocompletion:

- `git <TAB>` - Git commands and branches
- `docker <TAB>` - Docker commands and containers
- `kubectl <TAB>` - Kubernetes resources
- `aws <TAB>` - AWS services and commands
- `npm run <TAB>` - NPM scripts from package.json

## Troubleshooting

### Reload Configuration
```bash
source ~/.zshrc
```

### Rebuild Completions
```bash
rm -f ~/.zcompdump && compinit
```

### Check for Errors
```bash
zsh -x ~/.zshrc
```

## Next Steps

1. ✅ Reload your shell: `source ~/.zshrc`
2. ✅ Customize your work or personal configs
3. ✅ Set up Git repository for syncing
4. ✅ Read full documentation: `cat ~/.zsh/README.md`

---

For detailed documentation, see [README.md](README.md)
