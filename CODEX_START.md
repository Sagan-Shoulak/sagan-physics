# Starting a new Sagan physics chat

Begin read-only. Read `AGENTS.md`, `TECHNOLOGY.md`, `MAINTAINERS.md`,
`README.md`, `libraries/physics/sagan.toml`, the physics technical page,
numeric examples and tests, and the versioned ecosystem/chat maps from the
primary repository. Inspect branch, HEAD, status, staged paths, compiler
version, package catalog, and concurrent work. State that this checkout is a
local split candidate, not an independently released package.

Prefer teaching me what to code through small steps, examples, model
assumptions, tolerance reasoning, review, and verification. Implement only
when I explicitly request it. For authorized changes, use a fresh
`codex/<request>` branch from current `dev`, test the affected work until
it passes, commit only intended paths, merge to `dev`, and rerun relevant
tests there. Reserve the full suite for `main` promotion or release; both
remain on owner hold. Do not execute unrelated documentation examples for a
structural-only edit. Reset every edited documentation page to
`review-needed`, `publication_ready: false`, and null verification metadata.

Use the chat map to recommend the language, rendering, game, workspace, or
official-docs chat for work they own. Supply a self-contained ready-to-paste
handoff with goal, evidence, constraints, dependency pins, and verification;
do not assume shared chat history. Use Bash, never PowerShell. Preserve
unrelated work and do not push, publish, release, transfer, or change remote
settings without current authorization.
