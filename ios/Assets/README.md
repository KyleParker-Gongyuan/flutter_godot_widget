# Godot Assets for iOS

This directory contains Godot project files that will be bundled with the iOS app.

## Contents

These files are automatically copied from `example/android/app/src/main/assets/` using the `copy_godot_assets.sh` script.

- **project.godot**: Main Godot project configuration
- **gameloader.tscn**: Main scene file
- **xamp.gd**: Main communication script with Flutter
- **underlyingdatasender.gd**: Data handling utilities
- **addons/**: Godot plugins directory
- Other Godot resources (.svg, .gd, .tscn, etc.)

## Updating Assets

To update these assets after modifying your Godot project:

```bash
cd ../
./copy_godot_assets.sh
```

## Usage

These assets are loaded by the Godot engine at runtime through the `GodotView` class. The path is automatically resolved from the plugin bundle.

## Note

Keep these files in sync with your Android version for cross-platform consistency.

