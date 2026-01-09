#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

"${ROOT_DIR}/scripts/bootstrap.sh"

cd "${ROOT_DIR}"

echo "Running specs..."
WEBPERF_ROOT="${ROOT_DIR}" "${ROOT_DIR}/tools/crystal" run scripts/spec_runner.cr

echo "Running smoke test..."
WEBPERF_ROOT="${ROOT_DIR}" "${ROOT_DIR}/tools/crystal" run scripts/smoke.cr
