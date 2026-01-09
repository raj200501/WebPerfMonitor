#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

"${ROOT_DIR}/scripts/bootstrap.sh"

CONFIG_PATH=${1:-"${ROOT_DIR}/config/default.yml"}

cd "${ROOT_DIR}"
WEBPERF_ROOT="${ROOT_DIR}" exec "${ROOT_DIR}/tools/crystal" run src/main.cr -- run-once --config "${CONFIG_PATH}"
