# ============================================================================
# Personal-Specific Environment Variables
# ============================================================================
# Environment configuration specific to personal setup

# ============================================================================
# AWS Personal Configuration
# ============================================================================

# Default AWS profile for personal projects
# export AWS_PROFILE=personal

# Personal AWS region (override if different from shared)
# export AWS_REGION=us-west-2
# export AWS_DEFAULT_REGION=us-west-2

# ============================================================================
# GCP Personal Configuration
# ============================================================================

# Default GCP project for personal projects
# export GCP_PROJECT=my-personal-project

# ============================================================================
# Personal Development Settings
# ============================================================================

# Personal projects directory
# export PERSONAL_PROJECTS="$HOME/projects"

# ============================================================================
# Homebrew (for macOS)
# ============================================================================

# Homebrew settings
# export HOMEBREW_NO_ANALYTICS=1
# export HOMEBREW_NO_AUTO_UPDATE=1

# ============================================================================
# Personal Tools & SDKs
# ============================================================================

# Add personal tools to PATH
# export PATH="$HOME/bin:$PATH"
# export PATH="$HOME/.local/bin:$PATH"

# ============================================================================
# Language-Specific Settings
# ============================================================================

# Python
# export PYTHONDONTWRITEBYTECODE=1

# Go
# export GOPATH="$HOME/go"
# export PATH="$GOPATH/bin:$PATH"

# Rust
# export PATH="$HOME/.cargo/bin:$PATH"

# ============================================================================
# Personal API Keys (Consider using .env files instead)
# ============================================================================

# WARNING: Don't commit API keys to git!
# Better to use .env files or a secret manager

# Example (but better to load from .env):
# export OPENAI_API_KEY="your-key-here"
