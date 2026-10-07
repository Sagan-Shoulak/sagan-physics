---
title: Maintaining Sagan physics
status: review-needed
publication_ready: false
verified_in: null
verified_on: null
verified_by: null
---

# Maintaining Sagan physics

This is a public split repository, not a released package. Its
`libraries/physics/sagan.toml` currently declares `sagan-physics` version
`0.3.0`; the repository-local `libraries/index.tsv` points to that manifest
and declares compiler compatibility `^4.0.0`. The index must stay inside the
repository so its manifest path does not escape the index root. Do not use the
old monorepo index when validating this repository.

## Exact focused checks

Independent CI checks out the exact language commit in
`sagan-source-commit.txt`, builds its compiler on Linux, macOS, and Windows,
then runs the three headless numeric tests below with this repository's
`libraries/index.tsv`. Change the pin only in a reviewed compatibility PR;
do not silently substitute a sibling checkout or a branch tip.
On macOS, CI temporarily demotes only Clang's generated-C++
`-Wparentheses-equality` warning; the language compiler should remove that
workaround once its code generator emits warning-clean equality expressions.

When selected by the exact workspace lock, `scripts/workspace-build.sh` emits
the orbit demo's linked C++ and `scripts/workspace-test.sh` runs all three
numeric checks. The workspace coordinator supplies its pinned compiler and
combined package index through `SAGAN_EXECUTABLE` and `SAGAN_PACKAGE_INDEX`;
outside a workspace, set both explicitly.

Install or build a compatible Sagan compiler and native C++ toolchain.
From this candidate root in Git Bash on the current Windows machine:

```bash
export SAGAN_EXECUTABLE=/c/Users/joeps/coding/sagan/bin/sagan.exe
bash tests/integration/orbit_numeric_test.sh
bash tests/integration/lagrange_numeric_test.sh
bash tests/integration/solar_lagrange_numeric_test.sh
```

Each script sets the local `SAGAN_PACKAGE_INDEX` by default and adds the
current Windows MinGW toolchain paths. If Sagan is correctly installed on
PATH, omit `SAGAN_EXECUTABLE`; the scripts default to `sagan`. For a different
package index, set `SAGAN_PACKAGE_INDEX` explicitly to an exact, reviewed
catalog before running. The three test scripts passed on Windows with the
existing Sagan 4.9.5 development binary and the extracted local package.
The orbit test also passed the three invalid mass/step/overlap fixtures.
Hosted source-built checks pass on Linux, macOS, and Windows. Installed
artifact consumption is verified only on Windows because Sagan 4.9.5 does not
publish Linux or macOS compiler artifacts.

### Dev-channel artifact

Build a deterministic package from committed `dev` content with:

```bash
bash scripts/build-dev-package.sh --output-dir build/dev-package
```

The ZIP contains a repository-local `index.tsv`, the package manifest and
sources, GPL-3.0-only license and attribution, provenance, and internal
`SHA256SUMS`. Verify the archive with its adjacent `.zip.sha256` file before
extracting it. Set `SAGAN_PACKAGE_INDEX` to the extracted `index.tsv`; do not
copy its manifest into another catalog or silently fall back to a sibling
checkout.

`tests/integration/dev_package_test.sh` requires `SAGAN_RELEASE_ZIP` to name
the official Sagan 4.9.5 Windows portable ZIP. It verifies that compiler
asset's recorded digest, deterministic package bytes, internal and external
checksums, all three numeric suites and negative fixtures from a clean
location, a second run with the repository package source hidden, and
corruption rejection.

Withdraw a bad prerelease by removing its release assets and prerelease entry,
then stop selecting that package index. Never delete or rewrite the source
commit or its reviewed history as part of artifact rollback.

The corresponding demonstration commands are:

```bash
bash scripts/orbit_numeric_demo.sh
bash scripts/lagrange_numeric_demo.sh
bash scripts/solar_lagrange_numeric_demo.sh
```

Those scripts run headlessly and do not require a rendering window. Build
outputs and generated caches belong in ignored `build/`. Do not edit the
numeric examples' expected behavior merely to make a changed solver pass;
review units, frames, time step, tolerances, and the physical model.

## Branches, review, and release

Inspect branch, HEAD, status, staged paths, exact toolchain version, and
relevant history first. For every authorized request, start from current
`dev` on a fresh `codex/<request>` branch. Test the affected work, refine
until it works and focused tests pass, commit only intended paths, merge to
`dev`, and rerun those relevant tests against concurrent integration. The
full suite is reserved for reviewed `dev` to `main` promotion or release.
Both promotion and releases remain on owner hold until explicitly reopened
with a publication/signing policy; passing tests alone cannot lift the hold.

Structural-only documentation edits do not require unrelated executable
examples. Run affected examples when their source or supporting behavior
changes. Any edited documentation page resets to `status: review-needed`,
`publication_ready: false`, and null verification fields until a human audit.

## Extraction and recovery

The local history extraction requires the pinned `git-filter-repo` v2.47.0
with `--no-ff`, the exact `sagan-physics.txt` ownership manifest, a
disposable mirror, and post-filter exact-tree plus `git fsck --full` checks.
Default filtering omitted four solar-Lagrange files despite exiting zero.
Do not use its filtered tree, and do not rewrite the intact repository.
The final split must preserve relevant author/timestamp history and publish
only reviewed `dev` and `main` heads without inherited language release tags.

The current package path, technical docs links, CI, package distribution,
version compatibility, cross-platform checks, workspace lock, and owner
clean-machine drill still require independent validation. A failing
dependency lookup should be diagnosed against `libraries/index.tsv` and the
active `SAGAN_PACKAGE_INDEX`, not fixed by copying code into a consumer.
No local Git mirror or workspace lock can recover GitHub settings, secrets,
issues, or PR history; the current transfer backup is local-only and would
be lost with this machine.
