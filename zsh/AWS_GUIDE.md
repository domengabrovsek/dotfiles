# AWS Profile Management Guide

Enhanced AWS experience with profile switching and visual indicators.

## 🎯 Features

### 1. **AWS Profile in Prompt**
Your current AWS profile is always visible in your prompt:
```
~/my-project ☁︎ my-profile ⬢ v22.14.0 →
```

The cloud icon `☁︎` appears when `AWS_PROFILE` is set, showing you which profile you're using.

### 2. **Interactive Profile Switcher**
Switch between AWS profiles with a beautiful interactive menu.

### 3. **Profile Verification**
Automatically verifies credentials when switching profiles.

## 🚀 Quick Start

### Switch Profiles Interactively

```bash
awsp
# or
aws_switch
```

This shows an interactive numbered menu of all profiles from `~/.aws/config` and `~/.aws/credentials`. Select by number.

### Switch Directly to a Profile

```bash
awsp my-profile
# or
aws_switch my-profile
```

### Check Current Profile

```bash
awsc
# or
aws_current
```

Shows current profile name and verifies credentials via `sts get-caller-identity`.

### Clear Profile

```bash
# Using interactive menu
awsp
# Then select option 0

# Or directly
unset AWS_PROFILE
```

## ⌨️ Commands Reference

| Command | Description |
|---------|-------------|
| `awsp` | Interactive profile switcher (short alias) |
| `awsc` | Show current profile (short alias) |
| `aws_switch` | Interactive profile switcher (full name) |
| `aws_switch <profile>` | Switch to specific profile |
| `aws_current` | Show current profile and verify |
| `aws-whoami` | Show AWS identity (sts get-caller-identity) |
| `aws-regions` | List all AWS regions |

## 💡 Usage Examples

### Interactive Switching

`awsp` shows a numbered menu. Pick a number, credentials are verified automatically. Your prompt updates to show `☁︎ profile-name`.

### Direct Switch

```bash
awsp my-profile    # Switch directly, credentials verified
```

### Multiple Terminals

Profile switching only affects the current terminal session. Other terminals keep their own profiles - useful for working with multiple AWS accounts simultaneously.

## 🎨 Prompt Customization

The AWS profile appears in your prompt in orange color (color 208). You can customize this:

**Change the color:**

Edit `~/.zsh/modules/prompt.zsh` and modify the `aws_profile()` function:

```bash
function aws_profile() {
  if [[ -n "$AWS_PROFILE" ]]; then
    echo "%F{cyan}☁︎ $AWS_PROFILE%f "  # Change 208 to your preferred color
  fi
}
```

**Color options:**
- `208` - Orange (default)
- `cyan` - Cyan/turquoise
- `blue` - Blue
- `green` - Green
- `yellow` - Yellow
- `red` - Red
- `magenta` - Magenta

**Change the icon:**

Replace `☁︎` with your preferred icon:
- `☁` - Solid cloud
- `⚡` - Lightning bolt
- `AWS` - Text
- `@` - At symbol

## 🔧 Advanced Tips

### Set Default Profile for Shell Sessions

Add to `~/.zshrc.local`:
```bash
export AWS_PROFILE=my-default-profile
```

### Create Profile-Specific Aliases

Add to `~/.zsh/modules/aliases.zsh` or `~/.zshrc.local`:
```bash
alias aws-work='aws_switch my-work-profile'
alias aws-staging='aws_switch my-staging-profile'
```

## 🛡️ Security Best Practices

1. **Never commit AWS credentials to git**
   - Your `~/.aws/credentials` file is local only
   - The profile switcher only changes the `AWS_PROFILE` environment variable

2. **Use separate profiles for different environments** (personal, work, staging, CI, etc.)

3. **Verify profile after switching**
   - Use `awsc` to confirm you're using the right profile
   - The prompt shows the current profile to prevent mistakes

4. **Use MFA when possible**
   - Configure MFA in your AWS IAM settings
   - The profile switcher works with MFA-protected profiles

## 🐛 Troubleshooting

### Profile not showing in prompt?
```bash
# Reload your shell
source ~/.zshrc

# Verify AWS_PROFILE is set
echo $AWS_PROFILE
```

### Credentials not working?
```bash
# Check your credentials file
cat ~/.aws/credentials

# Verify with AWS CLI
aws sts get-caller-identity
```

### Profile not in menu?
The menu shows profiles from:
- `~/.aws/config` - Profile configurations
- `~/.aws/credentials` - Access credentials

Make sure your profile is defined in at least one of these files.

## 📚 Learn More

- AWS CLI Configuration: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
- Named Profiles: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html

---

**Happy cloud computing!** ☁️
