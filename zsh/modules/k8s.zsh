# ============================================================================
# Kubernetes
# ============================================================================

# --- Aliases ---

alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias ka='kubectl apply -f'
alias kl='kubectl logs -f'
alias kx='kubectl exec -it'

# Common kubectl get commands
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'

# Describe shortcuts
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'

# --- Functions ---

# Get pod logs with namespace
klogp() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: klogp <namespace> <pod_name>"
    return 1
  fi
  kubectl logs -f -n "$1" "$2"
}

# Execute command in pod
kexecp() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: kexecp <namespace> <pod_name>"
    return 1
  fi
  kubectl exec -it -n "$1" "$2" -- sh
}

# Switch kubectl context
kctx() {
  if [[ -z "$1" ]]; then
    kubectl config get-contexts
  else
    kubectl config use-context "$1"
  fi
}

# Switch kubectl namespace
kns() {
  if [[ -z "$1" ]]; then
    kubectl get namespaces
  else
    kubectl config set-context --current --namespace="$1"
  fi
}

# --- Completion ---

if command -v kubectl &> /dev/null; then
  # Cache kubectl completions to file (regenerates when binary changes)
  _kubectl_comp_cache="${HOME}/.zsh/cache/kubectl_completion.zsh"
  if [[ ! -f "$_kubectl_comp_cache" || "$(which kubectl)" -nt "$_kubectl_comp_cache" ]]; then
    kubectl completion zsh > "$_kubectl_comp_cache" 2>/dev/null
  fi
  [[ -f "$_kubectl_comp_cache" ]] && source "$_kubectl_comp_cache"

  # Alias completion for k=kubectl
  compdef k=kubectl
  compdef kg=kubectl
  compdef kd=kubectl
  compdef ka=kubectl
fi

if command -v helm &> /dev/null; then
  # Cache helm completions to file (regenerates when binary changes)
  _helm_comp_cache="${HOME}/.zsh/cache/helm_completion.zsh"
  if [[ ! -f "$_helm_comp_cache" || "$(which helm)" -nt "$_helm_comp_cache" ]]; then
    helm completion zsh > "$_helm_comp_cache" 2>/dev/null
  fi
  [[ -f "$_helm_comp_cache" ]] && source "$_helm_comp_cache"
fi

# --- Help ---

_zhelp_register k8s <<'HELP'
k / kg / kd   kubectl / get / describe
kdel / ka     kubectl delete / apply -f
kl / kx       kubectl logs -f / exec -it
kgp / kgs     get pods / services
kgd / kgn     get deployments / nodes
kgns          get namespaces
kdp / kds     describe pod / service
kdd           describe deployment
klogp <ns> <pod>   logs with namespace
kexecp <ns> <pod>  exec into pod
kctx [ctx]    switch kubectl context
kns [ns]      switch kubectl namespace
HELP
