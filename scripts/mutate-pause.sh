#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_command stellar
require_fixtures

TOKEN="$(fixture_value token)"
ADMIN_IDENTITY="$(fixture_value admin_identity)"
ADMIN_ADDRESS="$(stellar keys public-key "${ADMIN_IDENTITY}")"

stellar_testnet contract invoke \
  --id "${TOKEN}" \
  --source "${ADMIN_IDENTITY}" \
  -- pause \
  --caller "${ADMIN_ADDRESS}" >/dev/null

printf 'token=%s\npaused=true\n' "${TOKEN}"
