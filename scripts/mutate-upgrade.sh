#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_command stellar
require_fixtures

TOKEN="$(fixture_value token)"
MANAGER_IDENTITY="$(fixture_value manager_identity)"
MANAGER_ADDRESS="$(stellar keys public-key "${MANAGER_IDENTITY}")"

stellar contract build --package controlwatch-rwa-token
NEW_WASM_HASH="$(stellar_testnet contract install \
  --wasm "$(wasm_path controlwatch-rwa-token)" \
  --source "${MANAGER_IDENTITY}")"

stellar_testnet contract invoke \
  --id "${TOKEN}" \
  --source "${MANAGER_IDENTITY}" \
  -- upgrade \
  --new_wasm_hash "${NEW_WASM_HASH}" \
  --operator "${MANAGER_ADDRESS}" >/dev/null

printf 'token=%s\nwasm_hash=%s\n' "${TOKEN}" "${NEW_WASM_HASH}"
