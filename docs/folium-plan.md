# Folium IPA build plan from Windows

Inspected: 2026-11-12. Upstream: [folium-app/Folium](https://github.com/folium-app/Folium).

## Local setup status — 2026-11-12

Target device: **iPhone running iOS 27.2**.

The source is cloned in `C:\Users\Dragon\Documents\Projects\Folium-IPA\Folium` on `codex/folium-diagnostic-ipa` at the inspected baseline. All ten pinned submodules are initialized. The manual IPA workflow, header locks/fetcher, repository-relative Cytrus paths, source/binary preflight, and packaging scripts are prepared locally. See `Folium/SETUP.md` in this workspace (or `SETUP.md` from the repository root) for verified checks and exact next steps.

This status records local preparation only. Fork creation, commit/push, remote build, package resolution with Xcode, IPA production, Sideloadly installation, and physical-device testing are still pending. The original steps below remain the full build-and-test plan.

## Feasibility

**Yes: the method used for Henge is a practical starting point for Folium.** Windows controls the repository and workflow, GitHub's hosted macOS runner uses Xcode to build the iOS app, and Sideloadly signs and installs the downloaded IPA on the iPhone. No personally owned Mac, local macOS VM, or additional Windows Xcode/SDK download is needed.

This is a feasibility assessment from source inspection, not a successful Folium build. The existing Windows LLVM/SDK setup remains useful for isolated native experiments, but it does not currently replace Folium's complete Xcode, Apple Swift, resource compilation, and Swift Package Manager build. Splitting compilation across Windows and macOS would add compatibility work before the first working IPA.

## What the repository already provides

| Finding | Consequence for the build |
| --- | --- |
| Inspected Folium commit: `4dbc9e8e8450eef350109fe0e816554dcfaee7e5` | Use this as the reproducible starting point. |
| Shared `Folium` scheme in `Folium.xcodeproj` | An existing command-line Xcode build entry point is available. |
| Modern project format, Xcode upgrade marker `2700`, Swift 6 settings, and packages requiring Swift tools 6.2 | Start with the same `xcode-27` runner used for Henge and record its exact Xcode version. |
| Swift app code using UIKit/MetalKit, plus native static-library core targets | Build the existing project rather than recreate the UI or native target graph. |
| Ten core submodules | Checkout all pinned submodules for the initial full app build. |
| **Cytrus is the 3DS core**, based on an Azahar/Citra port | Diagnose 3DS compilation and runtime behavior in Cytrus. Mandarine is the PlayStation 1 core. |
| Tracked Boost, FFmpeg, and MoltenVK XCFrameworks, including device slices | Reuse them after checking architecture, linkage, and packaging. |
| Committed SwiftPM `Package.resolved` | Preserve its revisions instead of updating all dependencies. |
| Cytrus header paths reference the author's home directory and Vulkan SDK | Resolve these paths explicitly before expecting a clean hosted build. |

Sources: [project settings](https://github.com/folium-app/Folium/blob/4dbc9e8e8450eef350109fe0e816554dcfaee7e5/Folium.xcodeproj/project.pbxproj), [shared scheme](https://github.com/folium-app/Folium/blob/4dbc9e8e8450eef350109fe0e816554dcfaee7e5/Folium.xcodeproj/xcshareddata/xcschemes/Folium.xcscheme), [submodules](https://github.com/folium-app/Folium/blob/4dbc9e8e8450eef350109fe0e816554dcfaee7e5/.gitmodules), [Cytrus](https://github.com/folium-app/Cytrus/blob/d421219acdcb0ad5494ab68777a52a87465fd8ae/README.md), [Mandarine](https://github.com/folium-app/Mandarine/blob/c04202ece9c218525c7aa93bb5287f473218784e/README.md).

## Step 1 — Create an isolated Folium fork and checkout

1. Fork `folium-app/Folium` under the user's GitHub account, if a fork does not already exist.
2. Clone it into a sibling directory such as `C:\Users\Dragon\Documents\Projects\Folium-IPA\Folium`; keep the Henge checkout and test data separate.
3. Create a branch named `codex/folium-diagnostic-ipa` from the inspected commit, or explicitly record a newer baseline if upstream has changed.
4. Run `git submodule update --init --recursive` without `--remote`. Record `git rev-parse HEAD` and `git submodule status --recursive`.
5. Confirm Cytrus resolves to `d421219acdcb0ad5494ab68777a52a87465fd8ae` for this baseline. The inspected Cytrus and Mandarine commits contain no further gitlink dependencies.

Deliverable: a reproducible source checkout. A missing or inaccessible pinned dependency is a blocker to resolve, not a reason to silently substitute its latest version.

## Step 2 — Add a manual GitHub Actions build

Create `.github/workflows/folium-ipa.yml` with:

- `workflow_dispatch` as the initial trigger, `contents: read`, and concurrency cancellation per branch.
- `runs-on: xcode-27`, initially matching Henge. GitHub currently documents this label; verify its availability when implementing.
- Checkout with recursive submodules and `persist-credentials: false`. Enable Git LFS only if a dependency actually requires it.
- A script such as `ci/build-folium-ipa.sh` for dependency checks, compilation, validation, and packaging.
- Separate artifact uploads for the IPA/provenance on success and build logs on every outcome.

Ensure the dispatchable workflow exists on the fork's default branch before attempting a manual run on the diagnostic branch. Reuse the action versions that worked for Henge, then pin them to reviewed commit SHAs.

Record the runner image, `xcodebuild -version`, `xcrun swift --version`, `xcrun --sdk iphoneos --show-sdk-version`, disk space, and source revisions. Use the runner's installed Xcode/SDK; do not upload or reinstall the Windows SDK.

Sources: [GitHub runner labels](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [xcode-27 installed tools](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md).

## Step 3 — Validate packages and binary dependencies first

1. Confirm `xcodebuild -list -json -project Folium.xcodeproj` exposes `Folium`.
2. Resolve Swift packages using the committed lockfile and Xcode's resolved-version enforcement. Retain the resolution log and fail if the locked graph cannot be used.
3. Check the pinned AntiqueKit, zstd, SharedDependencies, PLzmaSDK, and OpenSSL revisions are fetchable.
4. Validate binary downloads through SwiftPM's checksums and inspect each required XCFramework for an `iphoneos` arm64 slice. A simulator arm64 slice is not interchangeable.
5. Inspect the tracked FFmpeg and MoltenVK binaries with `file`, `lipo`, and `otool` on the runner. Check dynamic dependency paths as well as architectures.

The inspected SharedDependencies package references release `1.0.0` binaries including Dynarmic, glslang, SDL3, OpenAL, Teakra, and other core libraries. The release lists the corresponding assets, but their download/checksum and device-link compatibility still need a real runner check. Start by reusing these binaries rather than rebuilding the entire dependency stack.

Sources: [locked package revisions](https://github.com/folium-app/Folium/blob/4dbc9e8e8450eef350109fe0e816554dcfaee7e5/Folium.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved), [SharedDependencies manifest](https://github.com/folium-app/SharedDependencies/blob/9787aa9062d8ff220f127052597e6f3ae1dcbc7a/Package.swift), [binary release](https://github.com/folium-app/SharedDependencies/releases/tag/1.0.0).

## Step 4 — Make native include paths reproducible

The Cytrus target currently searches:

```text
$(HOME)/Developer/Repositories
$(HOME)/VulkanSDK/1.4.363.0/macOS/include
$(HOME)/VulkanSDK/1.4.363.0/macOS/include/glslang
$(HOME)/VulkanSDK/1.4.363.0/macOS/include/vma
/usr/local/include
```

1. Audit the corresponding includes and identify what SwiftPM and the tracked frameworks already supply. Cytrus explicitly includes `vulkan/vulkan.hpp`.
2. Supply any remaining Vulkan C/C++ headers, glslang headers, and Vulkan Memory Allocator header from pinned compatible sources. Record versions and checksums.
3. Replace developer-specific paths with repository-relative paths or named build settings supplied by a CI `.xcconfig`. Preserve inherited search paths and scope overrides to the targets that need them.
4. Check other targets for the same assumptions and missing generated headers. Prefer small build configuration fixes over source rewrites.
5. Use host tools only for host-side generation; link iOS device libraries from the proper XCFramework slices. Do not link macOS Vulkan or Homebrew libraries into the app.

This is the clearest confirmed portability obstacle. Its exact fixes depend on the first clean runner build; installing a full Vulkan SDK may be unnecessary if pinned headers and existing iOS binaries satisfy the project.

Source: [Cytrus Vulkan include](https://github.com/folium-app/Cytrus/blob/d421219acdcb0ad5494ab68777a52a87465fd8ae/System/include/video_core/renderer_vulkan/vk_common.h).

## Step 5 — Build the existing full app for the iPhone

Use a fresh DerivedData directory and a shell script with `set -euo pipefail`. After dependency setup, the initial command shape is:

```bash
xcodebuild \
  -project Folium.xcodeproj \
  -scheme Folium \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build/DerivedData \
  -resultBundlePath build/Folium-build.xcresult \
  -onlyUsePackageVersionsFromResolvedFile \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY='' \
  DEVELOPMENT_TEAM='' \
  build
```

Apply the include-path configuration from Step 4 when needed. Capture the complete log while preserving the actual `xcodebuild` exit status. Clear the author's development team through build overrides so compilation does not require their provisioning profile.

Keep the full target graph initially: Folium imports several core modules, so deleting unrelated cores immediately could introduce more failures. Address errors in order: dependency resolution, missing headers, compile errors, linker errors, then resource/packaging errors. Only consider a separate 3DS-only variant if unrelated cores prove to be a substantial blocker; that variant requires coordinated changes to targets, imports, and app registration.

Deliverable: an arm64 device `Folium.app` containing its compiled resources and required runtime frameworks. Simulator success alone does not satisfy this step.

## Step 6 — Package a Sideloadly-ready IPA

1. Locate the app using resolved `TARGET_BUILD_DIR` and `WRAPPER_NAME`; reject missing or stale build output.
2. Inspect `Info.plist`, the executable, embedded frameworks, Swift runtime dependencies, and `otool -L` results. Reject simulator slices and unresolved non-system dylibs.
3. Reuse Henge's staging and packaging approach after adapting it to Folium's bundle structure. Do not copy Henge's entitlements, JIT helper, or RAM patches into Folium.
4. If ad-hoc signatures are needed for the packaging validation path, sign nested executable bundles before the app. Sideloadly will provide the final device-installable signature and provisioning locally.
5. Stage the app as `Payload/Folium.app` and ZIP `Payload` at the archive root into `Folium-diagnostic-<short-sha>.ipa`. Preserve bundle contents, permissions, and symlinks.
6. Validate archive contents, compute SHA-256, and upload the IPA with a build manifest, dependency revisions, package lockfile, and logs as workflow artifacts.

Use direct app packaging initially; an App Store-style `-exportArchive` signing flow is not required for this sideloading goal. Keep Apple ID credentials, signing certificates, and device pairing material off GitHub Actions.

## Step 7 — Install and test on the existing iPhone

1. Download and extract the workflow artifact on Windows, then select the contained `.ipa` in Sideloadly.
2. Preserve any existing Folium data before installing. Choose a separate test bundle identifier if testing alongside an existing installation, and record the identifier Sideloadly actually installs.
3. Install on the connected iPhone running iOS 27.2 and verify launch, permissions, library UI, and game import.
4. Import a personally supplied 3DS title or homebrew and any legitimately obtained files the core requires. Keep game/system files out of the source repository and CI artifact.
5. First test a configuration with CPU JIT and shader JIT disabled, using an interpreter configuration supported by this revision. Verify the saved settings actually reach Cytrus; do not assume defaults are safe for this test.
6. Verify graphics initialization, both screens, touch/controller input, audio, save/load, and launch after terminating the app. Collect crash and emulator logs for failures.
7. Assess JIT separately only after the interpreter baseline works. The presence of a JIT setting or Dynarmic binary does not prove usable JIT on iOS 27.2. Check the existing activation mechanism, final signing entitlements, and process state before enabling it. Do not assume Henge's helper is compatible with Folium.

Cytrus exposes CPU JIT, shader JIT, and fast-interpreter settings in source. Their existence supports this test sequence, but does not establish performance or successful execution on this iPhone.

Source: [Cytrus settings UI and mappings](https://github.com/folium-app/Folium/blob/4dbc9e8e8450eef350109fe0e816554dcfaee7e5/Folium/Enumerations/Settings/Cytrus/CytrusSettings.swift).

## Step 8 — Stabilize only after the first successful run

- Retain the working source, package, header, and toolchain versions in the build manifest.
- Add package/download caches keyed by the lockfile, dependency versions, and Xcode version after a clean build succeeds.
- Give each downloadable IPA a source revision and checksum; keep a separate log artifact on failed runs.
- Keep upstream license notices and the corresponding source/patches available with any redistributed build.
- Consider Windows-native core compilation later only if it offers a measured benefit. It is not necessary to achieve the first IPA with the hosted method.

Completion means a downloadable IPA has been built, Sideloadly has installed it, and a 3DS test has run on the physical iPhone. A green compilation job establishes only the build portion. Remaining uncertainties are reproducible native header setup, dependency binary compatibility, clean compilation of the full current target graph, and runtime/JIT behavior on iOS 27.2.
