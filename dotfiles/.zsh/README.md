# Modular Zsh Configuration

A clean, modular, and maintainable Zsh configuration that supports both work and personal environments with shared common configurations.

## Preview

When you open a new terminal, you'll be greeted with:

```
╔════════════════════════════════════════════════════════════════╗
║     Good morning, Domen! Welcome back 👋                       ║
╚════════════════════════════════════════════════════════════════╝

🏠 Mode: personal - Happy coding!
⬢  Node.js: v22.14.0
📂 Directory: ~/projects/my-app
±  Git branch: main
🕐 Time: Saturday, November 16, 2025 - 09:30

💡 Type 'zhelp' to see available commands
⚙️  Type 'zsh_switch' to change modes

~/projects/my-app ±(main) ⬢ v22.14.0 →
```

The greeting changes based on the time of day (Good morning/afternoon/evening) and shows personalized messages for work/personal modes!

## Features

- **Built-in Help System**: Interactive help to discover all available commands (`zhelp`)
- **Live Autosuggestions**: Fish-shell-like suggestions as you type from history and completions
- **Syntax Highlighting**: Commands are highlighted as you type (green for valid, red for invalid)
- **Modular Structure**: Organized into shared, work, and personal configurations
- **Smart Autocompletion**: Enhanced completions for:
  - Node.js, NPM, NVM
  - Docker & Docker Compose
  - Kubernetes (kubectl)
  - AWS CLI
  - GCP (gcloud)
  - Git
  - Terraform
  - And more...
- **Rich Aliases**: Comprehensive set of useful aliases for common tasks
- **Custom Functions**: Utility functions for development, deployment, and system management
- **Easy Mode Switching**: Seamlessly switch between work and personal configurations
- **Custom Prompt**: Beautiful prompt showing current directory, git status, and Node.js version
- **Git-Friendly**: Designed to be version-controlled and shared across machines

## Directory Structure

```
~/
├── .zshrc                  # Main entry point
└── .zsh/
    ├── README.md           # Full documentation (this file)
    ├── QUICKSTART.md       # Quick start guide
    ├── CHEATSHEET.md       # Quick reference for most used commands
    ├── .gitignore          # Git ignore rules
    ├── install.sh          # Installation script for new machines
    ├── shared/             # Common configs (always loaded)
    │   ├── completions.zsh # Tool completions and autocompletion settings
    │   ├── environment.zsh # Environment variables and shell settings
    │   ├── aliases.zsh     # Common aliases
    │   ├── functions.zsh   # Common utility functions (includes help system)
    │   └── prompt.zsh      # Custom prompt configuration
    ├── work/               # Work-specific configs
    │   ├── environment.zsh # Work environment variables
    │   ├── aliases.zsh     # Work-specific aliases
    │   └── functions.zsh   # Work-specific functions
    └── personal/           # Personal-specific configs
        ├── environment.zsh # Personal environment variables
        ├── aliases.zsh     # Personal-specific aliases
        └── functions.zsh   # Personal-specific functions
```

## Installation

### 1. Backup Your Current Configuration

```bash
# Backup your current .zshrc
cp ~/.zshrc ~/.zshrc.backup

# Backup your current .zsh directory if it exists
if [ -d ~/.zsh ]; then
  mv ~/.zsh ~/.zsh.backup
fi
```

### 2. Clone or Download This Configuration

**Option A: If you already have these files locally**

The files are already in place! Just reload your shell:

```bash
source ~/.zshrc
```

**Option B: Set up Git repository for syncing across machines**

```bash
# Initialize git repository in .zsh directory
cd ~/.zsh
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Ignore cache
cache/

# Ignore local overrides
*.local
EOF

# Add and commit files
git add .
git commit -m "Initial commit of modular zsh configuration"

# Add your remote repository (create one on GitHub first)
git remote add origin https://github.com/YOUR-USERNAME/dotfiles-zsh.git
git branch -M main
git push -u origin main
```

### 3. Install Dependencies

This configuration works best with:

- **Oh My Zsh**: [Installation instructions](https://ohmyz.sh/)
- **NVM**: [Installation instructions](https://github.com/nvm-sh/nvm)
- **z**: [Installation instructions](https://github.com/rupa/z) (for quick directory navigation)

## Usage

### Switching Between Work and Personal Modes

**Check Current Mode:**
```bash
zsh_mode
```

**Switch Modes:**
```bash
# Switch to work mode
zsh_switch work

# Switch to personal mode
zsh_switch personal
```

**Set Default Mode:**

Edit `~/.zshrc` and change line 27:
```bash
export ZSH_CONFIG_MODE="${ZSH_CONFIG_MODE:-personal}"  # Change 'personal' to 'work'
```

Or add to `~/.zprofile` (loaded before `.zshrc`):
```bash
export ZSH_CONFIG_MODE=work
```

### Discovering Available Commands

**The configuration includes a built-in help system to discover all available commands!**

```bash
# Show main help menu
zhelp

# Browse by category
zhelp git       # Git aliases and functions
zhelp docker    # Docker aliases and functions
zhelp k8s       # Kubernetes aliases and functions
zhelp node      # Node.js/NPM aliases and functions
zhelp aws       # AWS aliases and functions
zhelp utils     # Utility functions

# View all aliases or functions
zhelp aliases   # Show all aliases
zhelp functions # Show all functions

# Search for specific commands
zhelp search docker    # Find docker-related commands
zhelp search port      # Find port-related commands
```

This is the easiest way to discover what's available and learn how to use it!

### Using Autosuggestions

As you type commands, you'll see **gray suggestions** appear based on:
- **Command history**: Commands you've used before
- **Completions**: Valid options for the current command

**How to use:**
- **Accept full suggestion**: Press `→` (Right Arrow) or `Ctrl+E`
- **Accept one word**: Press `Ctrl+→` (Ctrl+Right Arrow)
- **Clear suggestion**: Press `Ctrl+U`

**Examples:**
```bash
# Type: npm run
# See gray suggestions for scripts from package.json

# Type: git checkout
# See suggestions for branch names from your repo

# Type: docker exec
# See suggestions for running container names
```

The suggestions are context-aware and will show relevant options based on what you're typing!

### Syntax Highlighting

Commands are highlighted in real-time as you type:
- **Green**: Valid command that exists
- **Red**: Invalid command or typo
- **Yellow**: Aliases
- **Blue**: Keywords and built-ins

This helps you catch typos before pressing Enter!

### Customizing Your Configuration

#### Adding Work-Specific Settings

Edit files in `~/.zsh/work/`:

**Environment Variables** (`~/.zsh/work/environment.zsh`):
```bash
export AWS_PROFILE=work-profile
export AWS_REGION=us-east-1
```

**Aliases** (`~/.zsh/work/aliases.zsh`):
```bash
alias ssh-bastion='ssh user@bastion.company.com'
alias work='cd ~/work/main-project'
```

**Functions** (`~/.zsh/work/functions.zsh`):
```bash
deploy_staging() {
  echo "Deploying to staging..."
  # Your deployment commands
}
```

#### Adding Personal-Specific Settings

Edit files in `~/.zsh/personal/` following the same pattern as work configs.

#### Adding Shared Settings

Edit files in `~/.zsh/shared/` for settings that apply to both work and personal environments.

### Machine-Specific Configurations

Create `~/.zshrc.local` for machine-specific settings that shouldn't be committed to git:

```bash
# Machine-specific settings
export SOME_LOCAL_VAR="value"

# API keys (though consider using a proper secret manager)
export API_KEY="secret-key"
```

This file is automatically loaded if it exists and is ignored by git.

### Customizing the Welcome Message

When you open a new terminal, you'll see a personalized welcome message showing:
- **Personalized greeting** with your name and time-based greeting (morning/afternoon/evening)
- **Current mode** (work/personal) with contextual message
- **Node.js version** (if installed)
- **Current directory**
- **Git branch** (if in a git repository)
- **Current date and time**
- **Quick tips**

**To change your name:**

Add this to `~/.zshrc.local`:
```bash
export ZSH_USER_NAME="Your Full Name"
```

The default is "Domen" but you can set it to any name you prefer!

**To disable the welcome message:**

Add this to `~/.zshrc.local`:
```bash
export ZSH_DISABLE_WELCOME=1
```

**To use a simpler welcome message:**

Edit `~/.zshrc` and replace the `zsh_welcome` call with:
```bash
echo "👋 Welcome! Running in $ZSH_CONFIG_MODE mode. Type 'zhelp' for help."
```

**To customize the welcome message:**

Edit the `zsh_welcome()` function in `~/.zsh/shared/functions.zsh` to show whatever information you prefer. You can customize:
- The greeting messages for different times of day
- The mode-specific messages ("Time to get things done!" for work, "Happy coding!" for personal)
- What information is displayed
- The colors and formatting

## Common Aliases

### Navigation
- `..`, `...`, `....` - Go up directories
- `ll`, `la`, `lt` - List files with different options

### Git
- `g`, `gs`, `ga`, `gc`, `gp`, `gl` - Common git commands
- `glog`, `gloga` - Pretty git logs

### Docker
- `d`, `dc` - Docker and docker compose shortcuts
- `dps`, `dpsa` - List containers
- `dcup`, `dcdown` - Start/stop compose services

### Kubernetes
- `k`, `kg`, `kd` - kubectl shortcuts
- `kgp`, `kgs`, `kgd` - Get pods, services, deployments

### Node.js/NPM
- `ni`, `nrun`, `nstart`, `ntest` - npm shortcuts
- `pi`, `prun`, `pstart` - pnpm shortcuts

[See `~/.zsh/shared/aliases.zsh` for the complete list]

## Useful Functions

### Node.js
- `cleanup_node` - Remove all node_modules and clear npm cache
- `npm_globals` - List global npm packages

### Docker
- `docker_nuke` - Complete Docker cleanup (with confirmation)
- `dsh <container>` - Enter a running container

### Git
- `qcommit <message>` - Quick add all and commit
- `qpush <message>` - Quick commit and push
- `git_clean_branches` - Delete merged branches

### Utilities
- `mkcd <dir>` - Create directory and cd into it
- `extract <file>` - Extract any archive type
- `myip` - Show public IP
- `kill_port <port>` - Kill process on specified port
- `weather [city]` - Show weather

[See `~/.zsh/shared/functions.zsh` for the complete list]

## Autocompletion

This configuration provides smart autocompletion for:

- **Git**: Branch names, commands, etc.
- **Docker**: Container names, images, commands
- **Kubectl**: Resources, contexts, namespaces
- **AWS CLI**: Services, commands, resources
- **GCP**: Projects, regions, services
- **NPM/NVM/Node**: Scripts, packages, versions
- **Terraform**: Commands, resources

Just type the command and press `TAB` for intelligent suggestions!

## Syncing Across Multiple Machines

### First Time Setup on New Machine

1. Install dependencies (Oh My Zsh, NVM, etc.)
2. Clone your dotfiles repository:

```bash
cd ~
git clone https://github.com/YOUR-USERNAME/dotfiles-zsh.git .zsh
```

3. Create symlink for .zshrc:

```bash
ln -s ~/.zsh/.zshrc ~/.zshrc
```

Or copy it:

```bash
cp ~/.zsh/.zshrc ~/.zshrc
```

4. Reload shell:

```bash
source ~/.zshrc
```

### Updating Configuration

When you make changes:

```bash
cd ~/.zsh
git add .
git commit -m "Update configuration"
git push
```

On other machines:

```bash
cd ~/.zsh
git pull
source ~/.zshrc
```

## Troubleshooting

### Slow Shell Startup

1. Check if NVM is loading slowly - consider using lazy loading
2. Disable unused plugins in `.zshrc`
3. Use `time zsh -i -c exit` to measure startup time

### Completions Not Working

1. Make sure completion cache directory exists:
```bash
mkdir -p ~/.zsh/cache
```

2. Rebuild completions:
```bash
rm -f ~/.zcompdump && compinit
```

### Changes Not Taking Effect

Reload your shell:
```bash
source ~/.zshrc
# or
exec zsh
```

## Contributing

Feel free to customize this configuration to your needs! Here are some ideas:

- Add more aliases for tools you use frequently
- Create custom functions for repetitive tasks
- Add completions for additional tools
- Share improvements with others!

## Tips

1. **Keep Secrets Out of Git**: Use `~/.zshrc.local` for API keys and sensitive data
2. **Document Your Changes**: Add comments to explain custom configurations
3. **Regular Backups**: Commit and push changes regularly
4. **Test Before Committing**: Make sure changes work before pushing to avoid breaking other machines
5. **Use Semantic Commits**: Use clear commit messages like "Add AWS deployment functions"

## Resources

- [Zsh Documentation](http://zsh.sourceforge.net/Doc/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Awesome Zsh Plugins](https://github.com/unixorn/awesome-zsh-plugins)

## License

Feel free to use and modify this configuration for your own purposes!

---

**Happy coding!** 🚀
