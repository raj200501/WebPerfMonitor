#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if command -v crystal >/dev/null 2>&1; then
  crystal --version
  exit 0
fi

if [[ -x "${ROOT_DIR}/tools/crystal" ]]; then
  if command -v ruby >/dev/null 2>&1; then
    echo "Crystal compiler not found; using local shim."
    "${ROOT_DIR}/tools/crystal" --version
    exit 0
  fi
  echo "Crystal compiler not found and Ruby unavailable for shim." >&2
  exit 1
fi

echo "Crystal compiler not found and shim missing." >&2
exit 1
