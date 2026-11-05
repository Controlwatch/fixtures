#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_command stellar

ADMIN_IDENTITY="${ADMIN_IDENTITY:-controlwatch-admin}"
MANAGER_IDENTITY="${MANAGER_IDENTITY:-controlwatch-manager}"

require_value ADMIN_IDENTITY
require_value MANAGER_IDENTITY

ADMIN_ADDRESS="$(stellar keys public-key "${ADMIN_IDENTITY}")"
MANAGER_ADDRESS="$(stellar keys public-key "${MANAGER_IDENTITY}")"

build_contracts() {
  local package
  for package in \
    controlwatch-claim-topics-and-issuers \
    controlwatch-compliance \
    controlwatch-identity-registry \
    controlwatch-identity-verifier \
    controlwatch-module-a \
    controlwatch-rwa-token; do
    stellar contract build --package "${package}"
  done
}

deploy_contract() {
  local package_name="$1"
  local alias_name="$2"
  shift 2

  stellar_testnet contract deploy \
    --wasm "$(wasm_path "${package_name}")" \
    --source "${ADMIN_IDENTITY}" \
    --alias "${alias_name}" \
    -- "$@"
}

invoke_as_manager() {
  local contract_id="$1"
  shift

  stellar_testnet contract invoke \
    --id "${contract_id}" \
    --source "${MANAGER_IDENTITY}" \
    -- "$@"
}

write_fixtures() {
  local output="${REPO_ROOT}/fixtures.json"
  local temporary="${output}.tmp"

  printf '{\n' >"${temporary}"
  printf '  "network": "testnet",\n' >>"${temporary}"
  printf '  "token": "%s",\n' "${TOKEN}" >>"${temporary}"
  printf '  "compliance": "%s",\n' "${COMPLIANCE}" >>"${temporary}"
  printf '  "identity_verifier": "%s",\n' "${IDENTITY_VERIFIER}" >>"${temporary}"
  printf '  "identity_registry": "%s",\n' "${IDENTITY_REGISTRY}" >>"${temporary}"
  printf '  "claim_topics_and_issuers": "%s",\n' "${CLAIM_TOPICS_AND_ISSUERS}" >>"${temporary}"
  printf '  "module_a": "%s",\n' "${MODULE_A}" >>"${temporary}"
  printf '  "admin_identity": "%s",\n' "${ADMIN_IDENTITY}" >>"${temporary}"
  printf '  "manager_identity": "%s"\n' "${MANAGER_IDENTITY}" >>"${temporary}"
  printf '}\n' >>"${temporary}"

  mv "${temporary}" "${output}"
}

build_contracts

CLAIM_TOPICS_AND_ISSUERS="$(deploy_contract \
  controlwatch-claim-topics-and-issuers controlwatch-claim-registry \
  --admin "${ADMIN_ADDRESS}" --manager "${MANAGER_ADDRESS}")"

IDENTITY_REGISTRY="$(deploy_contract \
  controlwatch-identity-registry controlwatch-identity-registry \
  --admin "${ADMIN_ADDRESS}" --manager "${MANAGER_ADDRESS}")"

IDENTITY_VERIFIER="$(deploy_contract \
  controlwatch-identity-verifier controlwatch-identity-verifier \
  --admin "${ADMIN_ADDRESS}" \
  --manager "${MANAGER_ADDRESS}" \
  --identity_registry_storage "${IDENTITY_REGISTRY}" \
  --claim_topics_and_issuers "${CLAIM_TOPICS_AND_ISSUERS}")"

COMPLIANCE="$(deploy_contract \
  controlwatch-compliance controlwatch-compliance \
  --admin "${ADMIN_ADDRESS}" --manager "${MANAGER_ADDRESS}")"

MODULE_A="$(deploy_contract \
  controlwatch-module-a controlwatch-module-a \
  --admin "${ADMIN_ADDRESS}" --manager "${MANAGER_ADDRESS}")"

TOKEN="$(deploy_contract \
  controlwatch-rwa-token controlwatch-rwa-token \
  --name "ControlWatch Fixture" \
  --symbol "CWF" \
  --admin "${ADMIN_ADDRESS}" \
  --manager "${MANAGER_ADDRESS}" \
  --compliance "${COMPLIANCE}" \
  --identity_verifier "${IDENTITY_VERIFIER}")"

invoke_as_manager "${COMPLIANCE}" bind_token \
  --token "${TOKEN}" --operator "${MANAGER_ADDRESS}" >/dev/null
invoke_as_manager "${IDENTITY_REGISTRY}" bind_token \
  --token "${TOKEN}" --operator "${MANAGER_ADDRESS}" >/dev/null

write_fixtures

cat <<EOF
--- ControlWatch baseline ---
token=${TOKEN}
compliance=${COMPLIANCE}
identity_verifier=${IDENTITY_VERIFIER}
identity_registry=${IDENTITY_REGISTRY}
claim_topics_and_issuers=${CLAIM_TOPICS_AND_ISSUERS}
module_a=${MODULE_A}
fixtures=${REPO_ROOT}/fixtures.json
--- end baseline ---
EOF
