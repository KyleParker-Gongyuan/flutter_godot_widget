# 🚀 START HERE - Quick Reference

## ✅ iOS Directory Ready!

```
ios/
├── Classes/         ✅ 6 Swift files (complete)
├── Assets/          ✅ All Godot files (copied)
└── podspec          ✅ Configured
```

---

## 🎯 Just Do These 4 Steps

### 📍 STEP 1: Test Now (5 min) - No Godot needed!

```bash
# IMPORTANT: Run from example directory first!
cd example
flutter pub get

# Now install pods
cd ios
pod install
open Runner.xcworkspace
```

Press **⌘R** → Tap **"iOS Test" tab** → Tap **"Show Godot"** → Tap **"Send Test"**

**✅ Success = Logs in both consoles**

---

### 📍 STEP 2: Test Button (5 min)

Open `ios/Classes/GodotView.swift`

Add before `pluginMaster?.registerWithGodot()`:

```swift
// Test button
let button = UIButton(frame: CGRect(x: 50, y: 100, width: 250, height: 50))
button.setTitle("Test: Send to Flutter", for: .normal)
button.backgroundColor = .systemBlue
button.layer.cornerRadius = 8
button.addTarget(self, action: #selector(testSendToFlutter), for: .touchUpInside)
containerView.addSubview(button)
```

Add at end of class:

```swift
@objc private func testSendToFlutter() {
    print("Test button tapped!")
    pluginMaster?.sendDataToFlutter("Hello from iOS! \(Date())")
}
```

Rebuild → Tap button → **✅ Flutter console gets message**

---

### 📍 STEP 3: Godot Framework (30 min)

**In Godot Editor 4.4.0:**
1. Project → Export → Add iOS
2. Export
3. Find `godot_ios.xcframework`
4. Copy to `ios/Frameworks/`

**Update `ios/flutter_godot_widget.podspec`** (add after line 17):

```ruby
s.vendored_frameworks = 'Frameworks/godot_ios.xcframework'
s.frameworks = 'Metal', 'MetalKit', 'CoreHaptics', 'AVFoundation'
```

```bash
cd example/ios
pod deintegrate
pod install
```

Rebuild

---

### 📍 STEP 4: Final Test (5 min)

Run app:
- ✅ Godot renders
- ✅ Flutter → Godot works
- ✅ Godot → Flutter works
- ✅ Resize works

**🎉 Done!**

---

## 📚 More Help

- **SIMPLE_STEPS.md** - Detailed version
- **iOS_TESTING_GUIDE.md** - Full testing guide
- **ADDING_GODOT_FRAMEWORK.md** - Framework details

---

## ⚡ Super Quick Commands

```bash
# Install & open
cd example/ios && pod install && open Runner.xcworkspace

# Clean (if issues)
pod deintegrate && pod install

# Test
flutter run -d "iPhone"
```

---

## 🎯 Success Checklist

- [ ] Step 1: Logs appear ✅
- [ ] Step 2: Button sends to Flutter ✅
- [ ] Step 3: Framework added ✅
- [ ] Step 4: Everything works ✅

**Total time: ~45 minutes** 🚀

