#!/usr/bin/env python3
"""Build a deterministic, checksummed sagan-physics dev-channel archive."""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import subprocess
import tempfile
import zipfile
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath


REPOSITORY_URL = "https://github.com/Sagan-Shoulak/sagan-physics"
COMPILER_COMPATIBILITY = "^4.0.0"
LICENSE_EXPRESSION = "GPL-3.0-only"
PAYLOAD_SOURCES = {
    "LICENSE.txt": "LICENSE.txt",
    "NOTICE.md": "NOTICE.md",
    "physics/sagan.toml": "libraries/physics/sagan.toml",
    "physics/src/restricted_three_body.sagan": "libraries/physics/src/restricted_three_body.sagan",
    "physics/src/solar_lagrange.sagan": "libraries/physics/src/solar_lagrange.sagan",
    "physics/src/two_body.sagan": "libraries/physics/src/two_body.sagan",
}


def run_git(repo: Path, *arguments: str) -> bytes:
    return subprocess.check_output(["git", "-C", str(repo), *arguments])


def committed_bytes(repo: Path, commit: str, path: str) -> bytes:
    return run_git(repo, "show", f"{commit}:{path}")


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def package_version(manifest: bytes) -> str:
    match = re.search(rb'^version\s*=\s*"([^"]+)"\s*$', manifest, re.MULTILINE)
    if not match:
        raise SystemExit("Could not read package version from libraries/physics/sagan.toml")
    return match.group(1).decode("ascii")


def generated_files(commit: str, version: str, commit_time: int) -> dict[str, bytes]:
    index = (
        "sagan-package-index-v1\n"
        f"sagan-physics\t{version}\t{COMPILER_COMPATIBILITY}\tinstalled\tphysics/sagan.toml\n"
    ).encode("utf-8")
    readme = f"""# Sagan physics {version} dev-channel package

This archive contains the Sagan source package only. It is not a stable
release. The package is licensed under GPL-3.0-only.

Set `SAGAN_PACKAGE_INDEX` to the absolute path of this directory's
`index.tsv`, then run a package whose manifest depends on:

```toml
[dependencies]
physics = {{ package = "sagan-physics", version = "^{version}" }}
```

The package declares compiler compatibility `{COMPILER_COMPATIBILITY}` and
was clean-location tested with the released Sagan 4.9.5 Windows portable
compiler. Linux and macOS CI build an exact pinned compiler source revision;
no installed compiler artifact is currently claimed on those platforms.

Verify the extracted payload with `sha256sum -c SHA256SUMS`. Verify the ZIP
before extraction with its separately published `.sha256` asset.

Rollback removes this extracted directory or stops selecting its index. A
GitHub prerelease can be withdrawn without deleting or rewriting source
history.
""".encode("utf-8")
    timestamp = datetime.fromtimestamp(commit_time, timezone.utc).isoformat().replace("+00:00", "Z")
    provenance = f"""repository={REPOSITORY_URL}
commit={commit}
commit_timestamp={timestamp}
package=sagan-physics
package_version={version}
compiler_compatibility={COMPILER_COMPATIBILITY}
license={LICENSE_EXPRESSION}
builder=scripts/build-dev-package.py@{commit}
validated_compiler_release=v4.9.5
validated_compiler_asset=sagan-4.9.5-windows-x64.zip
validated_compiler_sha256=f62f25076e229ab0f57b58d6f58c54ff61a57240195db7424a49699c09fc1adf
installed_artifact_platform=windows-x64
linux_macos_evidence=source-built-exact-pin-only
""".encode("utf-8")
    return {"README.md": readme, "PROVENANCE.txt": provenance, "index.tsv": index}


def zip_timestamp(epoch: int) -> tuple[int, int, int, int, int, int]:
    value = datetime.fromtimestamp(epoch, timezone.utc)
    if value.year < 1980:
        value = datetime(1980, 1, 1, tzinfo=timezone.utc)
    return (value.year, value.month, value.day, value.hour, value.minute, value.second - value.second % 2)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--commit", default="HEAD")
    arguments = parser.parse_args()

    repo = Path(__file__).resolve().parents[1]
    commit = run_git(repo, "rev-parse", f"{arguments.commit}^{{commit}}").decode().strip()
    commit_time = int(run_git(repo, "show", "-s", "--format=%ct", commit).decode().strip())
    manifest = committed_bytes(repo, commit, "libraries/physics/sagan.toml")
    version = package_version(manifest)
    archive_root = f"sagan-physics-{version}-dev.{commit[:12]}"

    payload: dict[str, bytes] = {
        destination: committed_bytes(repo, commit, source)
        for destination, source in PAYLOAD_SOURCES.items()
    }
    payload.update(generated_files(commit, version, commit_time))
    payload["SHA256SUMS"] = "".join(
        f"{sha256(payload[path])}  {path}\n" for path in sorted(payload)
    ).encode("ascii")

    arguments.output_dir.mkdir(parents=True, exist_ok=True)
    archive = arguments.output_dir / f"{archive_root}.zip"
    external_checksum = arguments.output_dir / f"{archive.name}.sha256"
    timestamp = zip_timestamp(commit_time)
    with tempfile.NamedTemporaryFile(dir=arguments.output_dir, delete=False) as temporary:
        temporary_path = Path(temporary.name)
    try:
        # Store this small source package without compression. Deflate output
        # varies across zlib versions even when every input and ZIP header is
        # identical, which would make cross-host artifact hashes unstable.
        with zipfile.ZipFile(temporary_path, "w", zipfile.ZIP_STORED) as output:
            for relative_path in sorted(payload):
                name = str(PurePosixPath(archive_root) / PurePosixPath(relative_path))
                info = zipfile.ZipInfo(name, timestamp)
                info.create_system = 3
                info.external_attr = 0o100644 << 16
                output.writestr(info, payload[relative_path], compress_type=zipfile.ZIP_STORED)
        os.replace(temporary_path, archive)
    finally:
        temporary_path.unlink(missing_ok=True)

    archive_digest = sha256(archive.read_bytes())
    external_checksum.write_text(f"{archive_digest}  {archive.name}\n", encoding="ascii", newline="\n")
    print(archive)
    print(external_checksum)
    print(archive_digest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
