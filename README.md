# Sagan physics

This public history-preserving split repository contains the current headless physics
package, numeric examples, failure fixtures, integration checks, and its
technical page. The package remains under `libraries/physics/`; its public
development-channel archive preserves the installed `physics/` catalog layout.

`libraries/index.tsv` is a repository-local package catalog for testing this
source against an installed or explicitly selected Sagan compiler. It is not
a public release catalog. The extracted demo/test scripts accept
`SAGAN_EXECUTABLE` and no longer assume `bin/sagan` lives in this repo.

Read [MAINTAINERS.md](MAINTAINERS.md) for exact Bash commands and recovery,
[TECHNOLOGY.md](TECHNOLOGY.md) for conceptual boundaries, and `AGENTS.md` for
lasting chat guidance.

## Dev-channel package

Build a deterministic, checksummed source package from committed content:

```bash
bash scripts/build-dev-package.sh --output-dir build/dev-package
```

The archive contains `sagan-physics` 0.3.0, an installed-package index,
complete GPL-3.0-only licensing, provenance, and internal payload checksums.
Its adjacent `.sha256` file verifies the archive itself. This is a
development-channel artifact, not a stable release or permission to promote
`main`.
