"""Validate a fresh iPhone device build and package it for local Sideloadly signing."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import shutil
import subprocess
import sys
import zipfile


ROOT = Path(__file__).resolve().parents[1]
MACHO = {b"\xcf\xfa\xed\xfe", b"\xfe\xed\xfa\xcf", b"\xca\xfe\xba\xbe",
         b"\xbe\xba\xfe\xca", b"\xca\xfe\xba\xbf", b"\xbf\xba\xfe\xca"}


def run(*args):
    return subprocess.check_output(args, text=True, stderr=subprocess.STDOUT).strip()


def expanded(path, binary, app):
    return Path(path.replace("@executable_path", str(app))
                .replace("@loader_path", str(binary.parent)))


def inspect_app(app, sdk, log):
    with (app / "Info.plist").open("rb") as content:
        info = plistlib.load(content)
    if info.get("DTPlatformName") != "iphoneos" or info.get("UIDeviceFamily") != [1]:
        raise ValueError("App must be built for the iPhone device platform")
    main = app / info["CFBundleExecutable"]
    if not main.is_file():
        raise ValueError(f"Missing app executable: {main}")
    binaries = []
    for path in sorted(app.rglob("*")):
        if path.is_file() and not path.is_symlink():
            with path.open("rb") as content:
                if content.read(4) in MACHO:
                    binaries.append(path)
    if main not in binaries:
        raise ValueError("App executable is not a Mach-O binary")
    commands = {binary: run("otool", "-l", str(binary)) for binary in binaries}
    rpath_pattern = r"cmd LC_RPATH\s+cmdsize \d+\s+path (.+?) \(offset"
    main_rpaths = re.findall(rpath_pattern, commands[main])
    with log.open("w", encoding="utf-8") as output:
        for binary in binaries:
            arches = run("lipo", "-archs", str(binary)).split()
            if arches != ["arm64"]:
                raise ValueError(f"Unexpected packaged architectures {arches}: {binary}")
            load_commands = commands[binary]
            platforms = re.findall(r"\bplatform (\S+)", load_commands)
            if platforms:
                if any(platform not in ("2", "IOS") for platform in platforms):
                    raise ValueError(f"Non-iOS device Mach-O: {binary}: {platforms}")
            elif "LC_VERSION_MIN_IPHONEOS" not in load_commands:
                raise ValueError(f"Cannot confirm iOS device platform: {binary}")
            dependencies = run("otool", "-L", str(binary))
            output.write(f"{run('file', str(binary))}\n{dependencies}\n{load_commands}\n")
            rpaths = [expanded(path, binary, app) for path in re.findall(rpath_pattern, load_commands)]
            rpaths += [expanded(path, main, app) for path in main_rpaths]
            for line in dependencies.splitlines()[1:]:
                dependency = line.strip().split(" (", 1)[0]
                if dependency.startswith(("/System/Library/", "/usr/lib/")):
                    continue
                if dependency.startswith("@rpath/"):
                    relative = dependency[len("@rpath/"):]
                    candidates = [path / relative for path in rpaths]
                    # Swift libraries supplied by iOS may live outside the app.
                    system_swift = (sdk / "usr/lib/swift" / relative).with_suffix(".tbd")
                    if relative.startswith("libswift") and system_swift.is_file():
                        continue
                elif dependency.startswith(("@loader_path/", "@executable_path/")):
                    candidates = [expanded(dependency, binary, app)]
                else:
                    raise ValueError(f"Non-system absolute or unknown dependency: {dependency}")
                if not any(path.is_file() and path.resolve().is_relative_to(app.resolve())
                           for path in candidates):
                    raise ValueError(f"Unresolved bundle dependency {dependency} in {binary}")
    return info


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run", required=True, type=Path)
    args = parser.parse_args()
    if sys.platform != "darwin":
        raise SystemExit("Packaging requires Apple's macOS validation tools")
    directory = args.run.resolve()
    if not directory.is_relative_to(ROOT / "build"):
        raise ValueError("Build directory must be inside this checkout's build folder")
    logs = directory / "logs"
    settings = json.loads((logs / "build-settings.json").read_text())
    targets = [row["buildSettings"] for row in settings if row["target"] == "Folium"]
    if len(targets) != 1:
        raise ValueError("Expected exactly one resolved Folium app target")
    app = Path(targets[0]["TARGET_BUILD_DIR"]) / targets[0]["WRAPPER_NAME"]
    if not app.resolve().is_relative_to(directory / "DerivedData") or not app.is_dir():
        raise ValueError(f"Missing app or output outside the fresh DerivedData directory: {app}")
    sdk = Path(run("xcrun", "--sdk", "iphoneos", "--show-sdk-path"))
    info = inspect_app(app, sdk, logs / "bundle-inspection.txt")
    stage = directory / "stage"
    stage.mkdir()  # Refuse an existing staging tree.
    payload = stage / "Payload"
    payload.mkdir()
    staged_app = payload / app.name
    run("ditto", str(app), str(staged_app))
    # Ad-hoc signatures provide bundle integrity; Sideloadly supplies the install signature.
    nested = [path for path in staged_app.rglob("*")
              if path.suffix in (".framework", ".appex", ".app", ".dylib")]
    for path in sorted(nested, key=lambda item: len(item.parts), reverse=True) + [staged_app]:
        run("codesign", "--force", "--sign", "-", "--timestamp=none", str(path))
    run("codesign", "--verify", "--deep", "--strict", str(staged_app))
    artifacts = directory / "artifacts"
    artifacts.mkdir(exist_ok=True)
    manifest = json.loads((logs / "source-manifest.json").read_text())
    ipa = artifacts / f"Folium-diagnostic-{manifest['source_revision'][:12]}.ipa"
    if ipa.exists():
        raise ValueError(f"Refusing to overwrite an existing IPA: {ipa}")
    run("ditto", "-c", "-k", "--norsrc", "--noextattr", "--keepParent", str(payload), str(ipa))
    with zipfile.ZipFile(ipa) as archive:
        names = archive.namelist()
        required = [f"Payload/{app.name}/Info.plist", f"Payload/{app.name}/{info['CFBundleExecutable']}"]
        if any(name not in names for name in required) or any(
            not name.startswith("Payload/") or ".." in Path(name).parts for name in names
        ):
            raise ValueError("Invalid IPA Payload layout")
        bad_member = archive.testzip()
        if bad_member:
            raise ValueError(f"Corrupt archive member: {bad_member}")
    digest = hashlib.sha256(ipa.read_bytes()).hexdigest()
    (artifacts / f"{ipa.name}.sha256").write_text(f"{digest}  {ipa.name}\n", encoding="utf-8")
    manifest.update({
        "built_at_utc": datetime.now(timezone.utc).isoformat(),
        "ipa": ipa.name, "ipa_sha256": digest,
        "bundle_identifier": info["CFBundleIdentifier"],
        "minimum_ios": info.get("MinimumOSVersion"),
        "signing": "ad-hoc; requires local Sideloadly re-signing",
        "github_run_id": os.environ.get("GITHUB_RUN_ID"),
        "device_runtime_tested": False,
    })
    (artifacts / "build-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    for name in ("Package.resolved", "headers.lock.json", "toolchain.txt", "source.patch", "source-status.txt"):
        shutil.copy2(logs / name, artifacts / name)
    print(f"Packaged {ipa}\nSHA-256: {digest}")


if __name__ == "__main__":
    main()
