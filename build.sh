#!/usr/bin/env bash
#
# Builds Kana.app — a double-clickable macOS bundle — from the Swift package.
#
#   ./build.sh              build only
#   ./build.sh --run        build, then open the app
#   CONFIG=debug ./build.sh debug build
#   SWIFT_FLAGS="--arch arm64 --arch x86_64" ./build.sh   universal binary
#
set -euo pipefail
cd "$(dirname "$0")"

CONFIG="${CONFIG:-release}"
APP_NAME="Kana"
BUNDLE="${APP_NAME}.app"
SWIFT_FLAGS="${SWIFT_FLAGS:-}"

echo "▸ Building ${APP_NAME} (${CONFIG})…"
# shellcheck disable=SC2086
swift build -c "${CONFIG}" ${SWIFT_FLAGS}
# shellcheck disable=SC2086
BIN_PATH="$(swift build -c "${CONFIG}" ${SWIFT_FLAGS} --show-bin-path)"

if [[ ! -x "${BIN_PATH}/${APP_NAME}" ]]; then
    echo "✗ build produced no ${APP_NAME} binary at ${BIN_PATH}" >&2
    exit 1
fi

rm -rf "${BUNDLE}"
mkdir -p "${BUNDLE}/Contents/MacOS" "${BUNDLE}/Contents/Resources"
cp "${BIN_PATH}/${APP_NAME}" "${BUNDLE}/Contents/MacOS/${APP_NAME}"

# The bundle icon. macOS renders it in every appearance itself, so the app must never swap it at
# runtime: an icon that changed when you opened the app would be a bug. See Icon/make-icon.sh.
if [[ -f Icon/AppIcon.icns ]]; then
    cp Icon/AppIcon.icns "${BUNDLE}/Contents/Resources/"
else
    echo "  (no app icon — run Icon/make-icon.sh; Finder will show the generic icon)" >&2
fi

cat > "${BUNDLE}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key><string>Kana</string>
    <key>CFBundleExecutable</key><string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key><string>local.kana.trainer</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.education</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
PLIST

if ! codesign --force --sign - "${BUNDLE}" 2>/dev/null; then
    echo "  (ad-hoc codesign skipped — the app still runs locally)"
fi

echo "▸ Built ${BUNDLE}"

if [[ "${1:-}" == "--run" ]]; then
    open "${BUNDLE}"
fi
