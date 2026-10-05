# Sagan physics (local split candidate)

This is a local history-preserving rehearsal of `sagan-physics`, not a
published independent repository. It contains the current headless physics
package, numeric examples, failure fixtures, integration checks, and its
technical page. The package remains under `libraries/physics/` in this first
candidate; final root relocation and CI are still open.

`libraries/index.tsv` is a candidate-local package catalog for testing this
source against an installed or explicitly selected Sagan compiler. It is not
a public release catalog. The extracted demo/test scripts accept
`SAGAN_EXECUTABLE` and no longer assume `bin/sagan` lives in this repo.

Read [MAINTAINERS.md](MAINTAINERS.md) for exact Bash commands and recovery,
[TECHNOLOGY.md](TECHNOLOGY.md) for conceptual boundaries, and
[CODEX_START.md](CODEX_START.md) for a new physics chat.
