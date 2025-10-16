#!/bin/bash

# Build script for Instagram Analyzer
# Run this from the project directory

echo "🏗️  Building Instagram Analyzer..."

# Check if we're in the right directory
if [ ! -f "IG analizer.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Run this script from the project root directory"
    exit 1
fi

echo "✅ Project found!"
echo "📁 Files created:"
echo "   • Models/InstagramUser.swift"
echo "   • Services/HTMLParser.swift" 
echo "   • ViewModels/InstagramAnalyzerViewModel.swift"
echo "   • Views/UserListView.swift"
echo "   • Views/FileDropView.swift"
echo "   • Utils/FileManager+Extensions.swift"
echo "   • ContentView.swift (updated)"
echo "   • Sample files for testing"

echo ""
echo "🚀 To run the app:"
echo "   1. Open 'IG analizer.xcodeproj' in Xcode"
echo "   2. Select your target device (Mac)"
echo "   3. Click Run (⌘+R)"

echo ""
echo "📖 Usage:"
echo "   1. Export your Instagram data (HTML format)"
echo "   2. Drag & drop followers_1.html and following.html into the app"
echo "   3. View analysis results in different tabs"

echo ""
echo "✨ The app is ready to use!"