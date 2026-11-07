#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_command stellar
require_fixtures

TOKEN="$(fixture_value token)"
ADMIN_IDENTITY="$(fixture_value admin_identity)"
MANAGER_IDENTITY="$(fixture_value manager_identity)"
ADMIN_ADDRESS="$(stellar keys public-key "${ADMIN_IDENTITY}")"
MANAGER_ADDRESS="$(stellar keys public-key "${MANAGER_IDENTITY}")"

stellar contract build --package controlwatch-compliance

NEW_COMPLIANCE="$(stellar_testnet contract deploy \
  --wasm "$(wasm_path controlwatch-compliance)" \
  --source "${ADMIN_IDENTITY}" \
  --alias controlwatch-compliance-mutated \
  -- --admin "${ADMIN_ADDRESS}" --manager "${MANAGER_ADDRESS}")"

stellar_testnet contract invoke \
  --id "${TOKEN}" \
  --source "${MANAGER_IDENTITY}" \
  -- set_compliance \
  --compliance "${NEW_COMPLIANCE}" \
  --operator "${MANAGER_ADDRESS}" >/dev/null

stellar_testnet contract invoke \
  --id "${NEW_COMPLIANCE}" \
  --source "${MANAGER_IDENTITY}" \
  -- bind_token \
  --token "${TOKEN}" \
  --operator "${MANAGER_ADDRESS}" >/dev/null

printf 'compliance=%s\n' "${NEW_COMPLIANCE}"
