# 🚀 Quick Start: iOS Integration

## What's Been Done For You

✅ All Swift code implemented  
✅ Communication channels configured  
✅ Platform views registered  
✅ Assets copied to iOS bundle  
✅ Full architectural parity with Android  

---

## What You Need To Do

### Step 1: Choose Your Integration Method

Pick **ONE** of these options:

#### 🟢 Option A: SwiftGodot (Easier - Recommended)

1. Add SwiftGodot to your project:

**Via CocoaPods** (Add to `ios/flutter_godot_widget.podspec`):
```ruby
s.dependency 'SwiftGodotKit', '~> 4.2.0'
```

**OR via Swift Package Manager**:
- Open `example/ios/Runner.xcworkspace`
- File → Add Packages
- URL: `https://github.com/migueldeicaza/SwiftGodot`

2. Update `ios/Classes/GodotView.swift` around line 65:

```swift
import SwiftGodot  // Add at top

// Replace setupGodotView() implementation
private func setupGodotView() {
    guard let godotInstance = godotInstance else { return }
    
    print("GodotView: Setting up Godot view with SwiftGodot")
    
    // Initialize SwiftGodot
    let engine = GodotEngine()
    godotInstance.godotObject = engine
    
    // Load project
    engine.loadProject(path: getGodotProjectPath())
    
    // Add view to container
    if let godotView = engine.view {
        godotView.frame = containerView.bounds
        godotView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(godotView)
    }
    
    pluginMaster?.registerWithGodot()
}
```

#### 🔴 Option B: Custom Godot XCFramework (Advanced)

1. Build Godot for iOS:
```bash
git clone https://github.com/godotengine/godot.git
cd godot
git checkout 4.4-stable
scons platform=ios target=template_release arch=arm64
scons platform=ios target=template_release arch=x86_64
```

2. Create XCFramework:
```bash
xcodebuild -create-xcframework \
  -framework bin/libgodot.ios.template_release.arm64.framework \
  -framework bin/libgodot.ios.template_release.x86_64.framework \
  -output ios/Frameworks/GodotEngine.xcframework
```

3. Update `ios/flutter_godot_widget.podspec`:
```ruby
s.vendored_frameworks = 'Frameworks/GodotEngine.xcframework'
s.frameworks = 'Metal', 'MetalKit', 'CoreHaptics'
```

---

### Step 2: Install Dependencies

```bash
cd example/ios
pod install
```

---

### Step 3: Build and Test

```bash
# Open in Xcode
open example/ios/Runner.xcworkspace

# Build and run (⌘R)
# Or use: flutter run -d "YOUR_DEVICE_NAME"
```

---

### Step 4: Test Communication

1. Launch app
2. Tap **"Show Godot View"** button
3. Tap **"Flutter 2 Godot"** button
4. Check console for logs:
   - `FlutterGodotWidgetPlugin: Received data from Flutter`
   - `GodotPluginMaster: Sending data to Godot`

---

## 🆘 Troubleshooting

### "Pod install fails"

```bash
cd example/ios
rm -rf Pods/ Podfile.lock
pod cache clean --all
pod install
```

### "Build fails in Xcode"

```bash
# Clean
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Rebuild
cd example/ios
pod deintegrate
pod install
open Runner.xcworkspace
# Product → Clean Build Folder (Shift+⌘K)
```

### "Godot singleton not found"

Make sure:
1. Godot framework is linked
2. Assets are in `ios/Assets/`
3. `project.godot` exists

### "Assets not loading"

```bash
# Re-copy assets
cd ios
./copy_godot_assets.sh

# Verify
ls -la ios/Assets/

# Rebuild
cd example/ios
pod install
```

---

## 📝 Testing Checklist

- [ ] App launches without crash
- [ ] "Show Godot View" button appears
- [ ] Tapping button shows Godot view
- [ ] Godot view fills the container
- [ ] "Flutter 2 Godot" button sends data
- [ ] Console shows communication logs
- [ ] Godot scripts can send data back

---

## 📚 Full Documentation

For detailed information, see:
- `iOS_INTEGRATION_GUIDE.md` - Complete integration guide
- `IMPLEMENTATION_SUMMARY.md` - What was implemented
- `ios/Assets/README.md` - Asset management

---

## 🎯 Expected Result

When working correctly:

1. **App Launch**: Flutter view with button
2. **Tap "Show Godot View"**: Godot content appears
3. **Communication**: Data flows both ways
4. **Console Logs**: See all events

```
✅ FlutterGodotWidgetPlugin: Registering plugin
✅ GodotEventsHandler: Initialized
✅ GodotView: Initializing with viewId: 0
✅ GodotPluginMaster: Initialized
✅ GodotView: Godot initialized successfully
```

---

## 💡 Pro Tips

1. **Always test on real device first** - Simulator may have GPU limitations
2. **Check Xcode console** - Extensive logging added for debugging
3. **Keep assets in sync** - Run `copy_godot_assets.sh` after Godot changes
4. **Use SwiftGodot** - It's maintained and easier than custom builds

---

**Time to complete**: 15-30 minutes (depending on chosen method)

**Questions?** Check `iOS_INTEGRATION_GUIDE.md` for detailed troubleshooting!

Good luck! 🎮

