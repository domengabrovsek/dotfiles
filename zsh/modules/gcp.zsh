# ============================================================================
# GCP
# ============================================================================

# --- Environment ---

# Source gcloud PATH and completions (installed via brew --cask google-cloud-sdk)
if [[ -f /opt/homebrew/share/google-cloud-sdk/path.zsh.inc ]]; then
  source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
fi
if [[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ]]; then
  source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
fi

# Default region for Cloud Run helpers; override in ~/.zshrc.local.
export GCP_DEFAULT_REGION="${GCP_DEFAULT_REGION:-europe-west1}"

# --- Aliases ---

alias gcp-projects='gcloud projects list'
alias gcp-set-project='gcloud config set project'
alias gcp-login='gcloud auth application-default login'
alias gcpp='gcp_switch'   # Quick profile switcher (like awsp)
alias gcpc='gcp_current'  # Show current profile (like awsc)
alias gcpa='gcp_account'  # Switch account on the active profile

# --- Configuration and account switchers ---

# Switch GCP configuration with interactive selection
gcp_switch() {
  local configs=()
  local active_config

  # Get list of configurations
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      configs+=("$line")
    fi
  done < <(gcloud config configurations list --format="value(name)" 2>/dev/null)

  active_config=$(gcloud config configurations list --filter="IS_ACTIVE=true" --format="value(name)" 2>/dev/null)

  # If no argument provided, show interactive selection
  if [[ -z "$1" ]]; then
    if [[ ${#configs[@]} -eq 0 ]]; then
      echo "No GCP configurations found."
      echo ""
      echo "Create one with: gcloud config configurations create <name>"
      return 1
    fi

    echo "GCP Configurations:"
    echo ""

    if [[ -n "$active_config" ]]; then
      local active_project=$(gcloud config get-value project 2>/dev/null)
      echo "   Current: \x1b[32m${active_config}\x1b[0m (project: ${active_project:-none})"
    fi
    echo ""

    # List all configs with numbers
    local i=1
    for config in "${configs[@]}"; do
      local project=$(gcloud config configurations describe "$config" --format="value(properties.core.project)" 2>/dev/null)
      if [[ "$config" == "$active_config" ]]; then
        printf "   \x1b[32m%2d) %s (project: %s) ✓\x1b[0m\n" $i "$config" "${project:-none}"
      else
        printf "   %2d) %s (project: %s)\n" $i "$config" "${project:-none}"
      fi
      ((i++))
    done

    echo ""
    echo -n "Select configuration number (or press Enter to cancel): "
    read selection

    # Handle selection
    if [[ -z "$selection" ]]; then
      echo "Cancelled."
      return 0
    elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#configs[@]} ]]; then
      local selected="${configs[$selection]}"
      gcloud config configurations activate "$selected" 2>/dev/null
      _update_gcp_config_cache
      echo ""
      echo "Switched to GCP configuration: $selected"
      gcp_current
    else
      echo "Invalid selection: $selection"
      return 1
    fi
  else
    # Direct config switch
    if gcloud config configurations activate "$1" 2>/dev/null; then
      _update_gcp_config_cache
      echo "Switched to GCP configuration: $1"
      gcp_current
    else
      echo "Configuration '$1' not found."
      echo ""
      echo "Available configurations:"
      gcloud config configurations list --format="table(name, is_active, properties.core.project, properties.core.account)" 2>/dev/null
      return 1
    fi
  fi
}

# Switch the active configuration's account with interactive selection
gcp_account() {
  local accounts=()
  local active_account

  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      accounts+=("$line")
    fi
  done < <(gcloud auth list --format="value(account)" 2>/dev/null)

  active_account=$(gcloud config get-value account 2>/dev/null)

  local selected="$1"
  if [[ -z "$selected" ]]; then
    if [[ ${#accounts[@]} -eq 0 ]]; then
      echo "No GCP accounts found."
      echo ""
      echo "Log in with: gcloud auth login <account>"
      return 1
    fi

    echo "GCP Accounts:"
    echo ""

    local i=1
    for account in "${accounts[@]}"; do
      if [[ "$account" == "$active_account" ]]; then
        printf "   \x1b[32m%2d) %s ✓\x1b[0m\n" $i "$account"
      else
        printf "   %2d) %s\n" $i "$account"
      fi
      ((i++))
    done

    echo ""
    echo -n "Select account number (or press Enter to cancel): "
    read selection

    if [[ -z "$selection" ]]; then
      echo "Cancelled."
      return 0
    elif [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#accounts[@]} ]]; then
      selected="${accounts[$selection]}"
    else
      echo "Invalid selection: $selection"
      return 1
    fi
  elif (( ! ${accounts[(Ie)$selected]} )); then
    echo "Account '$selected' is not logged in."
    echo ""
    echo "Log in with: gcloud auth login $selected"
    return 1
  fi

  gcloud config set account "$selected" --quiet 2>/dev/null
  _update_gcp_config_cache
  echo ""
  echo "Switched to GCP account: $selected"
  gcp_current
}

# Show current GCP profile and identity
gcp_current() {
  local config=$(gcloud config configurations list --filter="IS_ACTIVE=true" --format="value(name)" 2>/dev/null)
  local project=$(gcloud config get-value project 2>/dev/null)
  local account=$(gcloud config get-value account 2>/dev/null)
  local region=$(gcloud config get-value compute/region 2>/dev/null)

  echo ""
  echo "GCP Configuration: ${config:-default}"
  echo "  Account: ${account:-(not set)}"
  echo "  Project: ${project:-(not set)}"
  echo "  Region:  ${region:-(not set)}"
}

_zhelp_register gcp <<'HELP'
gcp-projects  gcloud projects list
gcpp / gcpc   switch profile / show current
gcpa          switch account on the active profile
gcp_switch    interactive profile switcher
gcp_current   show current profile + identity
gcp_account   interactive account switcher
gcp-set-project <id>  gcloud config set project
gcp-login     application-default login
HELP

# --- Cloud Run - Service Discovery ---

# Find a Cloud Run service by partial name/UUID (searches across all regions)
# Usage: cr-find <partial-name-or-uuid>
cr-find() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-find <partial-name-or-uuid>"
    return 1
  fi
  gcloud run services list --format="table(metadata.name, region, status.url)" | grep -i "$1"
}

# List all Cloud Run services (optionally filter)
# Usage: cr-list [filter]
cr-list() {
  if [[ -n "$1" ]]; then
    gcloud run services list --format="table(metadata.name, region, status.traffic[0].percent, status.url)" | grep -i "$1"
  else
    gcloud run services list --format="table(metadata.name, region, status.traffic[0].percent, status.url)"
  fi
}

# --- Cloud Run - Image & Revision Info ---

# Get the Docker image (with SHA) for a Cloud Run service
# Usage: cr-image <service-name-or-uuid> [region]
cr-image() {
  local service region
  _cr_target cr-image "$@" || return 1

  echo "Service: $service ($region)"
  echo ""
  gcloud run services describe "$service" --region="$region" \
    --format="value(spec.template.spec.containers[0].image)"
}

# Get just the SHA digest of the running image
# Usage: cr-sha <service-name-or-uuid> [region]
cr-sha() {
  local service region
  _cr_target cr-sha "$@" || return 1

  local image
  image=$(gcloud run services describe "$service" --region="$region" \
    --format="value(spec.template.spec.containers[0].image)" 2>/dev/null)

  if [[ "$image" == *"@sha256:"* ]]; then
    echo "${image##*@}"
  else
    echo "$image"
  fi
}

# List revisions for a Cloud Run service
# Usage: cr-revisions <service-name-or-uuid> [region]
cr-revisions() {
  local service region
  _cr_target cr-revisions "$@" || return 1

  gcloud run revisions list --service="$service" --region="$region" \
    --format="table(metadata.name, metadata.creationTimestamp.date(), spec.containers[0].image, status.conditions[0].status)" \
    --sort-by="~metadata.creationTimestamp" --limit=10
}

# --- Cloud Run - Inspection & Debugging ---

# Describe a Cloud Run service (full details)
# Usage: cr-describe <service-name-or-uuid> [region]
cr-describe() {
  local service region
  _cr_target cr-describe "$@" || return 1

  gcloud run services describe "$service" --region="$region"
}

# Show environment variables for a Cloud Run service
# Usage: cr-env <service-name-or-uuid> [region]
cr-env() {
  local service region
  _cr_target cr-env "$@" || return 1

  echo "Environment variables for: $service ($region)"
  echo ""
  gcloud run services describe "$service" --region="$region" \
    --format="yaml(spec.template.spec.containers[0].env)"
}

# Show resource limits (CPU, memory, concurrency) for a Cloud Run service
# Usage: cr-resources <service-name-or-uuid> [region]
cr-resources() {
  local service region
  _cr_target cr-resources "$@" || return 1

  echo "Resources for: $service ($region)"
  echo ""
  gcloud run services describe "$service" --region="$region" \
    --format="table[box](spec.template.spec.containers[0].resources.limits.cpu,spec.template.spec.containers[0].resources.limits.memory,spec.template.spec.containerConcurrency,spec.template.metadata.annotations.'autoscaling.knative.dev/minScale',spec.template.metadata.annotations.'autoscaling.knative.dev/maxScale')"
}

# Show traffic splitting for a Cloud Run service
# Usage: cr-traffic <service-name-or-uuid> [region]
cr-traffic() {
  local service region
  _cr_target cr-traffic "$@" || return 1

  echo "Traffic for: $service ($region)"
  echo ""
  gcloud run services describe "$service" --region="$region" \
    --format="yaml(status.traffic)"
}

# Get the URL of a Cloud Run service
# Usage: cr-url <service-name-or-uuid> [region]
cr-url() {
  local service region
  _cr_target cr-url "$@" || return 1

  gcloud run services describe "$service" --region="$region" \
    --format="value(status.url)"
}

# --- Cloud Run - Logs ---

# Tail logs for a Cloud Run service
# Usage: cr-logs <service-name-or-uuid> [region]
cr-logs() {
  local service region
  _cr_target cr-logs "$@" || return 1

  echo "Streaming logs for: $service ($region)  (Ctrl+C to stop)"
  echo ""
  gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=\"$service\"" \
    --limit=50 --format="table(timestamp, severity, textPayload)" --freshness=1h
}

# Tail error logs for a Cloud Run service
# Usage: cr-errors <service-name-or-uuid> [region]
cr-errors() {
  local service region
  _cr_target cr-errors "$@" || return 1

  echo "Error logs for: $service ($region)"
  echo ""
  gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=\"$service\" AND severity>=ERROR" \
    --limit=50 --format="table(timestamp, severity, textPayload)" --freshness=24h
}

# --- Cloud Run - Quick Actions ---

# Get a full summary of a Cloud Run service (image, URL, resources, traffic)
# Usage: cr-info <service-name-or-uuid> [region]
cr-info() {
  local service region
  _cr_target cr-info "$@" || return 1

  local -a fields
  fields=("${(@ps:\t:)$(gcloud run services describe "$service" --region="$region" \
    --format="value(spec.template.spec.containers[0].image,status.url,spec.template.spec.containers[0].resources.limits.cpu,spec.template.spec.containers[0].resources.limits.memory)" 2>/dev/null)}")
  local image="${fields[1]}" url="${fields[2]}" cpu="${fields[3]}" memory="${fields[4]}"

  echo "============================================"
  echo " Cloud Run Service Summary"
  echo "============================================"
  echo " Service:  $service"
  echo " Region:   $region"
  echo " URL:      ${url:-N/A}"
  echo " Image:    ${image:-N/A}"
  echo " CPU:      ${cpu:-N/A}"
  echo " Memory:   ${memory:-N/A}"
  echo "============================================"
}

# --- Artifact Registry / Docker Images ---

# List tags for an image in Artifact Registry
# Usage: ar-tags <image-path>
# Example: ar-tags europe-docker.pkg.dev/<project>/<repo>/<image>
ar-tags() {
  if [[ -z "$1" ]]; then
    echo "Usage: ar-tags <full-image-path>"
    echo "Example: ar-tags europe-docker.pkg.dev/<project>/<repo>/<image>"
    return 1
  fi
  gcloud artifacts docker tags list "$1" --format="table(tag, version)" --limit=20
}

# List images in an Artifact Registry repository
# Usage: ar-images [repository-path]
ar-images() {
  if [[ -z "$1" ]]; then
    echo "Usage: ar-images <repository-path>"
    echo "Example: ar-images europe-docker.pkg.dev/<project>/<repo>"
    return 1
  fi
  gcloud artifacts docker images list "$1" --format="table(package, version, createTime)" --sort-by="~createTime" --limit=20
}

# --- GCP Logs (General) ---

# Quick log search across the project
# Usage: gcp-logs <filter> [limit]
# Example: gcp-logs "severity>=ERROR" 20
gcp-logs() {
  if [[ -z "$1" ]]; then
    echo "Usage: gcp-logs <filter> [limit]"
    echo "Examples:"
    echo "  gcp-logs 'severity>=ERROR' 20"
    echo "  gcp-logs 'resource.type=cloud_run_revision'"
    echo "  gcp-logs 'textPayload:\"timeout\"'"
    return 1
  fi

  local limit="${2:-50}"
  gcloud logging read "$1" --limit="$limit" --format="table(timestamp, severity, textPayload)" --freshness=1h
}

# --- Help ---

_zhelp_register gcp <<'HELP'
cr-find       search Cloud Run service by name/UUID
cr-list       list Cloud Run services
cr-image      get Docker image + SHA for a service
cr-sha        get just the image SHA digest
cr-revisions  list recent revisions
cr-describe   full service description
cr-env        show environment variables
cr-resources  show CPU/memory/concurrency
cr-traffic    show traffic splitting
cr-url        get service URL
cr-logs       view recent logs (1h)
cr-errors     view error logs (24h)
cr-info       full summary (image, URL, resources)
ar-tags       list Artifact Registry image tags
ar-images     list images in AR repo
gcp-logs      quick log search
gcp-debug-help  show all GCP debug commands
HELP

gcp-debug-help() {
  cat <<'HELP'
GCP Debug Commands:
  cr-find <name>            Search for a Cloud Run service by partial name/UUID
  cr-list [filter]          List Cloud Run services (optionally filter)
  cr-image <name> [region]  Get Docker image (with SHA) for a service
  cr-sha <name> [region]    Get just the SHA digest of the running image
  cr-revisions <name>       List recent revisions for a service
  cr-describe <name>        Full description of a service
  cr-env <name>             Show environment variables
  cr-resources <name>       Show CPU, memory, concurrency limits
  cr-traffic <name>         Show traffic splitting
  cr-url <name>             Get the service URL
  cr-logs <name>            View recent logs (last hour)
  cr-errors <name>          View error logs (last 24h)
  cr-info <name>            Full summary (image, URL, resources)
  ar-tags <image-path>      List tags for an Artifact Registry image
  ar-images <repo-path>     List images in an Artifact Registry repo
  gcp-logs <filter> [limit] Quick log search across the project

Notes:
  - <name> can be a full service name or a UUID (auto-resolved)
  - [region] defaults to $GCP_DEFAULT_REGION (currently: europe-west1)
  - Override default region: export GCP_DEFAULT_REGION=us-central1
HELP
}

# --- Internal Helpers ---

# Parse "<service-name-or-uuid> [region]" for a cr-* command. Sets the caller's
# `service` and `region` locals, which zsh's dynamic scoping makes visible here.
_cr_target() {
  local cmd="$1"; shift
  if [[ -z "$1" ]]; then
    echo "Usage: $cmd <service-name-or-uuid> [region]"
    return 1
  fi

  local input="$1"
  region="${2:-$GCP_DEFAULT_REGION}"
  if gcloud run services describe "$input" --region="$region" &>/dev/null; then
    service="$input"
    return 0
  fi

  # Not a service in that region: search every region for a partial name or UUID.
  local match
  match=$(gcloud run services list --format="value(metadata.name, region)" 2>/dev/null | grep -i "$input" | head -1)
  if [[ -n "$match" ]]; then
    local -a parts=(${=match})
    service="${parts[1]}"
    region="${parts[2]}"
    return 0
  fi

  echo "Service not found: $input"
  echo "Try: cr-find $input"
  return 1
}
