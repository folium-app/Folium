# Folium diagnostic IPA setup — iPhone, iOS 27.2

Prepared on 2026-11-12 in `C:\Users\Dragon\Documents\Projects\Folium-IPA\Folium`.

This is a local source and CI setup. A macOS build, downloaded IPA, Sideloadly installation, and physical iPhone test have not been performed.

## Prepared locally

- Upstream: https://github.com/folium-app/Folium
- Baseline: `4dbc9e8e8450eef350109fe0e816554dcfaee7e5`.
- Branch: `codex/folium-diagnostic-ipa`.
- All ten core submodules are initialized recursively at the committed revisions. Cytrus is `d421219acdcb0ad5494ab68777a52a87465fd8ae`.
- The five Swift package revisions in the upstream `Package.resolved` are preserved. Xcode resolves their sources and checksum-protected binary downloads on macOS.
- All ten tracked XCFrameworks have an arm64 iOS device slice with a real binary. On Windows, this verifies metadata, file presence, and SHA-256; the runner additionally checks with `file`, `lipo`, and `otool`.
- Vulkan C headers, Vulkan-Hpp, glslang headers, and VMA sources are downloaded under ignored `Dependencies/CIHeaders/`. Commit URLs and archive SHA-256 values are in `ci/headers.lock.json`.
- Cytrus's Debug and Release system header search paths use those repository-relative directories and preserve inherited paths.
- `ci/iphone.xcconfig` selects iPhone and disables developer signing for the diagnostic build. It keeps upstream's minimum OS version; **iOS 27.2 is the physical test OS**, not an assumed installed SDK version.
- `.github/workflows/folium-ipa.yml` supplies a manual macOS build, IPA/provenance artifact, and separate logs on success or failure.

The upstream README contains an app description but no build instructions. [The adapted plan](docs/folium-plan.md) supplies the build approach. The header versions match the upstream Vulkan SDK search version where possible; their compatibility with the prebuilt glslang libraries still needs the first clean macOS build.

Local verification passed: source/XCFramework preflight, all four archive checksums and header-tree revalidation, accessibility of all five locked package commits, Python compilation, Bash syntax, Git whitespace checks, and actionlint 1.7.12. Actionlint was configured to recognize the newly documented `xcode-27` label; ShellCheck was unavailable. Both build and packaging commands were also checked to reject Windows execution without producing an IPA.

## Validate or refresh on Windows

Run from this repository in PowerShell, with Git and Python 3.12 or newer installed:

```powershell
git submodule update --init --recursive
python ci/preflight.py
python ci/fetch-headers.py
git submodule status --recursive
```

The fetcher verifies archive checksums before extraction. Rerunning it also checks existing header contents against the verified sources and refuses to replace modified files. `build/source-manifest.json` records source, core, package, and tracked binary revisions/checksums. `build/` and downloaded header sources are ignored by Git.

## Publish the setup to your fork and run the build

The local `origin` currently points to upstream. No fork has been created, no changes have been committed or pushed, and no remote workflow has been dispatched by this setup.

1. Create or use your own [Folium fork](https://github.com/folium-app/Folium/fork).
2. Configure this checkout with the upstream fetch remote and your fork as `origin`. Substitute your actual account in the URL:

   ```powershell
   git remote rename origin upstream
   git remote add origin https://github.com/YOUR-ACCOUNT/Folium.git
   git add .gitattributes .gitignore README.md SETUP.md docs ci .github Folium.xcodeproj/project.pbxproj
   git commit -m "Set up diagnostic iPhone IPA build"
   git push -u origin codex/folium-diagnostic-ipa
   ```

3. Merge the setup branch into the fork's default branch through a pull request. GitHub requires the dispatchable workflow to exist on the default branch before it appears for manual runs.
4. In the fork's **Actions** tab, enable workflows if prompted, select **Folium diagnostic IPA**, choose the diagnostic branch, and select **Run workflow**.
5. Download `Folium-iPhone-iOS-27.2-<commit>` after a successful run. It contains the `.ipa`, `.sha256`, `build-manifest.json`, package/header locks, toolchain information, and source patch/status. Failed runs retain a separate `Folium-logs-...` artifact when logs are available.

The workflow uses the documented [`xcode-27` arm64 runner](https://docs.github.com/en/actions/reference/runners/github-hosted-runners). Its installed Xcode and iPhoneOS SDK versions are recorded in each run; they are not silently pinned by the label. Checkout and upload actions are pinned to release commit SHAs. The checked-in dependencies contain actual binaries, so LFS is not enabled.

On a Mac with Xcode and Python 3.12+, the same path is:

```bash
bash ci/build-folium-ipa.sh
```

Every invocation creates fresh `build/diagnostic.XXXXXX/DerivedData` and staging directories. A failed build stops before packaging. The packager reads `TARGET_BUILD_DIR` and `WRAPPER_NAME` from resolved settings, validates arm64/iOS Mach-O binaries and runtime dependencies, signs the bundle ad hoc, and packages `Payload/Folium.app`. Sideloadly supplies the final provisioning and device-installable signature locally.

## Install and test on iPhone running iOS 27.2

1. Back up existing Folium app data. If retaining another installation, choose a separate bundle identifier in Sideloadly and record it.
2. Check the downloaded IPA against its `.sha256` file, then use Sideloadly on Windows to sign and install it on the connected iPhone. Follow the device trust/Developer Mode prompts required by that installation.
3. Check launch, permissions, library UI, and import with personally supplied homebrew or a game and system files you are entitled to use. Keep these files outside the repository and workflow artifacts.
4. In Cytrus settings, first disable **CPU JIT** (`cytrus.cpuJIT`) and **Shader JIT** (`cytrus.shaderJIT`). Confirm that settings reach the core before launching a title. Assess the fast-interpreter option separately if needed; it is not proof of usable JIT.
5. Check graphics, both 3DS screens, touch/controller input, audio, save/load, and relaunch after terminating the app. Collect crash/emulator logs for failures.
6. Investigate JIT separately after the interpreter baseline runs. Activation and performance on iOS 27.2 are unverified; no Henge entitlements, helper, RAM changes, or JIT patches are included.

The local setup is ready for its first macOS build. Successful compilation, dependency ABI compatibility, installation, and physical-device behavior remain to be established. The plan's final completion criterion still requires a working 3DS test on the physical iPhone.
