#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)

"${REPO_ROOT}/scripts/bootstrap.sh"

cd "${REPO_ROOT}"

echo "Running unit tests..."
PYTHONPATH="${REPO_ROOT}/src" python -m unittest discover -s tests -p "test_*.py"

echo "Running smoke test..."
PYTHONPATH="${REPO_ROOT}/src" python scripts/smoke.py
