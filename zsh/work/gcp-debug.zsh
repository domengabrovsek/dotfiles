# ============================================================================
# GCP Debugging Shortcuts
# ============================================================================
# Quick commands for debugging Cloud Run services, logs, and images
#
# Usage: type 'ghelp' to see all available GCP debug commands

# Default region for Cloud Run services (override in ~/.zshrc.local if needed)
export GCP_DEFAULT_REGION="${GCP_DEFAULT_REGION:-europe-west1}"

# ============================================================================
# Cloud Run - Service Discovery
# ============================================================================

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

# ============================================================================
# Cloud Run - Image & Revision Info
# ============================================================================

# Get the Docker image (with SHA) for a Cloud Run service
# Usage: cr-image <service-name-or-uuid> [region]
cr-image() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-image <service-name-or-uuid> [region]"
    echo "Example: cr-image e756cfe0-b0b8-4a89-bc9c-9db105cb2c27"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

  echo "Service: $service ($region)"
  echo ""
  gcloud run services describe "$service" --region="$region" \
    --format="value(spec.template.spec.containers[0].image)"
}

# Get just the SHA digest of the running image
# Usage: cr-sha <service-name-or-uuid> [region]
cr-sha() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-sha <service-name-or-uuid> [region]"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

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
  if [[ -z "$1" ]]; then
    echo "Usage: cr-revisions <service-name-or-uuid> [region]"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

  gcloud run revisions list --service="$service" --region="$region" \
    --format="table(metadata.name, metadata.creationTimestamp.date(), spec.containers[0].image, status.conditions[0].status)" \
    --sort-by="~metadata.creationTimestamp" --limit=10
}

# ============================================================================
# Cloud Run - Inspection & Debugging
# ============================================================================

# Describe a Cloud Run service (full details)
# Usage: cr-describe <service-name-or-uuid> [region]
cr-describe() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-describe <service-name-or-uuid> [region]"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

  gcloud run services describe "$service" --region="$region"
}

# Show environment variables for a Cloud Run service
# Usage: cr-env <service-name-or-uuid> [region]
cr-env() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-env <service-name-or-uuid> [region]"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

  echo "Environment variables for: $service ($region)"
  echo ""
  gcloud run services describe "$service" --region="$region" \
    --format="yaml(spec.template.spec.containers[0].env)"
}

# Show resource limits (CPU, memory, concurrency) for a Cloud Run service
# Usage: cr-resources <service-name-or-uuid> [region]
cr-resources() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-resources <service-name-or-uuid> [region]"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

  echo "Resources for: $service ($region)"
  echo ""
  gcloud run services describe "$service" --region="$region" \
    --format="table[box](spec.template.spec.containers[0].resources.limits.cpu,spec.template.spec.containers[0].resources.limits.memory,spec.template.spec.containerConcurrency,spec.template.metadata.annotations.'autoscaling.knative.dev/minScale',spec.template.metadata.annotations.'autoscaling.knative.dev/maxScale')"
}

# Show traffic splitting for a Cloud Run service
# Usage: cr-traffic <service-name-or-uuid> [region]
cr-traffic() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-traffic <service-name-or-uuid> [region]"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

  echo "Traffic for: $service ($region)"
  echo ""
  gcloud run services describe "$service" --region="$region" \
    --format="yaml(status.traffic)"
}

# Get the URL of a Cloud Run service
# Usage: cr-url <service-name-or-uuid> [region]
cr-url() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-url <service-name-or-uuid> [region]"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

  gcloud run services describe "$service" --region="$region" \
    --format="value(status.url)"
}

# ============================================================================
# Cloud Run - Logs
# ============================================================================

# Tail logs for a Cloud Run service
# Usage: cr-logs <service-name-or-uuid> [region]
cr-logs() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-logs <service-name-or-uuid> [region]"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

  echo "Streaming logs for: $service ($region)  (Ctrl+C to stop)"
  echo ""
  gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=\"$service\"" \
    --limit=50 --format="table(timestamp, severity, textPayload)" --freshness=1h
}

# Tail error logs for a Cloud Run service
# Usage: cr-errors <service-name-or-uuid> [region]
cr-errors() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-errors <service-name-or-uuid> [region]"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

  echo "Error logs for: $service ($region)"
  echo ""
  gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=\"$service\" AND severity>=ERROR" \
    --limit=50 --format="table(timestamp, severity, textPayload)" --freshness=24h
}

# ============================================================================
# Cloud Run - Quick Actions
# ============================================================================

# Get a full summary of a Cloud Run service (image, URL, resources, traffic)
# Usage: cr-info <service-name-or-uuid> [region]
cr-info() {
  if [[ -z "$1" ]]; then
    echo "Usage: cr-info <service-name-or-uuid> [region]"
    return 1
  fi

  local service region
  _cr-resolve-service "$1" "${2:-}" || return 1
  service="$_CR_SERVICE"
  region="$_CR_REGION"

  local desc
  desc=$(gcloud run services describe "$service" --region="$region" \
    --format="json" 2>/dev/null)

  if [[ -z "$desc" ]]; then
    echo "Failed to describe service: $service"
    return 1
  fi

  local image url cpu memory
  image=$(echo "$desc" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['spec']['template']['spec']['containers'][0]['image'])" 2>/dev/null)
  url=$(echo "$desc" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['status'].get('url','N/A'))" 2>/dev/null)
  cpu=$(echo "$desc" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['spec']['template']['spec']['containers'][0].get('resources',{}).get('limits',{}).get('cpu','N/A'))" 2>/dev/null)
  memory=$(echo "$desc" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['spec']['template']['spec']['containers'][0].get('resources',{}).get('limits',{}).get('memory','N/A'))" 2>/dev/null)

  echo "============================================"
  echo " Cloud Run Service Summary"
  echo "============================================"
  echo " Service:  $service"
  echo " Region:   $region"
  echo " URL:      $url"
  echo " Image:    $image"
  echo " CPU:      $cpu"
  echo " Memory:   $memory"
  echo "============================================"
}

# ============================================================================
# Artifact Registry / Docker Images
# ============================================================================

# List tags for an image in Artifact Registry
# Usage: ar-tags <image-path>
# Example: ar-tags europe-docker.pkg.dev/addingwell-dev-326312/aw-image/aw-gtm-cloud-image
ar-tags() {
  if [[ -z "$1" ]]; then
    echo "Usage: ar-tags <full-image-path>"
    echo "Example: ar-tags europe-docker.pkg.dev/addingwell-dev-326312/aw-image/aw-gtm-cloud-image"
    return 1
  fi
  gcloud artifacts docker tags list "$1" --format="table(tag, version)" --limit=20
}

# List images in an Artifact Registry repository
# Usage: ar-images [repository-path]
ar-images() {
  if [[ -z "$1" ]]; then
    echo "Usage: ar-images <repository-path>"
    echo "Example: ar-images europe-docker.pkg.dev/addingwell-dev-326312/aw-image"
    return 1
  fi
  gcloud artifacts docker images list "$1" --format="table(package, version, createTime)" --sort-by="~createTime" --limit=20
}

# ============================================================================
# GCP Logs (General)
# ============================================================================

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

# ============================================================================
# Help
# ============================================================================

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

# ============================================================================
# Internal Helpers
# ============================================================================

# Resolve a service name or UUID to full service name + region
# Sets _CR_SERVICE and _CR_REGION variables
_cr-resolve-service() {
  local input="$1"
  local region="${2:-$GCP_DEFAULT_REGION}"

  # First, try the input directly as a service name in the given region
  if gcloud run services describe "$input" --region="$region" &>/dev/null; then
    _CR_SERVICE="$input"
    _CR_REGION="$region"
    return 0
  fi

  # If that fails, search for it (could be a UUID or partial name)
  local match
  match=$(gcloud run services list --format="value(metadata.name, region)" 2>/dev/null | grep -i "$input" | head -1)

  if [[ -n "$match" ]]; then
    _CR_SERVICE=$(echo "$match" | awk '{print $1}')
    _CR_REGION=$(echo "$match" | awk '{print $2}')
    return 0
  fi

  echo "Service not found: $input"
  echo "Try: cr-find $input"
  return 1
}
