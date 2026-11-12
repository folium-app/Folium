"""Check pinned cores, package lock, and arm64 iOS XCFrameworks before compilation."""
import argparse
import hashlib
import json
from pathlib import Path
import plistlib
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
LOCK = ROOT / "Folium.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"


def command(*args):
    return subprocess.check_output(args, cwd=ROOT, text=True, encoding="utf-8").strip()


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as content:
        for chunk in iter(lambda: content.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def inspect_framework(path):
    with (path / "Info.plist").open("rb") as content:
        info = plistlib.load(content)
    devices = [library for library in info["AvailableLibraries"]
               if library["SupportedPlatform"] == "ios"
               and not library.get("SupportedPlatformVariant")
               and "arm64" in library["SupportedArchitectures"]]
    if not devices:
        raise ValueError(f"No arm64 iOS device slice in {path}")
    results = []
    for device in devices:
        binary = path / device["LibraryIdentifier"] / device["LibraryPath"]
        if binary.suffix == ".framework":
            binary /= binary.stem
        if not binary.is_file():
            raise ValueError(f"Missing XCFramework binary: {binary}")
        with binary.open("rb") as content:
            if content.read(50).startswith(b"version https://git-lfs.github.com/spec/"):
                raise ValueError(f"Unfetched Git LFS pointer: {binary}")
        record = {"path": binary.relative_to(ROOT).as_posix(), "sha256": sha256(binary),
                  "architectures": device["SupportedArchitectures"]}
        if sys.platform == "darwin":
            record["file"] = command("file", str(binary))
            record["lipo"] = command("lipo", "-archs", str(binary))
            if "arm64" not in record["lipo"].split():
                raise ValueError(f"Binary lacks arm64: {binary}")
            if "archive" in record["file"]:
                record["otool_L"] = "Static archive; no runtime load dependencies."
            else:
                record["otool_L"] = command("otool", "-L", str(binary))
        results.append(record)
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--artifacts", type=Path, help="Also inspect resolved SwiftPM XCFrameworks")
    parser.add_argument("--output", type=Path, default=ROOT / "build/source-manifest.json")
    args = parser.parse_args()
    status = subprocess.check_output(
        ["git", "submodule", "status", "--recursive"], cwd=ROOT, text=True
    ).splitlines()
    if not status or any(line[0] != " " for line in status):
        raise ValueError("Submodules are absent, conflicted, or differ from the committed pins")
    submodules = []
    for line in status:
        revision, path, *_ = line.split()
        dirty = command("git", "-C", str(ROOT / path), "status", "--porcelain")
        if dirty:
            raise ValueError(f"Submodule has local modifications: {path}")
        submodules.append({"path": path, "revision": revision})
    pins = json.loads(LOCK.read_text())["pins"]
    for pin in pins:
        if len(pin["state"]["revision"]) != 40:
            raise ValueError(f"Unpinned package: {pin['identity']}")
    frameworks = sorted((ROOT / "Dependencies").rglob("*.xcframework"))
    if not frameworks:
        raise ValueError("Tracked XCFrameworks are missing")
    if args.artifacts:
        if not args.artifacts.is_dir():
            raise ValueError(f"SwiftPM artifacts directory is missing: {args.artifacts}")
        resolved = sorted(args.artifacts.resolve().rglob("*.xcframework"))
        if not resolved:
            raise ValueError("No resolved binary XCFrameworks found")
        frameworks += resolved
    binaries = [binary for framework in frameworks for binary in inspect_framework(framework)]
    manifest = {
        "source_revision": command("git", "rev-parse", "HEAD"),
        "upstream_baseline": (ROOT / "ci/upstream-revision.txt").read_text().strip(),
        "test_device": "iPhone", "test_os": "iOS 27.2",
        "submodules": submodules, "swift_packages": pins,
        "package_lock_sha256": sha256(LOCK),
        "header_lock_sha256": sha256(ROOT / "ci/headers.lock.json"),
        "binary_inspection_host": sys.platform,
        "xcframework_device_binaries": binaries,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Validated {len(submodules)} pinned cores, {len(pins)} locked packages, "
          f"and {len(frameworks)} arm64 iOS XCFrameworks; manifest: {args.output}")


if __name__ == "__main__":
    main()
