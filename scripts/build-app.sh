#!/usr/bin/env bash
# Builds and assembles a complete, signed KUME.app at build/Release/KUME.app:
#   Contents/MacOS/KUME                      input method
#   Contents/Helpers/kume                    CLI (+ its resource bundle)
#   Contents/Applications/KUME Settings.app  settings
#   Contents/Frameworks/librime + rime-plugins, Contents/SharedSupport
# Used by install-dev.sh and package.sh. Signs ad-hoc unless KUME_SIGN_IDENTITY is set.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${CONFIG:-Release}"
DERIVED="$ROOT/build/DerivedData"
OUT="$ROOT/build/Release"
IDENTITY="${KUME_SIGN_IDENTITY:--}"

cd "$ROOT"
[[ -d Packages/KUMEKit/Frameworks/CRime.xcframework ]] || bash scripts/fetch-librime.sh
[[ -f build/SharedSupport/default.yaml ]] || bash scripts/fetch-dicts.sh
# KUME's own data changes more often than the dictionaries: always refresh it.
ditto SharedSupport build/SharedSupport
# Refresh public metadata even when reusing an older dictionary build cache.
/usr/bin/python3 scripts/dictionary-metadata.py --shared-dir build/SharedSupport
command -v xcodegen >/dev/null || { echo "xcodegen is required: brew install xcodegen" >&2; exit 1; }
xcodegen generate --quiet

echo "==> building apps ($CONFIG)"
xcodebuild -project KUME.xcodeproj -scheme KUME -configuration "$CONFIG" -derivedDataPath "$DERIVED" \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="$IDENTITY" CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO build -quiet
BUILT="$DERIVED/Build/Products/$CONFIG"

echo "==> building CLI"
swift build --package-path Packages/KUMEKit -c release --product kume >/dev/null
CLI_DIR="$(swift build --package-path Packages/KUMEKit -c release --show-bin-path)"

rm -rf "$OUT" && mkdir -p "$OUT"
APP="$OUT/KUME.app"
ditto "$BUILT/KUME.app" "$APP"
# Not Contents/MacOS: the file system is case-insensitive and "kume" would replace "KUME".
mkdir -p "$APP/Contents/Helpers" "$APP/Contents/Applications"
cp "$CLI_DIR/kume" "$APP/Contents/Helpers/kume"
ditto "$CLI_DIR/KUMEKit_KUMECore.bundle" "$APP/Contents/Helpers/KUMEKit_KUMECore.bundle"
install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP/Contents/Helpers/kume" 2>/dev/null || true
ditto "$BUILT/KUME Settings.app" "$APP/Contents/Applications/KUME Settings.app"

# Keep CFBundleShortVersionString numeric, but retain the full SemVer for updates.
# This only modifies staging bundles, before signing; project/CLI versions stay unchanged.
if [[ -n "${KUME_RELEASE_VERSION:-}" ]]; then
  for bundle in "$APP" "$APP/Contents/Applications/KUME Settings.app"; do
    plutil -replace KUMEReleaseVersion -string "$KUME_RELEASE_VERSION" "$bundle/Contents/Info.plist"
  done
fi

# Local builds are signed ad-hoc by default. Set KUME_SIGN_IDENTITY to a certificate
# hash to use a real identity — but make sure it is not revoked: macOS treats code
# signed with a revoked certificate as malware (kills it and moves the app to Trash).
echo "==> signing with: $IDENTITY"
TIMESTAMP=--timestamp
[[ "$IDENTITY" == "-" ]] && TIMESTAMP=--timestamp=none
# Development builds tolerate an unreachable timestamp service; release packaging sets
# KUME_REQUIRE_TIMESTAMP=1 (notarization needs secure timestamps).
sign() {
  codesign --force --options runtime "$TIMESTAMP" --sign "$IDENTITY" "$@" 2>/dev/null && return 0
  [[ "${KUME_REQUIRE_TIMESTAMP:-0}" == 1 ]] && { echo "timestamp service unavailable" >&2; return 1; }
  codesign --force --options runtime --timestamp=none --sign "$IDENTITY" "$@"
}
for lib in "$APP"/Contents/Frameworks/librime.1.dylib "$APP"/Contents/Frameworks/rime-plugins/*.dylib; do sign "$lib"; done
sign "$APP/Contents/Helpers/KUMEKit_KUMECore.bundle"
sign --entitlements Apps/KUME/KUME.entitlements "$APP/Contents/Helpers/kume"
sign --entitlements Apps/KUMESettings/KUMESettings.entitlements "$APP/Contents/Applications/KUME Settings.app"
sign --entitlements Apps/KUME/KUME.entitlements "$APP"
codesign --verify --deep --strict "$APP"
echo "==> built $APP"
