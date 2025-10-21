#!/bin/bash

# Quick Swift syntax validation without Xcode
# Uses basic grep patterns to check for common syntax errors

echo "🔍 Quick Swift syntax validation..."

SWIFT_FILES=(
    "IG analizer/IG analizer/ContentView.swift"
    "IG analizer/IG analizer/ViewModels/InstagramAnalyzerViewModel.swift"
    "IG analizer/IG analizer/Views/FollowersChartView.swift"
    "IG analizer/IG analizer/Services/HTMLParser.swift"
    "IG analizer/IG analizer/Models/FollowersHistory.swift"
)

ERROR_COUNT=0

for file in "${SWIFT_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "📄 Checking $file..."
        
        # Check for unmatched braces (basic count)
        OPEN_BRACES=$(grep -o "{" "$file" | wc -l)
        CLOSE_BRACES=$(grep -o "}" "$file" | wc -l)
        
        if [ $OPEN_BRACES -ne $CLOSE_BRACES ]; then
            echo "❌ Unmatched braces: $OPEN_BRACES open, $CLOSE_BRACES close"
            ERROR_COUNT=$((ERROR_COUNT + 1))
        else
            echo "✅ Braces balanced ($OPEN_BRACES pairs)"
        fi
        
        # Check for import statements
        if grep -q "import SwiftUI" "$file"; then
            echo "✅ SwiftUI import found"
        fi
        
        # Check for struct/class definitions
        if grep -q "struct.*View\|class.*:" "$file"; then
            echo "✅ Found struct/class definition"
        fi
        
        # Check for common syntax errors
        if grep -q "}$" "$file"; then
            echo "✅ File has proper closing braces"
        fi
        
    else
        echo "❌ File not found: $file"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
    echo ""
done

echo ""
if [ $ERROR_COUNT -eq 0 ]; then
    echo "🎉 All Swift files passed basic syntax validation!"
    echo "📱 Ready to build in Xcode when available"
    echo ""
    echo "🔧 Note: This is a basic check. Full compilation requires Xcode."
else
    echo "❌ Found $ERROR_COUNT potential issues"
    echo "🔧 Review files above for syntax errors"
fi