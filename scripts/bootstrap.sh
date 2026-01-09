#!/usr/bin/env bash
set -euo pipefail

if ! command -v python >/dev/null 2>&1; then
  echo "Python is required but not found." >&2
  exit 1
fi

python - <<'PY'
import sys
if sys.version_info < (3, 11):
    raise SystemExit("Python 3.11+ is required")
print(f"Python OK: {sys.version.split()[0]}")
PY
