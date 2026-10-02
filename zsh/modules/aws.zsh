# ============================================================================
# AWS
# ============================================================================

# --- Environment ---

export AWS_REGION=eu-central-1
export AWS_DEFAULT_REGION=eu-central-1

# AWS pager configuration (use less with colors)
export AWS_PAGER="less -R"

# --- Aliases ---

alias aws-whoami='aws sts get-caller-identity'
alias aws-regions='aws ec2 describe-regions --output table'
alias aws-login='aws sso login --profile $AWS_PROFILE'
alias awsp='aws_switch'  # Quick profile switcher
alias awsc='aws_current'  # Show current profile

# --- Functions ---

# Switch AWS profile via fzf; auto-refreshes an expired SSO session
aws_switch() {
  command -v aws >/dev/null 2>&1 || { echo "❌ aws CLI required."; return 1; }

  # `awsp off` / `awsp -c` clears the active profile
  if [[ "$1" == "off" || "$1" == "-c" ]]; then
    unset AWS_PROFILE
    echo "✓ Cleared AWS_PROFILE"
    return 0
  fi

  local profile
  if [[ -n "$1" ]] && aws configure list-profiles | grep -qx "$1"; then
    profile="$1"                                   # exact name switches directly
  else
    command -v fzf >/dev/null 2>&1 || { echo "❌ fzf required for selection."; return 1; }
    # `awsp <text>` pre-filters; preview shows each profile's account id + role
    profile=$(aws configure list-profiles | sort | fzf --height 40% --reverse \
      --query "$1" --prompt "aws profile> " \
      --preview 'echo "account: $(aws configure get sso_account_id --profile {})"; \
                 echo "role:    $(aws configure get sso_role_name  --profile {})"') || return
  fi
  [[ -z "$profile" ]] && return

  export AWS_PROFILE="$profile"
  echo "☁️  AWS_PROFILE=$profile"

  # Only hit the browser when the cached SSO token is missing or expired
  if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "SSO session expired, logging in..."
    aws sso login --profile "$profile"
  fi
  aws sts get-caller-identity --query Account --output text 2>/dev/null | sed 's/^/✓ account /'
}

# Quick alias to show current AWS profile
aws_current() {
  if [[ -n "$AWS_PROFILE" ]]; then
    echo "Current AWS Profile: $AWS_PROFILE"
    if command -v aws &> /dev/null; then
      echo ""
      aws sts get-caller-identity 2>/dev/null || echo "⚠️  Could not verify credentials"
    fi
  else
    echo "No AWS profile set (using default credentials)"
  fi
}

# List S3 buckets with human-readable sizes
s3_list_buckets() {
  aws s3 ls | while read -r line; do
    bucket_name=$(echo $line | awk '{print $3}')
    bucket_size=$(aws s3 ls s3://$bucket_name --recursive --summarize | grep "Total Size" | awk '{print $3}')
    echo "$bucket_name: $bucket_size bytes"
  done
}

# --- Completion ---

if command -v aws &> /dev/null; then
  # Find aws_completer location
  typeset aws_completer_path=$(which aws_completer 2>/dev/null)

  if [[ -z "$aws_completer_path" ]]; then
    # Try common locations
    if [[ -x /usr/local/bin/aws_completer ]]; then
      aws_completer_path="/usr/local/bin/aws_completer"
    elif [[ -x /opt/homebrew/bin/aws_completer ]]; then
      aws_completer_path="/opt/homebrew/bin/aws_completer"
    elif [[ -x /usr/local/aws-cli/v2/current/bin/aws_completer ]]; then
      aws_completer_path="/usr/local/aws-cli/v2/current/bin/aws_completer"
    fi
  fi

  # Only enable completion if we found the completer
  if [[ -n "$aws_completer_path" && -x "$aws_completer_path" ]]; then
    complete -C "$aws_completer_path" aws
  fi

  # Clean up variable
  unset aws_completer_path
fi

# --- Help ---

_zhelp_register aws <<'HELP'
aws-whoami    sts get-caller-identity
awsp / awsc   switch profile / show current
aws_switch    interactive profile switcher
aws_current   show current profile + identity
s3_list_buckets  list buckets with sizes
aws-regions   list AWS regions
aws-login     sso login for $AWS_PROFILE
HELP
