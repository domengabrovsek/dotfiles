# ============================================================================
# Terraform
# ============================================================================

# --- Aliases ---

alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tfw='terraform workspace'

# --- Completion ---

if command -v terraform &> /dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C $(which terraform) terraform
fi

# --- Help ---

_zhelp_register terraform <<'HELP'
tf / tfi      terraform / init
tfp / tfa     plan / apply
tfd / tfv     destroy / validate
tff / tfw     fmt / workspace
HELP
