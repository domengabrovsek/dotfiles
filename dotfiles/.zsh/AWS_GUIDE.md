# AWS Profile Management Guide

Enhanced AWS experience with profile switching and visual indicators.

## 🎯 Features

### 1. **AWS Profile in Prompt**
Your current AWS profile is always visible in your prompt:
```
~/my-project ☁︎ domengabrovsek ⬢ v22.14.0 →
```

The cloud icon `☁︎` appears when `AWS_PROFILE` is set, showing you which profile you're using.

### 2. **Interactive Profile Switcher**
Switch between AWS profiles with a beautiful interactive menu.

### 3. **Profile Verification**
Automatically verifies credentials when switching profiles.

## 🚀 Quick Start

### View Your Profiles

Your configured AWS profiles:
- `domengabrovsek`
- `tf-domengabrovsek`
- `tf-shupak-bot`

### Switch Profiles Interactively

```bash
awsp
# or
aws_switch
```

This shows an interactive menu:
```
☁️  Available AWS Profiles:

   Current: domengabrovsek (active)

    1) domengabrovsek ✓
    2) tf-domengabrovsek
    3) tf-shupak-bot

   0) Clear profile (unset AWS_PROFILE)

Select profile number (or press Enter to cancel):
```

Just type the number and press Enter!

### Switch Directly to a Profile

```bash
awsp domengabrovsek
# or
aws_switch tf-domengabrovsek
```

### Check Current Profile

```bash
awsc
# or
aws_current
```

Output:
```
Current AWS Profile: domengabrovsek

{
    "UserId": "...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/domen"
}
```

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

### Example 1: Interactive Switching
```bash
# Open the menu
$ awsp

☁️  Available AWS Profiles:

   Current: domengabrovsek (active)

    1) domengabrovsek ✓
    2) tf-domengabrovsek
    3) tf-shupak-bot

   0) Clear profile (unset AWS_PROFILE)

Select profile number (or press Enter to cancel): 2

✓ Switched to AWS profile: tf-domengabrovsek

Verifying credentials...
{
    "UserId": "...",
    "Account": "...",
    "Arn": "..."
}

✓ Profile verified successfully!
```

Your prompt now shows: `~/project ☁︎ tf-domengabrovsek →`

### Example 2: Direct Switch
```bash
$ awsp domengabrovsek
✓ Switched to AWS profile: domengabrovsek
{
    "UserId": "...",
    "Account": "...",
    "Arn": "..."
}
```

### Example 3: Check Current Profile
```bash
$ awsc
Current AWS Profile: domengabrovsek

{
    "UserId": "...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/domen"
}
```

### Example 4: Working with Multiple Terminals
When you switch profiles, it only affects the current terminal session. Other terminals keep their own profiles. This is perfect for working with multiple AWS accounts simultaneously!

```bash
# Terminal 1
$ awsp domengabrovsek
# Work with personal account

# Terminal 2
$ awsp tf-domengabrovsek
# Work with work account
```

## 🎨 Prompt Customization

The AWS profile appears in your prompt in orange color (color 208). You can customize this:

**Change the color:**

Edit `~/.zsh/shared/prompt.zsh` and modify the `aws_profile()` function:

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

### Set Default Profile in Work Mode

Add to `~/.zsh/work/environment.zsh`:
```bash
export AWS_PROFILE=tf-domengabrovsek
```

Now when you switch to work mode, this profile is automatically set!

### Set Default Profile for Shell Sessions

Add to `~/.zshrc.local`:
```bash
export AWS_PROFILE=domengabrovsek
```

### Create Profile-Specific Aliases

Add to `~/.zsh/work/aliases.zsh`:
```bash
alias aws-work='aws_switch tf-domengabrovsek'
alias aws-bot='aws_switch tf-shupak-bot'
```

### Quick Profile Switching with Ctrl+A

Add to `~/.zsh/shared/environment.zsh`:
```bash
# Bind Ctrl+A to quickly switch AWS profile
bindkey -s '^A' 'awsp\n'
```

Now pressing `Ctrl+A` opens the profile switcher!

## 🛡️ Security Best Practices

1. **Never commit AWS credentials to git**
   - Your `~/.aws/credentials` file is local only
   - The profile switcher only changes the `AWS_PROFILE` environment variable

2. **Use separate profiles for different environments**
   - Personal: `domengabrovsek`
   - Terraform: `tf-domengabrovsek`
   - Bot: `tf-shupak-bot`

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
