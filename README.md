# Sagan physics

This public history-preserving split repository contains the current headless physics
package, numeric examples, failure fixtures, integration checks, and its
technical page. The package remains under `libraries/physics/` in this first
layout; final root relocation and CI are still open.

`libraries/index.tsv` is a repository-local package catalog for testing this
source against an installed or explicitly selected Sagan compiler. It is not
a public release catalog. The extracted demo/test scripts accept
`SAGAN_EXECUTABLE` and no longer assume `bin/sagan` lives in this repo.

Read [MAINTAINERS.md](MAINTAINERS.md) for exact Bash commands and recovery,
[TECHNOLOGY.md](TECHNOLOGY.md) for conceptual boundaries, and
`CODEX_START.md` once if it still exists, then `AGENTS.md` for lasting chat
guidance.
