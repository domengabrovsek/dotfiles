#!/usr/bin/env bash
set -e

# Seed gcloud configurations from configurations.local, which is gitignored so
# account and project names stay out of this public repo. One per line:
#   <name> <account> <project> <region> <zone>
# Authenticate separately with `gcloud auth login <account>`, then switch with
# `gcpp`.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST="$SCRIPT_DIR/configurations.local"

if ! command -v gcloud &> /dev/null; then
  echo "gcloud not found - skipping GCP configuration seed"
  exit 0
fi
if [ ! -f "$LIST" ]; then
  echo "[skip] gcloud configurations: $LIST not found"
  exit 0
fi

# Create the named configuration if missing, then set its properties without
# touching whichever configuration is currently active (--no-activate +
# CLOUDSDK_ACTIVE_CONFIG_NAME scope each `set` to the target config).
seed_config() {
  local name=$1 account=$2 project=$3 region=$4 zone=$5
  if ! gcloud config configurations list --format='value(name)' 2>/dev/null | grep -qx "$name"; then
    gcloud config configurations create "$name" --no-activate
  fi
  CLOUDSDK_ACTIVE_CONFIG_NAME="$name" gcloud config set account "$account" --quiet
  CLOUDSDK_ACTIVE_CONFIG_NAME="$name" gcloud config set project "$project" --quiet
  CLOUDSDK_ACTIVE_CONFIG_NAME="$name" gcloud config set compute/region "$region" --quiet
  CLOUDSDK_ACTIVE_CONFIG_NAME="$name" gcloud config set compute/zone "$zone" --quiet
  echo "[ok] gcloud config: $name -> $project ($account)"
}

while read -r name account project region zone; do
  case "$name" in ''|'#'*) continue ;; esac
  seed_config "$name" "$account" "$project" "$region" "$zone"
done < "$LIST"
