# 📦 Godot iOS Framework Location

## 🎯 What Goes Here

Place your `godot_ios.xcframework` file in this directory.

```
ios/Frameworks/
└── godot_ios.xcframework/  ← Put this here!
```

---

## 🚀 How to Get the Framework

### Method 1: Export from Godot Editor (Recommended)

1. Open your Godot project in **Godot 4.4.0**
2. **Project** → **Export**
3. Add **iOS** preset
4. Click **"Export Project"**
5. Find `godot_ios.xcframework` in the exported folder
6. Copy it here:

```bash
cp -R ~/Desktop/GodotIOSExport/godot_ios.xcframework \
     /Users/tycologics/Projects/flutter_godot_widget/ios/Frameworks/
```

### Method 2: Download Pre-built (if available)

If you have a pre-built framework, copy it here.

---

## 🔧 After Adding Framework

1. **Uncomment lines in podspec:**

Edit `ios/flutter_godot_widget.podspec` (lines 22-23):

```ruby
# Change FROM:
# s.vendored_frameworks = 'Frameworks/godot_ios.xcframework'
# s.frameworks = 'Metal', 'MetalKit', 'CoreHaptics', 'AVFoundation', 'GameController'

# TO:
s.vendored_frameworks = 'Frameworks/godot_ios.xcframework'
s.frameworks = 'Metal', 'MetalKit', 'CoreHaptics', 'AVFoundation', 'GameController'
```

2. **Reinstall pods:**

```bash
cd example/ios
pod deintegrate
pod install
```

3. **Rebuild:**

```bash
open Runner.xcworkspace
# Product → Build (⌘B)
# Product → Run (⌘R)
```

---

## ✅ Verification

After adding the framework, this directory should look like:

```
ios/Frameworks/
├── README.md (this file)
└── godot_ios.xcframework/
    ├── Info.plist
    ├── ios-arm64/
    │   └── godot_ios.framework/
    ├── ios-arm64_x86_64-simulator/
    │   └── godot_ios.framework/
    └── ...
```

---

## 📏 Expected Size

The framework is large (~200-300 MB). This is normal for game engines.

---

## 🆘 Issues?

- **Framework not found:** Check path is exactly `ios/Frameworks/godot_ios.xcframework`
- **Pod install fails:** Ensure lines are uncommented in podspec
- **Build errors:** Clean build folder and rebuild

See `COMPLETE_GODOT_FRAMEWORK.md` for detailed help.

---

**Once you add the framework here, the integration will be complete!** 🎉

