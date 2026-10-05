#!/usr/bin/env bash
set -euo pipefail

export PATH="/c/msys64/ucrt64/bin:/ucrt64/bin:/usr/bin:/bin:$PATH"
if [[ -z "${SAGAN_EXECUTABLE:-}" || -z "${SAGAN_PACKAGE_INDEX:-}" ]]; then
  echo "Workspace test requires SAGAN_EXECUTABLE and SAGAN_PACKAGE_INDEX." >&2
  exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
bash tests/integration/orbit_numeric_test.sh
bash tests/integration/lagrange_numeric_test.sh
bash tests/integration/solar_lagrange_numeric_test.sh
