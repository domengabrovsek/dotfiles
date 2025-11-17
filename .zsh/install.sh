#!/usr/bin/env bash

# ============================================================================
# Modular Zsh Configuration Installer
# ============================================================================
# This script helps install the modular Zsh configuration on a new machine

set -e  # Exit on error

echo "🚀 Modular Zsh Configuration Installer"
echo "======================================"
echo ""

# ============================================================================
# Check Prerequisites
# ============================================================================

echo "📋 Checking prerequisites..."

# Check if Zsh is installed
if ! command -v zsh &> /dev/null; then
  echo "❌ Zsh is not installed. Please install Zsh first."
  exit 1
fi

echo "✅ Zsh is installed"

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "⚠️  Oh My Zsh is not installed."
  echo -n "Would you like to install it now? (y/n): "
  read install_omz

  if [[ "$install_omz" == "y" || "$install_omz" == "Y" ]]; then
    echo "📥 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh My Zsh installed"
  else
    echo "⚠️  Skipping Oh My Zsh installation. The configuration may not work properly."
  fi
else
  echo "✅ Oh My Zsh is already installed"
fi

# ============================================================================
# Backup Existing Configuration
# ============================================================================

echo ""
echo "💾 Backing up existing configuration..."

# Backup .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
  backup_file="$HOME/.zshrc.backup-$(date +%Y%m%d-%H%M%S)"
  cp "$HOME/.zshrc" "$backup_file"
  echo "✅ Backed up .zshrc to $backup_file"
fi

# Backup .zsh directory if it exists
if [ -d "$HOME/.zsh" ]; then
  backup_dir="$HOME/.zsh.backup-$(date +%Y%m%d-%H%M%S)"
  mv "$HOME/.zsh" "$backup_dir"
  echo "✅ Backed up .zsh directory to $backup_dir"
fi

# ============================================================================
# Install Configuration
# ============================================================================

echo ""
echo "📦 Installing configuration..."

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# If the script is already in ~/.zsh, we're good
if [ "$SCRIPT_DIR" = "$HOME/.zsh" ]; then
  echo "✅ Configuration is already in ~/.zsh"
else
  # Copy the configuration to ~/.zsh
  cp -r "$SCRIPT_DIR" "$HOME/.zsh"
  echo "✅ Copied configuration to ~/.zsh"
fi

# Copy .zshrc to home directory
if [ -f "$HOME/.zsh/.zshrc" ]; then
  cp "$HOME/.zsh/.zshrc" "$HOME/.zshrc"
  echo "✅ Copied .zshrc to home directory"
else
  echo "⚠️  Warning: .zshrc not found in ~/.zsh/"
fi

# Create cache directory
mkdir -p "$HOME/.zsh/cache"
echo "✅ Created cache directory"

# ============================================================================
# Configuration Mode Selection
# ============================================================================

echo ""
echo "⚙️  Configuration Mode"
echo "Choose your default configuration mode:"
echo "  1) Personal (default)"
echo "  2) Work"
echo -n "Enter choice (1 or 2): "
read mode_choice

case "$mode_choice" in
  2)
    echo 'export ZSH_CONFIG_MODE=work' >> "$HOME/.zprofile"
    echo "✅ Set default mode to: work"
    ;;
  *)
    echo "✅ Using default mode: personal"
    ;;
esac

# ============================================================================
# Optional Dependencies
# ============================================================================

echo ""
echo "📦 Optional Dependencies"
echo "The following tools enhance the Zsh experience:"
echo ""

# Check for NVM
if ! command -v nvm &> /dev/null && [ ! -d "$HOME/.nvm" ]; then
  echo "⚠️  NVM (Node Version Manager) is not installed"
  echo "   Install: https://github.com/nvm-sh/nvm"
else
  echo "✅ NVM is installed"
fi

# Check for z
if [ ! -f "$HOME/z.sh" ]; then
  echo "⚠️  z (jump around) is not installed"
  echo -n "Would you like to install it now? (y/n): "
  read install_z

  if [[ "$install_z" == "y" || "$install_z" == "Y" ]]; then
    curl -fsSL https://raw.githubusercontent.com/rupa/z/master/z.sh -o "$HOME/z.sh"
    echo "✅ z installed to ~/z.sh"
  fi
else
  echo "✅ z is installed"
fi

# Check for zsh-autosuggestions
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "⚠️  zsh-autosuggestions is not installed"
  echo -n "Would you like to install it now? (y/n): "
  read install_autosuggestions

  if [[ "$install_autosuggestions" == "y" || "$install_autosuggestions" == "Y" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo "✅ zsh-autosuggestions installed"
  fi
else
  echo "✅ zsh-autosuggestions is installed"
fi

# Check for zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "⚠️  zsh-syntax-highlighting is not installed"
  echo -n "Would you like to install it now? (y/n): "
  read install_highlighting

  if [[ "$install_highlighting" == "y" || "$install_highlighting" == "Y" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    echo "✅ zsh-syntax-highlighting installed"
  fi
else
  echo "✅ zsh-syntax-highlighting is installed"
fi

# Check for Docker
if ! command -v docker &> /dev/null; then
  echo "⚠️  Docker is not installed"
  echo "   Install: https://www.docker.com/products/docker-desktop"
else
  echo "✅ Docker is installed"
fi

# Check for kubectl
if ! command -v kubectl &> /dev/null; then
  echo "⚠️  kubectl is not installed"
  echo "   Install: https://kubernetes.io/docs/tasks/tools/"
else
  echo "✅ kubectl is installed"
fi

# ============================================================================
# Finalize
# ============================================================================

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Customize your configuration in ~/.zsh/work/ or ~/.zsh/personal/"
echo "  3. Read the documentation: cat ~/.zsh/README.md"
echo ""
echo "Useful commands:"
echo "  - zsh_mode: Check current mode"
echo "  - zsh_switch [work|personal]: Switch between modes"
echo ""
echo "Happy coding! 🚀"
