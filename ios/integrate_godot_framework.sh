#!/bin/bash

# Script to integrate Godot iOS framework into the project
# Run this after copying godot_ios.xcframework to ios/Frameworks/

set -e

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║        Godot iOS Framework Integration Script                    ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Check if framework exists
FRAMEWORK_PATH="$SCRIPT_DIR/Frameworks/godot_ios.xcframework"

if [ ! -d "$FRAMEWORK_PATH" ]; then
    echo "❌ ERROR: Framework not found!"
    echo ""
    echo "Expected location: $FRAMEWORK_PATH"
    echo ""
    echo "Please:"
    echo "1. Export your Godot project for iOS"
    echo "2. Copy godot_ios.xcframework to ios/Frameworks/"
    echo "3. Run this script again"
    echo ""
    echo "See: COMPLETE_GODOT_FRAMEWORK.md for detailed instructions"
    exit 1
fi

echo "✅ Found Godot framework at: $FRAMEWORK_PATH"
echo ""

# Check framework size
FRAMEWORK_SIZE=$(du -sh "$FRAMEWORK_PATH" | awk '{print $1}')
echo "📦 Framework size: $FRAMEWORK_SIZE"
echo ""

# Update podspec
PODSPEC_PATH="$SCRIPT_DIR/flutter_godot_widget.podspec"

if grep -q "# s.vendored_frameworks" "$PODSPEC_PATH"; then
    echo "🔧 Uncommenting framework lines in podspec..."
    
    # Uncomment the framework lines
    sed -i '' 's/# s.vendored_frameworks/s.vendored_frameworks/' "$PODSPEC_PATH"
    sed -i '' 's/# s.frameworks/s.frameworks/' "$PODSPEC_PATH"
    
    echo "✅ Podspec updated"
else
    echo "✅ Podspec already configured"
fi
echo ""

# Clean and rebuild
echo "🧹 Cleaning build..."
cd "$PROJECT_ROOT/example"
flutter clean > /dev/null 2>&1
echo "✅ Flutter clean complete"
echo ""

echo "📦 Getting Flutter dependencies..."
flutter pub get
echo "✅ Dependencies updated"
echo ""

# iOS pods
echo "📱 Installing iOS pods..."
cd ios
pod deintegrate > /dev/null 2>&1 || true
pod install

if [ $? -eq 0 ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║              ✅ INTEGRATION COMPLETE! ✅                          ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🚀 Next steps:"
    echo ""
    echo "1. Open Xcode workspace:"
    echo "   open Runner.xcworkspace"
    echo ""
    echo "2. Build and run (⌘R)"
    echo ""
    echo "3. Test the app:"
    echo "   - Tap 'iOS Test' tab"
    echo "   - Tap 'Show Godot'"
    echo "   - Godot should now render!"
    echo ""
    echo "✅ Framework: Integrated"
    echo "✅ Pods: Installed"
    echo "✅ Ready: For testing"
    echo ""
else
    echo ""
    echo "❌ Pod install failed!"
    echo ""
    echo "Try manually:"
    echo "  cd example/ios"
    echo "  pod deintegrate"
    echo "  pod install"
    echo ""
    exit 1
fi

