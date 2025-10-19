#!/bin/bash

# Instagram Analyzer - Build Script per Distribuzione
# Questo script automatizza il processo di build per condividere l'app con amici

set -e  # Exit on any error

PROJECT_NAME="IG analizer"
SCHEME_NAME="IG analizer"
CONFIGURATION="Release"
ARCHIVE_PATH="build/IG-Analyzer.xcarchive"
EXPORT_PATH="build/"
APP_NAME="Instagram Analyzer"

echo "🚀 Building $APP_NAME for distribution..."

# Cleanup previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/
mkdir -p build/

# Build archive
echo "📦 Creating archive..."
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration "$CONFIGURATION" \
           -archivePath "$ARCHIVE_PATH" \
           -destination "generic/platform=macOS" \
           clean archive

if [ $? -eq 0 ]; then
    echo "✅ Archive created successfully!"
else
    echo "❌ Archive failed!"
    exit 1
fi

echo "🎉 Build completed!"
echo ""
echo "📋 Next steps for sharing with friends:"
echo "   🎯 TestFlight: Upload to App Store Connect"
echo "   💿 Direct: Create DMG with create-dmg tool"
echo "   🌐 Web: Convert to React/JavaScript version"
echo ""
echo "💡 See DISTRIBUTION_GUIDE.md for detailed instructions!"