#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_command stellar
require_fixtures

COMPLIANCE="$(fixture_value compliance)"
MODULE_A="$(fixture_value module_a)"
MANAGER_IDENTITY="$(fixture_value manager_identity)"
MANAGER_ADDRESS="$(stellar keys public-key "${MANAGER_IDENTITY}")"

stellar_testnet contract invoke \
  --id "${COMPLIANCE}" \
  --source "${MANAGER_IDENTITY}" \
  -- add_module_to \
  --hook Transferred \
  --module "${MODULE_A}" \
  --operator "${MANAGER_ADDRESS}" >/dev/null

printf 'module=%s\nhook=Transferred\n' "${MODULE_A}"
