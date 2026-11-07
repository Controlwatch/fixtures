#!/usr/bin/env bash

set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_command controlwatch
require_fixtures

if [[ "$#" -ne 2 ]]; then
  echo "usage: verify.sh <baseline-snapshot-id> <expected-code>" >&2
  exit 2
fi

BASELINE_ID="$1"
EXPECTED_CODE="$2"
case "${EXPECTED_CODE}" in
  CW-001|CW-003|CW-005|CW-008) ;;
  *)
    echo "unsupported expected detector code: ${EXPECTED_CODE}" >&2
    exit 2
    ;;
esac

TOKEN="$(fixture_value token)"
REPORT="$(mktemp)"
trap 'rm -f "${REPORT}"' EXIT

set +e
controlwatch compare \
  --network testnet \
  --contract "${TOKEN}" \
  --baseline "${BASELINE_ID}" \
  --json "${REPORT}" >/dev/null
COMPARE_EXIT=$?
set -e

if [[ "${COMPARE_EXIT}" -ne 10 ]]; then
  echo "compare exited with ${COMPARE_EXIT}; expected findings exit 10" >&2
  exit 1
fi

TOTAL_FINDINGS="$(grep -c '"code": "CW-' "${REPORT}" || true)"
EXPECTED_FINDINGS="$(grep -c "\"code\": \"${EXPECTED_CODE}\"" "${REPORT}" || true)"
if [[ "${TOTAL_FINDINGS}" -ne 1 || "${EXPECTED_FINDINGS}" -ne 1 ]]; then
  echo "expected exactly one ${EXPECTED_CODE} finding, got total=${TOTAL_FINDINGS} expected=${EXPECTED_FINDINGS}" >&2
  exit 1
fi

printf 'verified %s as the only finding\n' "${EXPECTED_CODE}"
