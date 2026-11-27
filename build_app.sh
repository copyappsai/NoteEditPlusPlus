#!/bin/bash
set -e

echo "=== Building NoteEdit++ for macOS ==="
swift build -c release

BIN_PATH="$(swift build -c release --show-bin-path)/NoteEditPlusPlus"
APP_BUNDLE="NoteEdit++.app"

echo "=== Creating macOS App Bundle ($APP_BUNDLE) ==="
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BIN_PATH" "$APP_BUNDLE/Contents/MacOS/NoteEditPlusPlus"
chmod +x "$APP_BUNDLE/Contents/MacOS/NoteEditPlusPlus"
cp "Info.plist" "$APP_BUNDLE/Contents/Info.plist"

if [ -f "AppIcon.icns" ]; then
    cp "AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# Apply Apple App Sandbox, Hardened Runtime and Code Signing
echo "=== Signing App Bundle with Apple Hardened Runtime & Entitlements ==="
ENTITLEMENTS="NoteEditPlusPlus.entitlements"

if [ -f "$ENTITLEMENTS" ]; then
    codesign --force --options runtime --deep --sign - --entitlements "$ENTITLEMENTS" "$APP_BUNDLE"
    echo "=== Code Signature Verification ==="
    codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
    echo "=== Embedded Entitlements ==="
    codesign -d --entitlements :- "$APP_BUNDLE"
else
    echo "Warning: $ENTITLEMENTS not found, signing without entitlements."
    codesign --force --options runtime --deep --sign - "$APP_BUNDLE"
fi

echo "=== NoteEdit++.app successfully built and signed! ==="
echo "You can launch it with: open 'NoteEdit++.app'"
