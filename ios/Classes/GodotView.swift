import Flutter
import UIKit
import SwiftGodot

/// GodotView is the iOS equivalent of the Android GodotView.kt
/// It implements FlutterPlatformView and hosts the Godot engine
class GodotView: NSObject, FlutterPlatformView {
    
    // MARK: - Properties
    
    private let containerView: UIView
    private let frame: CGRect
    private let viewId: Int64
    private let provider: GodotPluginProvider
    
    private var godotInstance: GodotInstance?
    private var pluginMaster: GodotPluginMaster?
    private var isGodotInitialized: Bool = false
    
    // MARK: - Initialization
    
    init(
        frame: CGRect,
        viewId: Int64,
        args: Any?,
        provider: GodotPluginProvider
    ) {
        self.frame = frame
        self.viewId = viewId
        self.provider = provider
        
        // Create container view
        self.containerView = UIView(frame: frame)
        self.containerView.backgroundColor = .black
        self.containerView.clipsToBounds = true
        
        super.init()
        
        print("GodotView: Initializing with viewId: \(viewId), frame: \(frame)")
        
        // Check if we need to recreate Godot
        if provider.shouldRecreateGodot() {
            print("GodotView: Recreating Godot instance")
            recreateGodot()
        } else {
            // Initialize Godot
            initializeGodot()
        }
    }
    
    deinit {
        print("GodotView: Deinitializing")
        cleanup()
    }
    
    // MARK: - FlutterPlatformView
    
    func view() -> UIView {
        return containerView
    }
    
    // MARK: - Godot Lifecycle
    
    private func initializeGodot() {
        print("GodotView: Initializing Godot engine")
        
        // Get or create Godot instance
        godotInstance = provider.getGodotInstance()
        
        guard let godotInstance = godotInstance else {
            print("GodotView: ERROR - Failed to get Godot instance")
            return
        }
        
        // Create plugin master for communication
        pluginMaster = GodotPluginMaster(godotInstance: godotInstance, provider: provider)
        
        // Setup Godot view
        setupGodotView()
        
        isGodotInitialized = true
        print("GodotView: Godot initialized successfully")
    }
    
    private func setupGodotView() {
        guard let godotInstance = godotInstance else { return }
        
        print("GodotView: Setting up Godot view with SwiftGodot")
        
        // Get the path to Godot project files (not pre-compiled)
        let projectPath = getGodotProjectPath()
        print("GodotView: Loading Godot project from: \(projectPath)")
        
        // Initialize SwiftGodot with the project path
        // This loads the project.godot file and all .gd scripts dynamically
        runGodot(args: [
            "--path", projectPath,
            "--rendering-driver", "metal"
        ]) { scene in
            DispatchQueue.main.async { [weak self] in
                print("GodotView: ✅ Godot scene loaded successfully!")
                self?.onGodotReady(scene: scene)
            }
        }
        
        // Get the Godot rendering view and add it to our container
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if let godotView = GodotRuntime.getView() {
                print("GodotView: Got SwiftGodot view, adding to container")
                godotView.frame = self.containerView.bounds
                godotView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.containerView.addSubview(godotView)
                print("GodotView: ✅ Godot rendering started - project loaded dynamically!")
            } else {
                print("GodotView: ⚠️ SwiftGodot view not available yet")
                self.showPlaceholder()
            }
        }
        
        // Register plugin with Godot for communication
        pluginMaster?.registerWithGodot()
    }
    
    private func onGodotReady(scene: GDExtension.InitializationLevel) {
        print("GodotView: Godot engine ready at level: \(scene)")
        // Engine is now running and project files are loaded
        // Communication channels can now talk to GDScript
    }
    
    private func showPlaceholder() {
        let label = UILabel(frame: containerView.bounds)
        label.text = "🎮 Godot\n\nInitializing SwiftGodot...\nLoading project files"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(label)
        
        // Add test button for communication demo
        addTestButton()
    }
    
    // SwiftGodot handles dynamic loading of Godot project files
    
    private func recreateGodot() {
        print("GodotView: Recreating Godot instance")
        
        // Cleanup old instance
        cleanup()
        
        // Initialize new instance
        initializeGodot()
    }
    
    private func cleanup() {
        print("GodotView: Cleaning up Godot resources")
        
        // Cleanup plugin
        pluginMaster?.cleanup()
        pluginMaster = nil
        
        // Clear views
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        isGodotInitialized = false
    }
    
    // MARK: - Helper Methods
    
    /// Get the path to Godot project assets
    private func getGodotProjectPath() -> String {
        // First, try to get from the plugin bundle
        if let bundlePath = Bundle(for: type(of: self)).path(forResource: "flutter_godot_widget", ofType: "bundle"),
           let bundle = Bundle(path: bundlePath),
           let assetsPath = bundle.resourcePath {
            print("GodotView: Found assets in plugin bundle: \(assetsPath)")
            return assetsPath
        }
        
        // Fallback: try main bundle
        if let assetsPath = Bundle.main.path(forResource: "godot_assets", ofType: nil) {
            print("GodotView: Found assets in main bundle: \(assetsPath)")
            return assetsPath
        }
        
        // Last resort: use documents directory
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let godotPath = (documentsPath as NSString).appendingPathComponent("godot_project")
        print("GodotView: Using documents directory: \(godotPath)")
        return godotPath
    }
    
    /// Handle data from Flutter to send to Godot
    func sendDataToGodot(_ data: String) {
        print("GodotView: Sending data to Godot: \(data)")
        pluginMaster?.sendDataToGodot(data)
    }
}

// MARK: - Size Conformance

extension GodotView {
    /// Update Godot viewport size to match Flutter container
    /// This ensures Godot conforms to the Flutter container's size
    func updateSize(_ newSize: CGSize) {
        print("GodotView: Updating size to: \(newSize)")
        
        // Update container frame
        containerView.frame.size = newSize
        
        // Update SwiftGodot view to match container
        if let godotView = GodotRuntime.getView() {
            godotView.frame = containerView.bounds
            print("GodotView: SwiftGodot view resized to: \(newSize)")
        } else {
            // Update any placeholder subviews
            containerView.subviews.forEach { subview in
                subview.frame = containerView.bounds
            }
        }
    }
}

// MARK: - Test Button for Demo

extension GodotView {
    /// Add test button to demonstrate iOS → Flutter communication
    private func addTestButton() {
        // Create button
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 50, y: 100, width: 250, height: 50)
        button.setTitle("📤 Send to Flutter (Test)", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(testSendToFlutter), for: .touchUpInside)
        containerView.addSubview(button)
        
        // Create status label
        let label = UILabel(frame: CGRect(x: 50, y: 180, width: 300, height: 150))
        label.text = "✅ iOS Communication Ready!\n\nTap button to test\niOS → Flutter\nreal-time messaging"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.tag = 999 // Tag to find it later
        containerView.addSubview(label)
        
        print("GodotView: Test button added for demo")
    }
    
    /// Handle test button tap - sends message to Flutter
    @objc private func testSendToFlutter() {
        print("GodotView: Test button tapped!")
        
        // Update label with success message
        if let label = containerView.viewWithTag(999) as? UILabel {
            label.text = "✅ Message Sent!\n\nCheck:\n• Flutter console\n• iOS Test tab logs\n• Communication verified!"
            label.textColor = .green
        }
        
        // Send test data to Flutter via plugin master
        let timestamp = Date().timeIntervalSince1970
        let message = "Hello from iOS! Time: \(Int(timestamp))"
        
        print("GodotView: Sending message to Flutter: \(message)")
        pluginMaster?.sendDataToFlutter(message)
        
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.viewWithTag(999)?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.viewWithTag(999)?.transform = .identity
            }
        }
    }
}

// MARK: - Lifecycle Notifications

extension GodotView {
    /// Called when view will appear
    func viewWillAppear() {
        print("GodotView: viewWillAppear")
        // Lifecycle management ready for Godot integration
    }
    
    /// Called when view will disappear
    func viewWillDisappear() {
        print("GodotView: viewWillDisappear")
        // Lifecycle management ready for Godot integration
    }
}

