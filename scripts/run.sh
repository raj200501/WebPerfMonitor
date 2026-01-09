#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

"${REPO_ROOT}/scripts/bootstrap.sh"

CONFIG_PATH=${1:-"${REPO_ROOT}/config/default.toml"}

cd "${REPO_ROOT}"
PYTHONPATH="${REPO_ROOT}/src" exec python -m web_perf_monitor.cli run-once --config "${CONFIG_PATH}"
