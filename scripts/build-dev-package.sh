#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python_executable="${PYTHON:-python}"
exec "$python_executable" "$repo_root/scripts/build-dev-package.py" "$@"
