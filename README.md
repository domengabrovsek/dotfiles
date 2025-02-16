# Dotfiles Sync Tool

A simple bash script to sync dotfiles between your home directory and a local dotfiles directory. This tool helps you manage and version control your configuration files.

## Supported Files

- `.aliases`: Shell aliases
- `.gitconfig`: Git configuration
- `.zshrc`: Zsh shell configuration
- `z.sh`: Z shell script

## Usage

1. Make the script executable:
```bash
chmod +x sync-dotfiles.sh
```

2. Run the script:
```bash
./sync-dotfiles.sh
```

3. Choose sync direction:
   - Option 1: Sync from HOME to local dotfiles directory
   - Option 2: Sync from local dotfiles directory to HOME

## Features

- Bidirectional syncing between HOME and local dotfiles directory
- Automatic creation of dotfiles directory if it doesn't exist
- Color-coded output for better visibility
- Clear feedback on sync status for each file

## Directory Structure

```
./
├── sync-dotfiles.sh
└── dotfiles/
    ├── .aliases
    ├── .gitconfig
    ├── .zshrc
    └── z.sh
```