# Autosuggestions & Syntax Highlighting Guide

Your Zsh configuration now includes **live autosuggestions** and **syntax highlighting** for a better command-line experience!

## 🎯 What You Get

### 1. Live Autosuggestions (Fish-shell style)

As you type, you'll see **gray suggestions** appearing automatically based on:
- **Command history**: Commands you've typed before
- **Completions**: Valid options for the current context (e.g., npm scripts, git branches, docker containers)

### 2. Syntax Highlighting

Commands are colored in real-time:
- **Green**: Valid command that exists
- **Red**: Invalid command or typo
- **Yellow**: Aliases
- **Blue**: Keywords and built-ins
- **Cyan**: Options and flags

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `→` (Right Arrow) | Accept entire suggestion |
| `Ctrl+E` | Accept entire suggestion (alternative) |
| `Ctrl+→` | Accept one word from suggestion |
| `Ctrl+U` | Clear current suggestion |
| `Tab` | Traditional tab completion |

## 💡 Examples

### NPM Scripts
```bash
# Type: npm run
# Suggestion shows: npm run dev  (from package.json)
```

### Git Branches
```bash
# Type: git checkout
# Suggestion shows: git checkout feature/my-branch
```

### Docker Containers
```bash
# Type: docker exec -it
# Suggestion shows: docker exec -it my-container
```

### Previous Commands
```bash
# Type: docker-compose
# Suggestion shows: docker-compose up -d  (from history)
```

### File Paths
```bash
# Type: cd ~/proj
# Suggestion shows: cd ~/projects/my-app
```

## ⚙️ Configuration

All autosuggestion settings are in: `~/.zsh/shared/environment.zsh`

### Current Settings

- **Strategy**: History + Completions (suggests from both)
- **Color**: Dimmed gray (fg=240)
- **Async**: Enabled (better performance)
- **Max Buffer**: 20 characters

### Customization Options

**Change suggestion color:**
```bash
# Add to ~/.zshrc.local
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'  # Different gray
```

**Use only history (not completions):**
```bash
# Add to ~/.zshrc.local
ZSH_AUTOSUGGEST_STRATEGY=(history)
```

**Disable for specific commands:**
```bash
# Add to ~/.zshrc.local
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)
```

## 🚀 Tips & Tricks

### 1. Build Your History
The more you use your shell, the better the suggestions become. Frequently used commands will be suggested first.

### 2. Context-Aware Completions
Suggestions change based on context:
- After `npm run` → Shows scripts from package.json
- After `git branch` → Shows branch names
- After `docker exec` → Shows running containers

### 3. Partial Matching
Start typing any part of a command, and relevant suggestions appear:
```bash
# Type: docker
# Might suggest: docker-compose up -d
# Or: docker exec -it my-container bash
```

### 4. Accept Word by Word
Use `Ctrl+→` to accept suggestions one word at a time:
```bash
# Suggestion: git commit -m "Add new feature"
# Press Ctrl+→ three times to get: git commit -m
# Then type your own message
```

### 5. Clear Unwanted Suggestions
If a suggestion isn't what you want, press `Ctrl+U` to clear it and keep typing.

## 🐛 Troubleshooting

### Suggestions not appearing?
1. Reload shell: `source ~/.zshrc`
2. Check plugin loaded: `echo $plugins | grep autosuggestions`
3. Type a few commands to build history

### Suggestions too slow?
1. Already enabled: Async mode (ZSH_AUTOSUGGEST_USE_ASYNC=true)
2. Reduce buffer size if needed
3. Use history-only strategy

### Wrong color/hard to see?
Adjust the color in `~/.zshrc.local`:
```bash
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'  # Lighter gray
```

## 📚 Learn More

- **zsh-autosuggestions**: https://github.com/zsh-users/zsh-autosuggestions
- **zsh-syntax-highlighting**: https://github.com/zsh-users/zsh-syntax-highlighting

---

**Enjoy your enhanced command-line experience!** 🎉
