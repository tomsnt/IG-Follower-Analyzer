#!/bin/bash

# Test build script per Instagram Analyzer
# Verifica che il codice compili correttamente

set -e  # Exit on any error

PROJECT_NAME="IG analizer"
SCHEME_NAME="IG analizer" 
CONFIGURATION="Debug"

echo "🔧 Testing build for Instagram Analyzer..."

# Navigate to project directory
cd "/Users/tommy/Documents/IG-Follower-Analyzer/IG analizer"

# Clean build directory
echo "🧹 Cleaning build directory..."
rm -rf build/

# Test build (without archive)
echo "📦 Testing compilation..."
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration "$CONFIGURATION" \
           -destination "platform=macOS" \
           clean build

if [ $? -eq 0 ]; then
    echo "✅ Build successful! All new features compile correctly."
    echo ""
    echo "📋 New features added:"
    echo "   📈 FollowersChartView - Real-time growth chart"
    echo "   📊 FollowersHistory - Data tracking over time" 
    echo "   📅 Date parsing - Chrome extension timestamps"
    echo "   🎯 Auto-snapshot - Saves data after each analysis"
    echo ""
    echo "🎉 Ready for distribution!"
else
    echo "❌ Build failed! Check errors above."
    exit 1
fi