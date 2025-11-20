#!/bin/bash

# Script to copy Godot assets from Android example to iOS plugin bundle
# This script should be run whenever Godot project files are updated

set -e

echo "=========================================="
echo "Copying Godot Assets to iOS Bundle"
echo "=========================================="

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Source and destination paths
ANDROID_ASSETS="$PROJECT_ROOT/example/android/app/src/main/assets"
IOS_ASSETS="$SCRIPT_DIR/Assets"

# Check if source exists
if [ ! -d "$ANDROID_ASSETS" ]; then
    echo "ERROR: Android assets directory not found at: $ANDROID_ASSETS"
    exit 1
fi

# Create iOS assets directory if it doesn't exist
mkdir -p "$IOS_ASSETS"

echo "Source: $ANDROID_ASSETS"
echo "Destination: $IOS_ASSETS"
echo ""

# Copy all Godot project files
echo "Copying project.godot..."
cp "$ANDROID_ASSETS/project.godot" "$IOS_ASSETS/" 2>/dev/null || echo "Warning: project.godot not found"

echo "Copying .tscn files..."
cp "$ANDROID_ASSETS"/*.tscn "$IOS_ASSETS/" 2>/dev/null || echo "Warning: No .tscn files found"

echo "Copying .gd files..."
cp "$ANDROID_ASSETS"/*.gd "$IOS_ASSETS/" 2>/dev/null || echo "Warning: No .gd files found"

echo "Copying .gd.uid files..."
cp "$ANDROID_ASSETS"/*.uid "$IOS_ASSETS/" 2>/dev/null || echo "Warning: No .uid files found"

echo "Copying .svg files..."
cp "$ANDROID_ASSETS"/*.svg "$IOS_ASSETS/" 2>/dev/null || echo "Warning: No .svg files found"

echo "Copying .svg.import files..."
cp "$ANDROID_ASSETS"/*.import "$IOS_ASSETS/" 2>/dev/null || echo "Warning: No .import files found"

echo "Copying .cfg files..."
cp "$ANDROID_ASSETS"/*.cfg "$IOS_ASSETS/" 2>/dev/null || echo "Warning: No .cfg files found"

# Copy addons directory if it exists
if [ -d "$ANDROID_ASSETS/addons" ]; then
    echo "Copying addons directory..."
    cp -R "$ANDROID_ASSETS/addons" "$IOS_ASSETS/"
fi

# Copy android directory if it exists (for Godot Android export settings)
if [ -d "$ANDROID_ASSETS/android" ]; then
    echo "Copying android directory..."
    cp -R "$ANDROID_ASSETS/android" "$IOS_ASSETS/"
fi

echo ""
echo "=========================================="
echo "Asset copying completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Run 'cd example/ios && pod install' to update iOS dependencies"
echo "2. Open example/ios/Runner.xcworkspace in Xcode"
echo "3. Build and run the iOS app"
echo ""

