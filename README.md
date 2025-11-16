# Dotfiles

Personal configuration files and shell setup.

## Structure

```text
dotfiles/
└── .zsh/
    ├── personal/  # Personal machine configs
    ├── work/      # Work machine configs
    └── shared/    # Shared configs
```

## Setup

Run the install script to set up everything automatically:

```bash
cd dotfiles/.zsh
./install.sh
```

The installer will:

- Check and optionally install Oh My Zsh
- Install required plugins (zsh-autosuggestions, zsh-syntax-highlighting)
- Install z (directory jumper)
- Copy configuration to `~/.zsh` and `~/.zshrc`
- Let you choose between personal or work mode

## Documentation

- [Quick Start Guide](dotfiles/.zsh/QUICKSTART.md)
- [Zsh Configuration](dotfiles/.zsh/README.md)
- [AWS CLI Guide](dotfiles/.zsh/AWS_GUIDE.md)
- [Autosuggestions](dotfiles/.zsh/AUTOSUGGESTIONS.md)
- [Cheatsheet](dotfiles/.zsh/CHEATSHEET.md)
