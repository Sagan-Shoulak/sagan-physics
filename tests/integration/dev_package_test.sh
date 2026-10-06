#!/usr/bin/env bash
set -euo pipefail

export PATH="/c/msys64/ucrt64/bin:/ucrt64/bin:/usr/bin:/bin:$PATH"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
compiler_zip="${SAGAN_RELEASE_ZIP:?Set SAGAN_RELEASE_ZIP to the released Sagan 4.9.5 Windows portable ZIP}"
if command -v cygpath >/dev/null 2>&1; then
  compiler_zip="$(cygpath -u "$compiler_zip")"
fi
expected_compiler_sha="f62f25076e229ab0f57b58d6f58c54ff61a57240195db7424a49699c09fc1adf"
python_executable="${PYTHON:-python}"
work_root="$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/sagan-physics-package.XXXXXX")"
hidden_physics=""
hidden_index=""

restore_source() {
  if [[ -n "$hidden_index" && -e "$hidden_index" ]]; then mv "$hidden_index" "$repo_root/libraries/index.tsv"; fi
  if [[ -n "$hidden_physics" && -e "$hidden_physics" ]]; then mv "$hidden_physics" "$repo_root/libraries/physics"; fi
  rm -rf "$work_root"
}
trap restore_source EXIT

actual_compiler_sha="$(sha256sum "$compiler_zip" | awk '{print $1}')"
[[ "$actual_compiler_sha" == "$expected_compiler_sha" ]] || { echo "Sagan 4.9.5 archive checksum mismatch" >&2; exit 1; }

mkdir -p "$work_root/build-a" "$work_root/build-b" "$work_root/compiler" "$work_root/package" "$work_root/consumer"
bash "$repo_root/scripts/build-dev-package.sh" --output-dir "$work_root/build-a"
bash "$repo_root/scripts/build-dev-package.sh" --output-dir "$work_root/build-b"
archive_a="$(find "$work_root/build-a" -maxdepth 1 -name '*.zip' -print -quit)"
archive_b="$(find "$work_root/build-b" -maxdepth 1 -name '*.zip' -print -quit)"
[[ "$(sha256sum "$archive_a" | awk '{print $1}')" == "$(sha256sum "$archive_b" | awk '{print $1}')" ]]
[[ "$(sha256sum "$archive_a.sha256" | awk '{print $1}')" == "$(sha256sum "$archive_b.sha256" | awk '{print $1}')" ]]
(cd "$work_root/build-a" && sha256sum -c "$(basename "$archive_a.sha256")")

"$python_executable" -m zipfile -e "$compiler_zip" "$work_root/compiler"
"$python_executable" -m zipfile -e "$archive_a" "$work_root/package"
package_root="$(find "$work_root/package" -mindepth 1 -maxdepth 1 -type d -name 'sagan-physics-*' -print -quit)"
sagan_executable="$(find "$work_root/compiler" -type f -name sagan.exe -print -quit)"
[[ -n "$package_root" && -n "$sagan_executable" ]]
(cd "$package_root" && sha256sum -c SHA256SUMS)

compiler_version="$($sagan_executable --version)"
[[ "$compiler_version" == "Sagan 4.9.5" ]] || { echo "Expected released Sagan 4.9.5, got: $compiler_version" >&2; exit 1; }

cp -a "$repo_root/examples" "$work_root/consumer/examples"
mkdir -p "$work_root/consumer/tests/integration" "$work_root/consumer/tests/fixtures"
cp -a "$repo_root/tests/integration/orbit_numeric_test.sh" "$work_root/consumer/tests/integration/"
cp -a "$repo_root/tests/integration/lagrange_numeric_test.sh" "$work_root/consumer/tests/integration/"
cp -a "$repo_root/tests/integration/solar_lagrange_numeric_test.sh" "$work_root/consumer/tests/integration/"
cp -a "$repo_root/tests/fixtures/physics" "$work_root/consumer/tests/fixtures/physics"

export SAGAN_EXECUTABLE="$sagan_executable"
export SAGAN_PACKAGE_INDEX="$package_root/index.tsv"
consumer_output="$work_root/consumer-output.txt"
(cd "$work_root/consumer" && bash tests/integration/orbit_numeric_test.sh && bash tests/integration/lagrange_numeric_test.sh && bash tests/integration/solar_lagrange_numeric_test.sh) | tee "$consumer_output"

if grep -F "$repo_root" "$consumer_output" || grep -F "$repo_root" "$package_root/index.tsv"; then
  echo "Clean-location package leaked the source checkout path" >&2
  exit 1
fi

hidden_physics="$work_root/hidden-physics"
hidden_index="$work_root/hidden-index.tsv"
mv "$repo_root/libraries/physics" "$hidden_physics"
mv "$repo_root/libraries/index.tsv" "$hidden_index"
(cd "$work_root/consumer" && bash tests/integration/orbit_numeric_test.sh && bash tests/integration/lagrange_numeric_test.sh && bash tests/integration/solar_lagrange_numeric_test.sh)
mv "$hidden_index" "$repo_root/libraries/index.tsv"
hidden_index=""
mv "$hidden_physics" "$repo_root/libraries/physics"
hidden_physics=""

corrupt_root="$work_root/corrupt"
cp -a "$package_root" "$corrupt_root"
printf '\ncorruption\n' >> "$corrupt_root/physics/src/two_body.sagan"
if (cd "$corrupt_root" && sha256sum -c SHA256SUMS >/dev/null 2>&1); then
  echo "Corrupted package unexpectedly passed checksum verification" >&2
  exit 1
fi

echo "Dev package test passed: deterministic archive, released Sagan 4.9.5 clean-location consumption, hidden-source replay, and corruption rejection."
