#!/bin/bash

# Instagram Analyzer - Build Script per Distribuzione
# Questo script automatizza il processo di build e packaging dell'app

set -e  # Exit on any error

PROJECT_NAME="IG analizer"
SCHEME_NAME="IG analizer"
CONFIGURATION="Release"
ARCHIVE_PATH="build/IG-Analyzer.xcarchive"
EXPORT_PATH="build/"
APP_NAME="Instagram Analyzer"

echo "🚀 Starting build process for $APP_NAME..."

# Cleanup previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/
mkdir -p build/

# Build archive
echo "📦 Building archive..."
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration "$CONFIGURATION" \
           -archivePath "$ARCHIVE_PATH" \
           -destination "generic/platform=macOS" \
           clean archive

if [ $? -eq 0 ]; then
    echo "✅ Archive built successfully!"
else
    echo "❌ Archive build failed!"
    exit 1
fi

# Export for App Store
echo "📤 Exporting for App Store..."
xcodebuild -exportArchive \
           -archivePath "$ARCHIVE_PATH" \
           -exportPath "$EXPORT_PATH" \
           -exportOptionsPlist "ExportOptions.plist"

if [ $? -eq 0 ]; then
    echo "✅ Export completed successfully!"
    echo "📁 Files available in: $EXPORT_PATH"
    
    # List exported files
    echo "📋 Exported files:"
    ls -la "$EXPORT_PATH"
else
    echo "❌ Export failed!"
    exit 1
fi

# Create DMG for direct distribution (optional)
echo "💿 Creating DMG for direct distribution..."
if command -v create-dmg &> /dev/null; then
    create-dmg \
        --volname "$APP_NAME" \
        --volicon "IG analizer/Assets.xcassets/AppIcon.appiconset/" \
        --window-pos 200 120 \
        --window-size 600 300 \
        --icon-size 100 \
        --icon "$APP_NAME.app" 175 120 \
        --hide-extension "$APP_NAME.app" \
        --app-drop-link 425 120 \
        "build/$APP_NAME.dmg" \
        "build/$APP_NAME.app"
    
    if [ $? -eq 0 ]; then
        echo "✅ DMG created successfully!"
    else
        echo "⚠️  DMG creation failed (optional step)"
    fi
else
    echo "⚠️  create-dmg not found. Install with: npm install -g create-dmg"
fi

echo "🎉 Build process completed!"
echo "📋 Next steps:"
echo "   1. For TestFlight: Upload to App Store Connect"
echo "   2. For direct distribution: Use the DMG file"
echo "   3. For App Store: Submit for review via App Store Connect"
