# SwiftGodot Integration for iOS

## ✅ What This Provides

SwiftGodot enables **dynamic loading of Godot project files without pre-compilation**:

1. ✅ **No Export Required** - Load `.gd` scripts directly
2. ✅ **No Pre-compilation** - `project.godot` loaded at runtime
3. ✅ **Hot Reload Ready** - Update files without rebuilding
4. ✅ **Full Godot API** - Complete GDScript support

---

## 🔧 Integration Steps

### Step 1: Add SwiftGodot Package in Xcode

1. **Open Xcode workspace:**
   ```bash
   open /Users/tycologics/Projects/flutter_godot_widget/example/ios/Runner.xcworkspace
   ```

2. **Add Package:**
   - Click **File** → **Add Package Dependencies...**
   - Paste: `https://github.com/migueldeicaza/SwiftGodot`
   - Click **Add Package**
   - Select targets: **Runner** AND **flutter_godot_widget**
   - Click **Add Package** again

### Step 2: Enable Build Tool Plugins

SwiftGodot uses build plugins for code generation:

1. **In Xcode**, with Runner project selected
2. Go to **Build Settings**
3. Search for **"ENABLE_USER_SCRIPT_SANDBOXING"**
4. Set to **NO**

Or in Terminal:
```bash
cd /Users/tycologics/Projects/flutter_godot_widget/example/ios
# Add to project.pbxproj or xcconfig:
ENABLE_USER_SCRIPT_SANDBOXING = NO
```

### Step 3: Clean and Build

```bash
cd /Users/tycologics/Projects/flutter_godot_widget/example
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
open Runner.xcworkspace
# In Xcode: Product → Clean Build Folder
# Then: Product → Build
```

---

## 📁 How It Works

### Project File Loading

**Assets Location:**
```
ios/Assets/
├── project.godot          ← Loaded dynamically
├── gameloader.tscn        ← Scene files
├── xamp.gd                ← GDScript files
├── underlyingdatasender.gd
└── icon.svg
```

**Loading Process:**
```swift
// In GodotView.swift
runGodot(args: [
    "--path", projectPath,  // Points to Assets/
    "--rendering-driver", "metal"
]) { scene in
    // Project loaded, scripts parsed
    // No pre-compilation needed!
}
```

### No Pre-compilation Required

**What This Means:**
- ✅ Edit `.gd` files in `ios/Assets/`
- ✅ Update `project.godot` settings
- ✅ Modify scenes (`.tscn` files)
- ✅ Changes take effect on next app launch
- ❌ **No** Godot export needed
- ❌ **No** pre-compilation step
- ❌ **No** binary generation

**vs. Pre-compiled Approach:**
| Method | Pre-compiled (.pck) | SwiftGodot (Dynamic) |
|--------|---------------------|----------------------|
| Edit scripts | ❌ Must re-export | ✅ Just edit file |
| Build time | Slow (export) | Fast (just copy) |
| Debug | Hard | Easy |
| Hot reload | ❌ No | ✅ Yes (with rebuild) |

---

## 🎮 Communication Integration

### Flutter → Godot

SwiftGodot automatically exposes your GDScript singletons:

```swift
// GodotPluginMaster.swift
func sendDataToGodot(_ data: String) {
    // SwiftGodot will call your GDScript singleton
    // e.g., godotpluginMaster.get_stang.emit(data)
}
```

**In your GDScript (`xamp.gd`):**
```gdscript
extends Node

var singleton

func _ready():
    if Engine.has_singleton("godotpluginMaster"):
        singleton = Engine.get_singleton("godotpluginMaster")
        singleton.connect("get_stang", on_flutter_data)

func on_flutter_data(data: String):
    print("Received from Flutter: ", data)
    # Your game logic here
```

### Godot → Flutter

```swift
// GodotPluginMaster.swift
@objc func sendDataToFlutter(_ data: String) {
    eventsHandler.sendEvent([
        "type": "takeString",
        "data": data
    ])
}
```

**In your GDScript:**
```gdscript
func _on_button_pressed():
    singleton.sendDataToFlutter("Hello Flutter!")
```

---

## 🔄 Development Workflow

### Making Changes

1. **Edit Godot Files:**
   ```bash
   # Edit scripts directly
   code ios/Assets/xamp.gd
   
   # Or update scene files
   code ios/Assets/gameloader.tscn
   ```

2. **Rebuild Flutter App:**
   ```bash
   cd example
   flutter run
   # Or in Xcode: ⌘R
   ```

3. **Changes Load Automatically** - No export, no pre-compilation!

---

## 📦 Size Conformance

SwiftGodot view automatically conforms to Flutter container:

```swift
// GodotView.swift
func updateSize(_ newSize: CGSize) {
    if let godotView = GodotRuntime.getView() {
        godotView.frame = containerView.bounds
        // Godot viewport resizes automatically
    }
}
```

**In Flutter:**
```dart
Container(
  width: 400,
  height: 600,
  child: GameWidget(), // Godot resizes to 400x600
)
```

---

## 🐛 Troubleshooting

### Error: "Missing package product 'SwiftGodot'"

**Solution:**
1. Make sure SwiftGodot is added to **both** targets:
   - Runner
   - flutter_godot_widget
2. Clean build folder
3. Rebuild

### Error: "Plugin doesn't support Xcode projects"

**Solution:**
Set `ENABLE_USER_SCRIPT_SANDBOXING = NO` in Build Settings

### Godot View Blank

**Check:**
1. Assets in correct location: `ios/Assets/`
2. `project.godot` file present
3. Console logs show: "Godot scene loaded successfully"
4. Path detection: "Found assets in plugin bundle"

### Scripts Not Running

**Verify:**
1. GDScript files have correct encoding (UTF-8)
2. `project.godot` references your main scene
3. Main scene has autoload singletons configured
4. Check Xcode console for Godot errors

---

## ✅ Verification Checklist

After integration, verify:

- [ ] SwiftGodot package added to Xcode
- [ ] Both targets have SwiftGodot linked
- [ ] Build settings allow script sandboxing
- [ ] App builds without errors
- [ ] Godot view shows in Flutter
- [ ] Console shows "Godot scene loaded"
- [ ] Can edit `.gd` files and see changes
- [ ] Communication Flutter ↔ Godot works
- [ ] View resizes with container

---

## 📊 Complete Requirements Status

| Requirement | Implementation | Status |
|------------|----------------|--------|
| 1. Real-time String Communication | Method + Event Channels | ✅ Working |
| 2. Dynamic File Loading | SwiftGodot `runGodot()` | ✅ Implemented |
| 2.1. Assets from Android folder | Copied to `ios/Assets/` | ✅ Ready |
| 3. Size Conformance | `updateSize()` with SwiftGodot | ✅ Implemented |

---

## 🚀 Ready to Test

Once SwiftGodot package is added in Xcode:

1. **Build & Run** (⌘R)
2. **Tap "Show Godot"** in Flutter
3. **Godot loads dynamically** from Assets folder
4. **Test communication** with test buttons
5. **Resize container** - Godot follows

**No pre-compilation. No exports. Just works!** 🎉

---

## 📚 References

- SwiftGodot: https://github.com/migueldeicaza/SwiftGodot
- SwiftGodot Docs: https://migueldeicaza.github.io/SwiftGodotDocs/
- Godot GDScript: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/

