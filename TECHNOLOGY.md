---
title: Sagan physics technology overview
status: review-needed
publication_ready: false
verified_in: null
verified_on: null
verified_by: null
---

# Sagan physics technology overview

This repository owns physics models and numerical algorithms, not language
syntax, game rules, or rendering backends. The current Sagan package under
`libraries/physics/` exports two-body and restricted-three-body operations
used by the headless orbit and Lagrange demos. Tests exercise conserved
quantity drift, representative orbital behavior, tracer stability/escape
outputs, and invalid input rejection. Those tests are evidence about these
specific implementations and tolerances, not a general proof of physical
correctness for every scenario.

The package source is Sagan. `libraries/physics/sagan.toml` declares its
package identity and version; `libraries/index.tsv` lets the current
compiler resolve this candidate locally without accidentally loading the
monorepo's physics source. The numeric demos in `examples/` consume that
package through their own manifests/locks. The tests in `tests/integration/`
drive those demos and check important output contracts, while negative
fixtures under `tests/fixtures/physics/` check rejected inputs.

The dependency direction is physics to Sagan's language/math/toolchain.
Rendering and the Space Game consume physics, never the reverse. The future
workspace exact lock coordinates tested versions across repositories;
physics can still be developed and tested independently. The present local
catalog is a source-checkout aid, not a substitute for released package
metadata or compatibility verification.

The `dev` branch also builds a deterministic GPL-3.0-only ZIP containing a
self-contained installed-package index, the 0.3.0 manifest and sources,
provenance, and payload checksums. Its Windows clean-location test consumes
the released Sagan 4.9.5 portable compiler without a sibling source checkout.
This remains a prerelease development channel; Linux and macOS currently have
exact-source CI evidence rather than installed compiler artifacts.

The first extracted tree retained all 29 owned files and relevant history
only when the pinned filter used `--no-ff`; the default filter silently
omitted four solar-Lagrange files. Therefore exact file-manifest comparison
after filtering is a required invariant, not optional polish. The final
stable package distribution and installed-artifact validation beyond Windows
remain to be completed. See [MAINTAINERS.md](MAINTAINERS.md).
