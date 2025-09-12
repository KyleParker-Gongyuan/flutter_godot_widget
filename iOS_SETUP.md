# iOS Setup Instructions

## Automatic Dependencies
The plugin now automatically includes SwiftGodot via CocoaPods. No manual XCFramework installation required.

## Adding .pck Files to iOS Bundle

### Method 1: Using Xcode (Recommended)
1. Open your iOS project in Xcode: `example/ios/Runner.xcworkspace`
2. Right-click on "Runner" in the project navigator
3. Select "Add Files to Runner..."
4. Navigate to `example/ios/Runner/Assets/`
5. Select your `.pck` file(s) (e.g., `game.pck`)
6. Make sure "Copy items if needed" is checked
7. Make sure "Add to target: Runner" is checked
8. Click "Add"

### Method 2: Drag and Drop
1. Open Xcode project: `example/ios/Runner.xcworkspace`
2. In Finder, navigate to `example/ios/Runner/Assets/`
3. Drag the `.pck` file from Finder into the Xcode project navigator under "Runner"
4. Choose "Copy items if needed" and add to "Runner" target

### Verify Bundle Resources
1. In Xcode, select the "Runner" target
2. Go to "Build Phases" tab
3. Expand "Copy Bundle Resources"
4. Verify your `.pck` file is listed there

## File Organization

### Android
- Place `.pck` files in: `android/app/src/main/assets/`

### iOS  
- Place `.pck` files in: `example/ios/Runner/Assets/`
- Add them to Xcode project as described above

## Runtime .pck Switching

```dart
// Set the .pck file name to use (doesn't reload immediately)
await flutterGodotWidget.setPckName("mygame.pck");

// Reload Godot with the specified .pck file
await flutterGodotWidget.reloadGodot(pckName: "mygame.pck");

// Or reload with previously set .pck name
await flutterGodotWidget.reloadGodot();
```

## Important Notes

1. **Default .pck name**: The plugin looks for `game.pck` by default
2. **Bundle Resources**: .pck files must be added to "Copy Bundle Resources" in Xcode
3. **No Rebuilding**: Changing .pck files doesn't require rebuilding native code
4. **SwiftGodot**: Automatically included via CocoaPods - no manual framework installation needed


