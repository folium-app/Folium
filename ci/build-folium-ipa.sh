#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p build
RUN="$(mktemp -d "$ROOT/build/diagnostic.XXXXXX")"
LOGS="$RUN/logs"
mkdir -p "$LOGS" "$RUN/artifacts"
exec > >(tee "$LOGS/setup.log") 2>&1
echo "Build directory: $RUN"
if [[ "$(uname -s)" != Darwin ]]; then
    echo "Xcode compilation requires macOS. Run the Folium diagnostic IPA GitHub workflow."
    exit 1
fi
for tool in xcodebuild xcrun python3 ditto codesign; do
    command -v "$tool" >/dev/null
done
python3 -c 'import sys; assert sys.version_info >= (3, 12), "Python 3.12+ required"'
{
    date -u
    sw_vers
    uname -a
    echo "Runner: ${ImageOS:-unknown} ${ImageVersion:-unknown}"
    xcode-select -p
    xcodebuild -version
    xcrun swift --version
    xcrun --sdk iphoneos --show-sdk-version
    df -h .
    git rev-parse HEAD
    git submodule status --recursive
} | tee "$LOGS/toolchain.txt"
cp ci/headers.lock.json "$LOGS/headers.lock.json"
LOCK="Folium.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
cp "$LOCK" "$LOGS/Package.resolved"
git diff --binary HEAD > "$LOGS/source.patch"
git status --short > "$LOGS/source-status.txt"
python3 ci/preflight.py --output "$LOGS/source-manifest.json"
python3 ci/fetch-headers.py

COMMON=(
    -project Folium.xcodeproj
    -scheme Folium
    -configuration Release
    -sdk iphoneos
    -destination 'generic/platform=iOS'
    -derivedDataPath "$RUN/DerivedData"
    -clonedSourcePackagesDirPath "$RUN/SourcePackages"
    -onlyUsePackageVersionsFromResolvedFile
    -disableAutomaticPackageResolution
    -xcconfig ci/iphone.xcconfig
    ARCHS=arm64
    CODE_SIGNING_ALLOWED=NO
    CODE_SIGNING_REQUIRED=NO
    CODE_SIGN_IDENTITY=
    DEVELOPMENT_TEAM=
)
xcodebuild "${COMMON[@]}" -resolvePackageDependencies 2>&1 | tee "$LOGS/package-resolution.log"
cmp "$LOCK" "$LOGS/Package.resolved"
xcodebuild -project Folium.xcodeproj -list -json \
    -clonedSourcePackagesDirPath "$RUN/SourcePackages" \
    -onlyUsePackageVersionsFromResolvedFile -disableAutomaticPackageResolution \
    > "$LOGS/project.json" 2> "$LOGS/project-list.log"
python3 -c 'import json,sys; assert "Folium" in json.load(open(sys.argv[1]))["project"]["schemes"]' "$LOGS/project.json"
python3 ci/preflight.py --artifacts "$RUN/SourcePackages/artifacts" --output "$LOGS/source-manifest.json"
xcodebuild "${COMMON[@]}" -showBuildSettings -json > "$LOGS/build-settings.json" 2> "$LOGS/build-settings.log"
xcodebuild "${COMMON[@]}" -resultBundlePath "$RUN/Folium-build.xcresult" build 2>&1 | tee "$LOGS/build.log"
cmp "$LOCK" "$LOGS/Package.resolved"
python3 ci/package-ipa.py --run "$RUN"
echo "IPA and provenance: $RUN/artifacts"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo "Built an arm64 diagnostic IPA for iPhone (test OS: iOS 27.2)."
        echo
        echo "Physical-device installation and Cytrus/JIT behavior still require testing."
    } >> "$GITHUB_STEP_SUMMARY"
fi
