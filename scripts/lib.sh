#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly TESTNET_PASSPHRASE="Test SDF Network ; September 2015"

NETWORK="${NETWORK:-testnet}"
NETWORK_PASSPHRASE="${NETWORK_PASSPHRASE:-${TESTNET_PASSPHRASE}}"
RPC_URL="${RPC_URL:-https://soroban-testnet.stellar.org}"

if [[ -f "${REPO_ROOT}/.env" ]]; then
  # shellcheck disable=SC1091
  source "${REPO_ROOT}/.env"
fi

require_testnet() {
  if [[ "${NETWORK}" != "testnet" ]]; then
    echo "refusing to run: NETWORK must be testnet" >&2
    exit 2
  fi

  if [[ "${NETWORK_PASSPHRASE}" != "${TESTNET_PASSPHRASE}" ]]; then
    echo "refusing to run: NETWORK_PASSPHRASE is not the Stellar testnet passphrase" >&2
    exit 2
  fi
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "required command not found: $1" >&2
    exit 2
  fi
}

require_value() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "required environment variable is empty: ${name}" >&2
    exit 2
  fi
}

wasm_path() {
  local package_name="$1"
  printf '%s/target/wasm32v1-none/release/%s.wasm' \
    "${REPO_ROOT}" "${package_name//-/_}"
}

stellar_testnet() {
  stellar "$@" \
    --rpc-url "${RPC_URL}" \
    --network-passphrase "${NETWORK_PASSPHRASE}"
}

require_testnet
