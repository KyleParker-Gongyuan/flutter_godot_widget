# 🚀 Simple Steps - iOS Setup & Testing

## 📁 What You Have (iOS Directory)

```
ios/
├── Classes/                          ✅ 6 Swift files ready
│   ├── FlutterGodotWidgetPlugin.swift
│   ├── GodotEventsHandler.swift
│   ├── GodotPluginMaster.swift
│   ├── GodotPluginProvider.swift
│   ├── GodotView.swift
│   └── GodotViewFactory.swift
├── Assets/                           ✅ All Godot files copied
│   ├── project.godot
│   ├── xamp.gd
│   ├── gameloader.tscn
│   └── (20+ more files)
├── copy_godot_assets.sh             ✅ Asset sync script
└── flutter_godot_widget.podspec     ✅ Configuration
```

**Status:** Everything is built and ready! ✅

---

## 🎯 Step 1: Quick Test (5 minutes)

**Test the communication without Godot framework:**

```bash
# IMPORTANT: Start from example directory
cd example
flutter pub get

# Now install pods
cd ios
pod install
open Runner.xcworkspace
```

Press **⌘R** to run

**In the app:**
1. Tap "**iOS Test**" tab at top
2. Tap "**Show Godot**" button
3. Tap "**Send Test**" button
4. Look at logs

**✅ Success if you see:**
- Xcode console: `FlutterGodotWidgetPlugin: Registering plugin`
- Flutter console: `📥 Received: ...`

---

## 🎯 Step 2: Add Test Button (5 minutes)

**Make iOS send messages to Flutter:**

1. Open `ios/Classes/GodotView.swift`

2. Find line ~100 (in `setupGodotView()` method)

3. Add this BEFORE `pluginMaster?.registerWithGodot()`:

```swift
// Add test button
let button = UIButton(frame: CGRect(x: 50, y: 100, width: 250, height: 50))
button.setTitle("Test: Send to Flutter", for: .normal)
button.backgroundColor = .systemBlue
button.layer.cornerRadius = 8
button.addTarget(self, action: #selector(testSendToFlutter), for: .touchUpInside)
containerView.addSubview(button)
```

4. Add this method at the end of the `GodotView` class:

```swift
@objc private func testSendToFlutter() {
    print("Test button tapped!")
    pluginMaster?.sendDataToFlutter("Hello from iOS! \(Date())")
}
```

5. Rebuild (⌘B) and run (⌘R)

6. Tap the blue button in Godot view

**✅ Success if you see:**
- Flutter console gets the message
- "iOS Test" tab shows: `📥 Received: Hello from iOS!`

---

## 🎯 Step 3: Add Godot Framework (30 minutes)

**Choose the easiest method:**

### Method: Export from Godot Editor

1. Open your Godot project in **Godot 4.4.0 Editor**

2. Go to **Project** → **Export...**

3. Click **Add...** → Select **iOS**

4. Configure:
   - Bundle Identifier: `com.yourcompany.yourapp`
   - Team ID: (your Apple team)
   
5. Click **Export Project**

6. Save as iOS Xcode project

7. Find the exported folder, locate `godot_ios.xcframework`

8. Copy it:
```bash
mkdir -p ios/Frameworks
cp -R /path/to/exported/godot_ios.xcframework ios/Frameworks/
```

9. Edit `ios/flutter_godot_widget.podspec`, add after line 17:

```ruby
s.vendored_frameworks = 'Frameworks/godot_ios.xcframework'
s.frameworks = 'Metal', 'MetalKit', 'CoreHaptics', 'AVFoundation'
```

10. Reinstall:
```bash
cd example/ios
pod deintegrate
pod install
```

11. Rebuild in Xcode

---

## 🎯 Step 4: Final Test (5 minutes)

**Test everything works:**

1. Run the app

2. In "iOS Test" tab:
   - ✅ Show Godot view → Should see Godot scene
   - ✅ Tap "Send Test" → Godot should receive
   - ✅ Move size sliders → View should resize
   - ✅ Tap buttons in Godot → Flutter should receive

3. In "Original" tab:
   - ✅ Show Godot View → Works
   - ✅ Flutter 2 Godot → Works

**✅ Done!** Your iOS version matches Android! 🎉

---

## 🐛 If Something Goes Wrong

### Problem: Pod install fails

```bash
cd example/ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
```

### Problem: Build fails

```bash
# Clean everything
rm -rf ~/Library/Developer/Xcode/DerivedData/*
# In Xcode: Product → Clean Build Folder (Shift+⌘K)
```

### Problem: No logs appear

1. Check Xcode console is visible (View → Debug Area → Show Debug Area)
2. Check Flutter console in terminal/VS Code
3. Make sure channel names are correct

### Problem: Can't find Godot framework

You need to either:
- Export from Godot Editor (easiest)
- OR build from source (advanced)

See `ADDING_GODOT_FRAMEWORK.md` for detailed help.

---

## 📋 Quick Checklist

**Before testing:**
- [ ] Xcode 15+ installed
- [ ] CocoaPods installed (`sudo gem install cocoapods`)
- [ ] Flutter SDK installed
- [ ] iOS device or simulator ready

**Step 1 - Quick Test:**
- [ ] `pod install` works
- [ ] App builds and runs
- [ ] "iOS Test" tab appears
- [ ] Can show/hide Godot view
- [ ] Logs appear in consoles

**Step 2 - Test Button:**
- [ ] Test button code added
- [ ] Rebuilds successfully
- [ ] Button appears in view
- [ ] Tapping sends to Flutter
- [ ] Flutter receives message

**Step 3 - Godot Framework:**
- [ ] Framework exported/built
- [ ] Copied to `ios/Frameworks/`
- [ ] Podspec updated
- [ ] `pod install` runs again
- [ ] Builds successfully

**Step 4 - Final Test:**
- [ ] Godot scene renders
- [ ] Flutter → Godot works
- [ ] Godot → Flutter works
- [ ] Size conformance works
- [ ] No crashes or errors

---

## ⏱️ Time Estimate

- **Step 1:** 5 minutes
- **Step 2:** 5 minutes
- **Step 3:** 30 minutes
- **Step 4:** 5 minutes

**Total:** ~45 minutes for complete iOS integration! 🚀

---

## 💡 Pro Tips

1. **Do Step 1 first** - It proves everything works without Godot
2. **Check both consoles** - Xcode shows native logs, Flutter shows event logs
3. **Use iOS Test tab** - It has better logging and controls
4. **Export from Godot** - Much easier than building from source

---

## 🎓 What Each Step Tests

| Step | Tests | Why Important |
|------|-------|---------------|
| 1 | Communication channels | Proves architecture works |
| 2 | Bidirectional flow | Proves events reach Flutter |
| 3 | Godot integration | Adds the engine |
| 4 | Complete system | Validates all requirements |

---

## 📞 Need Help?

**Quick fixes:**
- App crashes → Check Xcode console for errors
- No logs → Verify channel names match
- Build fails → Clean and rebuild
- Pod issues → Delete Pods folder and reinstall

**Detailed help:**
- `iOS_TESTING_GUIDE.md` - Full testing guide
- `ADDING_GODOT_FRAMEWORK.md` - Framework integration
- `TESTING_AND_DELIVERY.md` - Complete testing plan

---

## ✅ Success Looks Like

**After Step 1:**
```
Xcode Console:
  ✅ FlutterGodotWidgetPlugin: Registering plugin
  ✅ GodotEventsHandler: Initialized
  ✅ GodotView: Initializing

Flutter Console:
  ✅ flutter: 📥 Received: ...
```

**After Step 2:**
```
Flutter Console:
  ✅ flutter: 📥 Received: Hello from iOS!
  ✅ [timestamp] 📥 Received: ...
```

**After Steps 3 & 4:**
```
Godot scene visible ✅
Messages flow both ways ✅
View resizes properly ✅
No crashes ✅
```

---

## 🎉 You're Done!

Once all steps pass, you have:
- ✅ Real-time Flutter ↔ Godot communication
- ✅ Dynamic Godot project loading
- ✅ Automatic size conformance
- ✅ Complete iOS implementation matching Android!

**Congratulations!** 🎮🚀

---

**Start with Step 1 right now - it only takes 5 minutes!** ⭐

