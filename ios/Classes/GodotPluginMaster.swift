import Foundation
import Flutter

/// GodotPluginMaster handles the bridge between Godot and Flutter
/// This is the iOS equivalent of the Android godotpluginMaster.kt
class GodotPluginMaster {
    
    // MARK: - Constants
    static let PLUGIN_NAME = "godotpluginMaster"
    static let SHOW_STRING_SIGNAL = "get_stang"
    
    // MARK: - Properties
    private let eventsHandler: GodotEventsHandler
    private var godotInstance: GodotInstance?
    private weak var provider: GodotPluginProvider?
    
    // MARK: - Initialization
    
    init(godotInstance: GodotInstance?, provider: GodotPluginProvider) {
        self.godotInstance = godotInstance
        self.provider = provider
        self.eventsHandler = GodotEventsHandler.shared
        
        print("GodotPluginMaster: Initialized")
        setupGodotCallbacks()
    }
    
    // MARK: - Setup
    
    private func setupGodotCallbacks() {
        // When Godot framework is integrated, register callbacks here
        // For SwiftGodot:
        // - Register signals
        // - Set up script callbacks
        // - Connect to Godot's signal system
        
        print("GodotPluginMaster: Setting up Godot callbacks")
    }
    
    // MARK: - Public Methods (Called from Godot)
    
    /// Called from Godot GDScript to send data to Flutter
    /// Equivalent to: singleton.sendData("string") in xamp.gd
    @objc func sendDataToFlutter(_ data: String) {
        print("GodotPluginMaster: sendData called with: \(data)")
        
        eventsHandler.sendEvent([
            "type": "takeString",
            "data": data
        ])
    }
    
    /// Called from Godot GDScript to navigate back/close view
    /// Equivalent to: singleton.goBack() in xamp.gd
    @objc func goBack() {
        print("GodotPluginMaster: goBack called")
        
        DispatchQueue.main.async { [weak self] in
            self?.eventsHandler.sendSimpleEvent("close_view")
        }
    }
    
    // MARK: - Public Methods (Called from Flutter)
    
    /// Send data from Flutter to Godot
    /// This emits a signal that Godot scripts can listen to
    func sendDataToGodot(_ data: String) {
        print("GodotPluginMaster: Sending data to Godot: \(data)")
        
        guard let godotInstance = godotInstance, godotInstance.isInitialized else {
            print("GodotPluginMaster: ERROR - Godot instance not initialized")
            return
        }
        
        // When Godot framework is integrated, emit signal here
        // For SwiftGodot:
        // godotInstance.emitSignal(SHOW_STRING_SIGNAL, data)
        
        // For now, we'll use a notification pattern
        NotificationCenter.default.post(
            name: NSNotification.Name("GodotReceiveData"),
            object: nil,
            userInfo: ["data": data, "signal": GodotPluginMaster.SHOW_STRING_SIGNAL]
        )
        
        print("GodotPluginMaster: Signal '\(GodotPluginMaster.SHOW_STRING_SIGNAL)' emitted with data: \(data)")
    }
    
    // MARK: - Helper Methods
    
    /// Register this plugin with the Godot engine
    /// Called when Godot initializes
    func registerWithGodot() {
        print("GodotPluginMaster: Registering plugin with Godot")
        
        // When using SwiftGodot or custom framework:
        // 1. Register this class as a Godot singleton
        // 2. Expose methods to GDScript (sendDataToFlutter, goBack)
        // 3. Register signals (get_stang)
        
        // Example pseudo-code for SwiftGodot:
        // Engine.registerSingleton(name: PLUGIN_NAME, instance: self)
        // Engine.addSignal(SHOW_STRING_SIGNAL, withArgs: ["data": String.self])
    }
    
    /// Cleanup when plugin is being destroyed
    func cleanup() {
        print("GodotPluginMaster: Cleaning up")
        godotInstance = nil
    }
}

// MARK: - Godot Script Interface

/// These methods will be exposed to GDScript
/// They need to be callable from Godot scripts like xamp.gd
extension GodotPluginMaster {
    
    /// Get available methods for Godot
    /// These will be exposed to GDScript
    static func getExposedMethods() -> [String] {
        return [
            "sendDataToFlutter",  // Called as: singleton.sendData("string")
            "goBack"              // Called as: singleton.goBack()
        ]
    }
    
    /// Get available signals for Godot
    /// These can be connected to in GDScript
    static func getExposedSignals() -> [String: [String]] {
        return [
            SHOW_STRING_SIGNAL: ["data"]  // Connected as: singleton.connect("get_stang", examp)
        ]
    }
}

