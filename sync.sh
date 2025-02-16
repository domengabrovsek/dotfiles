#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# List of dotfiles to sync
dotfiles=(
    ".aliases"
    ".gitconfig"
    ".zshrc"
    "z.sh"
)

# Get the current directory and set up paths
CURRENT_DIR=$(pwd)
DOTFILES_DIR="$CURRENT_DIR/dotfiles"

# Create dotfiles directory if it doesn't exist
if [ ! -d "$DOTFILES_DIR" ]; then
    mkdir -p "$DOTFILES_DIR"
    echo -e "${BLUE}Created dotfiles directory at:${NC} $DOTFILES_DIR"
fi

# Function to sync a file
sync_file() {
    local file=$1
    local source_path=$2
    local dest_path=$3

    if [ -f "$source_path" ]; then
        cp "$source_path" "$dest_path"
        echo -e "${GREEN}✓${NC} Synced $file"
    else
        echo -e "${RED}✗${NC} $file not found at source: $source_path"
    fi
}

# Function to sync files in a specific direction
sync_files() {
    local direction=$1
    local source_dir
    local dest_dir
    
    if [ "$direction" = "to_local" ]; then
        source_dir="$HOME"
        dest_dir="$DOTFILES_DIR"
        echo "Syncing from HOME to local dotfiles directory"
    else
        source_dir="$DOTFILES_DIR"
        dest_dir="$HOME"
        echo "Syncing from local dotfiles directory to HOME"
    fi

    echo "Source: $source_dir"
    echo "Destination: $dest_dir"
    echo "------------------------"

    for file in "${dotfiles[@]}"; do
        sync_file "$file" "$source_dir/$file" "$dest_dir/$file"
    done
}

# Prompt for sync direction
echo -e "${BLUE}Dotfiles Sync Tool${NC}"
echo "1. Sync from HOME to local dotfiles directory"
echo "2. Sync from local dotfiles directory to HOME"
echo
read -p "Choose sync direction (1/2): " choice

case $choice in
    1)
        sync_files "to_local"
        ;;
    2)
        sync_files "to_home"
        ;;
    *)
        echo -e "${RED}Invalid choice. Please select 1 or 2.${NC}"
        exit 1
        ;;
esac

echo "------------------------"
echo "Sync complete!"