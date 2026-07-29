#!/usr/bin/env bash
set -e

# Seed gcloud configurations (personal + pentla work projects). No secrets:
# just account/project/region. Authenticate separately and interactively with
#   gcloud auth login <account>
# then switch between these with `gcpp` (gcp_switch).

if ! command -v gcloud &> /dev/null; then
  echo "gcloud not found - skipping GCP configuration seed"
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

#            name                       account                     project                    region        zone
seed_config  personal                   domen.gabrovsek@gmail.com   domen-home-infra           europe-west1  europe-west1-b
seed_config  pentla-audit-logs          domen@pentla.tech           pentla-audit-logs          europe-west1  europe-west1-b
seed_config  pentla-production          domen@pentla.tech           pentla-production          europe-west1  europe-west1-b
seed_config  pentla-staging             domen@pentla.tech           pentla-staging             europe-west1  europe-west1-b
seed_config  pentla-tfstate-global      domen@pentla.tech           pentla-tfstate-global      europe-west1  europe-west1-b
seed_config  pentla-tfstate-production  domen@pentla.tech           pentla-tfstate-production  europe-west1  europe-west1-b
seed_config  pentla-tfstate-staging     domen@pentla.tech           pentla-tfstate-staging     europe-west1  europe-west1-b
seed_config  pentla-utils               domen@pentla.tech           pentla-utils               europe-west1  europe-west1-b
