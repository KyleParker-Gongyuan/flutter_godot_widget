# 🔘 Add Test Button to iOS - Quick Guide

## ✅ You're Here Because

You saw the black Godot view with "Waiting for Godot framework" message! That's perfect! ✅

Now let's add a test button to verify **iOS → Flutter** communication works.

---

## 📝 Edit This File

**File:** `ios/Classes/GodotView.swift`

**Find line ~67** (the `setupGodotView()` method)

---

## 📋 Step 1: Add Test Button Method

**Add this code at the END of the GodotView class** (around line 165):

```swift
// MARK: - Test Button

private func addTestButton() {
    // Create button
    let button = UIButton(frame: CGRect(x: 50, y: 100, width: 250, height: 50))
    button.setTitle("📤 Send to Flutter (Test)", for: .normal)
    button.backgroundColor = .systemBlue
    button.layer.cornerRadius = 8
    button.addTarget(self, action: #selector(testSendToFlutter), for: .touchUpInside)
    containerView.addSubview(button)
    
    // Create status label
    let label = UILabel(frame: CGRect(x: 50, y: 200, width: 300, height: 150))
    label.text = "iOS Godot View Ready! ✅\n\nTap button to test\niOS → Flutter communication"
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = .white
    label.tag = 999 // Tag to find it later
    containerView.addSubview(label)
}

@objc private func testSendToFlutter() {
    print("GodotView: Test button tapped!")
    
    // Update label
    if let label = containerView.viewWithTag(999) as? UILabel {
        label.text = "✅ Message Sent!\n\nCheck Flutter console\nand iOS Test tab logs"
        label.textColor = .green
    }
    
    // Send test data to Flutter
    let timestamp = Date().timeIntervalSince1970
    pluginMaster?.sendDataToFlutter("Hello from iOS! Time: \(timestamp)")
}
```

---

## 📋 Step 2: Call It in setupGodotView()

**Find this line** (around line 90):

```swift
pluginMaster?.registerWithGodot()
```

**Add BEFORE it:**

```swift
// Add test button for communication testing
addTestButton()

pluginMaster?.registerWithGodot()
```

---

## 🔨 Rebuild

1. In Xcode: **Product → Build** (⌘B)
2. In Xcode: **Product → Run** (⌘R)

Or in terminal:
```bash
flutter run -d "Omer's iPhone"
```

---

## ✅ Test It!

1. Tap **"iOS Test"** tab
2. Tap **"Show Godot"**
3. **You should see:** Blue button that says "📤 Send to Flutter (Test)"
4. Tap the button
5. **Check:**
   - Label turns green ✅
   - Flutter console shows: `flutter: 📥 Received: Hello from iOS!` ✅
   - iOS Test tab shows the message in logs ✅

---

## 🎉 Success Means

If the message appears in Flutter:
- ✅ **Bidirectional communication works!**
- ✅ Event channel: iOS → Flutter working
- ✅ Method channel: Flutter → iOS working (already tested)

**You've proven the entire architecture works!** 🎉

---

## 🎯 After This Works

**Next Step:** Add Godot framework (SIMPLE_STEPS.md Step 3)

Then you'll have:
- ✅ Real-time Flutter ↔ Godot communication
- ✅ Godot scenes rendering
- ✅ Complete iOS integration matching Android!

---

**Add the code above and rebuild!** Should take 2 minutes! 🚀

