#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_command stellar

ADMIN_IDENTITY="${ADMIN_IDENTITY:-controlwatch-admin}"
MANAGER_IDENTITY="${MANAGER_IDENTITY:-controlwatch-manager}"

ensure_identity() {
  local identity="$1"

  if stellar keys public-key "${identity}" >/dev/null 2>&1; then
    echo "reusing Stellar identity: ${identity}"
  else
    stellar keys generate "${identity}" --secure-store
  fi

  stellar_testnet keys fund "${identity}"
  printf '%s=%s\n' "${identity}" "$(stellar keys public-key "${identity}")"
}

ensure_identity "${ADMIN_IDENTITY}"
ensure_identity "${MANAGER_IDENTITY}"
