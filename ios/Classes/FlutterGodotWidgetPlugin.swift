import Flutter
import UIKit
import SwiftGodot

// GodotPlatformView: UIView that embeds real Godot engine
class GodotPlatformView: NSObject, FlutterPlatformView {
    private let frame: CGRect
    private let viewId: Int64
    private let containerView: UIView
    private var godotView: GodotView?
    private var isGodotInitialized = false
    private var currentPckName = "game.pck"
    private var godotInstance: Godot?

    init(frame: CGRect, viewId: Int64, args: Any?) {
        self.frame = frame
        self.viewId = viewId
        self.containerView = UIView(frame: frame)
        super.init()
        
        print("🚀 GodotPlatformView init - frame: \(frame)")
        setupGodot()
    }
    
    private func setupGodot() {
        initializeGodotWithCurrentPck()
    }
    
    private func initializeGodotWithCurrentPck() {
        do {
            print("🚀 Starting Godot engine initialization...")
            
            // Clean up previous instance if exists
            if let existingView = godotView {
                existingView.removeFromSuperview()
                godotView = nil
            }
            
            // Find the .pck file with priority: Bundle -> Documents directory
            guard let pckPath = findPckFile(named: currentPckName) else {
                print("❌ Could not find \(currentPckName) in bundle or documents directory")
                print("📁 Available .pck files in bundle: \(Bundle.main.paths(forResourcesOfType: "pck", inDirectory: nil))")
                if let documentsPath = getDocumentsDirectory() {
                    print("📁 Documents directory: \(documentsPath)")
                }
                createErrorView(message: "Game file \(currentPckName) not found")
                return
            }
            
            print("✅ Found .pck file at: \(pckPath)")
            
            // Initialize Godot with the .pck file
            if !isGodotInitialized {
                // Configure Godot arguments
                var args = ["--main-pack", pckPath]
                
                // Initialize Godot engine
                Godot.initialize(with: args)
                isGodotInitialized = true
                print("✅ Godot engine initialized successfully")
            } else {
                // For runtime switching, we need to reload with new pack
                print("🔄 Reloading Godot with new pack: \(pckPath)")
                // Note: SwiftGodot may require engine restart for pack switching
                // This is a limitation we'll document
            }
            
            // Create Godot view
            godotView = GodotView(frame: containerView.bounds)
            guard let godotView = godotView else {
                print("❌ Failed to create GodotView")
                createErrorView(message: "Failed to create Godot view")
                return
            }
            
            // Pin Godot view to all edges for proper Flutter layout integration
            godotView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(godotView)
            
            NSLayoutConstraint.activate([
                godotView.topAnchor.constraint(equalTo: containerView.topAnchor),
                godotView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                godotView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                godotView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
            
            print("✅ Godot view created and added to container")
            print("📦 Loaded pack: \(currentPckName)")
            
        } catch {
            print("❌ Godot initialization failed: \(error)")
            createErrorView(message: "Godot initialization failed: \(error.localizedDescription)")
        }
    }
    
    private func createErrorView(message: String) {
        let errorView = UIView(frame: containerView.bounds)
        errorView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        errorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let label = UILabel()
        label.text = "❌ \(message)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        errorView.addSubview(label)
        containerView.addSubview(errorView)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: errorView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: errorView.trailingAnchor, constant: -20)
        ])
    }
    
    // Method to handle messages from Flutter
    func handleFlutterMessage(_ message: String) {
        print("📨 Godot received message from Flutter: \(message)")
        
        // Send message to Godot through the engine
        if let godotView = godotView {
            // Use Godot's signal system or call a method on a specific node
            // This is a placeholder - the actual implementation depends on your Godot game setup
            print("📤 Forwarding message to Godot engine: \(message)")
            
            // Example: Call a method on the main scene's root node
            // You would customize this based on your Godot game's structure
            // godotView.getMainScene()?.call("receive_flutter_message", [message])
        } else {
            print("⚠️ No Godot view available to receive message")
        }
    }
    
    // Method to reload Godot with a new .pck file
    func reloadWithPck(_ pckName: String) {
        print("🔄 Reloading Godot with new pack: \(pckName)")
        currentPckName = pckName
        initializeGodotWithCurrentPck()
    }
    
    // Method to set the current .pck name without reloading
    func setPckName(_ pckName: String) {
        print("📦 Setting current pack name to: \(pckName)")
        currentPckName = pckName
    }
    
    // Helper method to find .pck file with priority: Bundle -> Documents directory
    private func findPckFile(named pckName: String) -> String? {
        let pckNameWithoutExtension = pckName.replacingOccurrences(of: ".pck", with: "")
        
        // 1. Check main bundle first (copied by build script)
        if let bundlePath = Bundle.main.path(forResource: pckNameWithoutExtension, ofType: "pck") {
            print("📦 Found .pck in bundle: \(bundlePath)")
            return bundlePath
        }
        
        // 2. Check documents directory (for downloaded packs)
        if let documentsPath = getDocumentsDirectory() {
            let documentsFilePath = documentsPath.appendingPathComponent(pckName)
            if FileManager.default.fileExists(atPath: documentsFilePath.path) {
                print("📦 Found .pck in documents: \(documentsFilePath.path)")
                return documentsFilePath.path
            }
        }
        
        return nil
    }
    
    // Helper method to get documents directory
    private func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }

    func view() -> UIView {
        return containerView
    }
}

// GodotPlatformViewFactory: Creates GodotPlatformView instances
class GodotPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let godotView = GodotPlatformView(frame: frame, viewId: viewId, args: args)
        FlutterGodotWidgetPlugin.currentGodotView = godotView
        return godotView
    }
}

public class FlutterGodotWidgetPlugin: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel?
    static var registrar: FlutterPluginRegistrar?
    static var currentGodotView: GodotPlatformView?
    static var shared: FlutterGodotWidgetPlugin?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_godot_widget/method_channel", binaryMessenger: registrar.messenger())
        let instance = FlutterGodotWidgetPlugin()
        instance.channel = channel
        FlutterGodotWidgetPlugin.registrar = registrar
        FlutterGodotWidgetPlugin.shared = instance
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Register the Godot platform view
        let factory = GodotPlatformViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "godot-view")
        print("✅ Registered iOS PlatformView factory with ID: godot-view")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "sendString":
            if let args = call.arguments as? [String: Any], let message = args["data"] as? String {
                // Handle the string received from Flutter
                print("Received from Flutter: \(message)")
                
                // Send to Godot if available
                sendStringToGodot(message: message)
                
                result("iOS received: \(message)")
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected a string under 'data'", details: nil))
            }
        case "receiveString":
            if let args = call.arguments as? [String: Any], let message = args["data"] as? String {
                // Send a string from iOS to Flutter
                sendStringToFlutter(message: message)
                result("iOS sent: \(message)")
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected a string under 'data'", details: nil))
            }
        case "loadGodotScene":
            if let args = call.arguments as? [String: Any], let scenePath = args["scenePath"] as? String {
                loadGodotScene(scenePath: scenePath)
                result("Loading scene: \(scenePath)")
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected scenePath", details: nil))
            }
        case "touch":
            // Handle platform view touch events
            result("touch handled")
        case "listen":
            // Handle event channel listen
            result(nil)
        case "getIntentData":
            // Handle intent data (Android-specific, return empty for iOS)
            result([:])
        case "sendData2Godot":
            // Handle data sent to Godot
            if let args = call.arguments as? [String: Any], let data = args["data"] as? String {
                sendStringToGodot(message: data)
                result("Data sent to Godot: \(data)")
            } else {
                result("No data provided")
            }
        case "setPckName":
            // Set the current .pck file name
            if let args = call.arguments as? [String: Any], let pckName = args["pckName"] as? String {
                FlutterGodotWidgetPlugin.currentGodotView?.setPckName(pckName)
                result("PCK name set to: \(pckName)")
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected pckName", details: nil))
            }
        case "reloadGodot":
            // Reload Godot with current or specified .pck file
            var pckName = "game.pck" // default
            if let args = call.arguments as? [String: Any], let specifiedPck = args["pckName"] as? String {
                pckName = specifiedPck
            }
            FlutterGodotWidgetPlugin.currentGodotView?.reloadWithPck(pckName)
            result("Godot reloaded with: \(pckName)")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Helper to send a string from iOS to Flutter
    public func sendStringToFlutter(message: String) {
        channel?.invokeMethod("onStringFromNative", arguments: ["data": message])
    }
    
    // Helper to send a string to Godot
    private func sendStringToGodot(message: String) {
        // Forward message to current Godot view
        FlutterGodotWidgetPlugin.currentGodotView?.handleFlutterMessage(message)
        
        // TODO: Replace with real Godot communication once framework is provided
        /*
        REAL GODOT COMMUNICATION (will be enabled once client provides framework):
        
        // Send message to Godot script
        Godot.callMethod("_on_flutter_message", arguments: [message])
        
        // Or send to specific node
        if let mainScene = Godot.getNode("Main") {
            mainScene.call("receive_message_from_flutter", [message])
        }
        */
        
        print("📤 Sending to Godot: \(message)")
        print("📍 Currently using simulation - waiting for Godot.xcframework")
    }
    
    // Helper to load Godot scene
    private func loadGodotScene(scenePath: String) {
        // TODO: Implement actual scene loading when Godot framework is available
        print("Loading Godot scene: \(scenePath)")
    }
}
