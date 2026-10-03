#!/bin/bash
set -e

# ==============================================================================
# Foldero Build & Packaging Script
# ==============================================================================

echo "🚀 Building Foldero (Release)..."

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

BUILD_DIR="./build"
DIST_DIR="./dist"
APP_NAME="FolderStudio"
RELEASE_NAME="Foldero"

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$DIST_DIR"

# 1. Build macOS Release App
xcodebuild \
  -project FolderStudio.xcodeproj \
  -scheme FolderStudio \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  clean build

APP_PATH="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"

if [ ! -d "$APP_PATH" ]; then
  echo "❌ Error: App bundle not found at $APP_PATH"
  exit 1
fi

echo "📦 Packaging distribution files..."

# Copy .app to dist
cp -R "$APP_PATH" "$DIST_DIR/$RELEASE_NAME.app"

# Create ZIP archive
cd "$DIST_DIR"
zip -r -y "$RELEASE_NAME-macOS.zip" "$RELEASE_NAME.app" > /dev/null
cd "$PROJECT_DIR"

# Create DMG disk image
DMG_STAGING="./dmg_staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
cp -R "$APP_PATH" "$DMG_STAGING/$RELEASE_NAME.app"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create \
  -volname "$RELEASE_NAME" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$DIST_DIR/$RELEASE_NAME-macOS.dmg" > /dev/null

rm -rf "$DMG_STAGING"

echo "✅ Build completed successfully!"
echo "📁 Artifacts created in $DIST_DIR:"
ls -lh "$DIST_DIR"

# Reveal in Finder
if [ -d "$DIST_DIR" ]; then
  open "$DIST_DIR"
fi
