# Adding SwiftGodot to the iOS Plugin

## Quick Steps

### 1. Open Xcode Workspace

```bash
open /Users/tycologics/Projects/flutter_godot_widget/example/ios/Runner.xcworkspace
```

### 2. Add SwiftGodot Package

1. In Xcode, click **File** → **Add Package Dependencies...**

2. In the search field, paste:
   ```
   https://github.com/migueldeicaza/SwiftGodot
   ```

3. Click **Add Package**

4. Select **SwiftGodot** library (check the box)

5. Make sure it's added to the **flutter_godot_widget** target

6. Click **Add Package**

### 3. Build and Run

1. Select your target device/simulator

2. Press **⌘R** to build and run

3. SwiftGodot will download and integrate automatically

4. The app should now render Godot!

---

## What SwiftGodot Does

SwiftGodot provides:
- ✅ Complete Godot runtime for iOS
- ✅ Swift bindings to Godot API
- ✅ Automatic project loading
- ✅ View integration
- ✅ No need to export from Godot Editor

---

## The Code Changes Made

### Updated `GodotView.swift`:

```swift
import SwiftGodot

// In setupGodotView():
runGodot(args: [
    "--path", projectPath,
    "--rendering-driver", "metal"
]) { scene in
    print("Scene loaded!")
}

if let godotView = GodotRuntime.getView() {
    containerView.addSubview(godotView)
}
```

This:
1. Initializes Godot engine
2. Loads your project from Assets/
3. Gets the rendering view
4. Adds it to Flutter container

---

## Expected Result

After adding SwiftGodot:

✅ Godot engine starts automatically  
✅ Your project.godot loads from Assets  
✅ Game renders in the Flutter view  
✅ All communication channels work  
✅ No export needed!  

---

## Troubleshooting

### "Cannot find 'SwiftGodot' in scope"

- Make sure you added the package to **flutter_godot_widget** target, not just Runner
- Clean build folder: **Product** → **Clean Build Folder** (⇧⌘K)
- Rebuild

### SwiftGodot download fails

- Check internet connection
- Try again - GitHub sometimes has rate limits
- Or download manually and add as local package

### Project not loading

- Check that Assets/ folder has project.godot
- Verify path in logs: Look for "Project path: ..."
- Make sure assets are in resource bundle

---

## Alternative: Manual SwiftGodot

If adding via Xcode doesn't work:

1. Clone SwiftGodot:
   ```bash
   cd ~/Desktop
   git clone https://github.com/migueldeicaza/SwiftGodot.git
   ```

2. In Xcode: **File** → **Add Package Dependencies** → **Add Local...**

3. Select the cloned SwiftGodot folder

4. Add to flutter_godot_widget target

---

## Clean Build (If Needed)

```bash
cd /Users/tycologics/Projects/flutter_godot_widget/example
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
open Runner.xcworkspace
```

Then add SwiftGodot and rebuild.

---

Ready to add it!

