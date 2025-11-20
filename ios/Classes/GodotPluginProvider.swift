import Foundation
import Flutter

/// Protocol defining what the Godot plugin provider must supply
protocol GodotPluginProvider: AnyObject {
    /// Get the Flutter plugin registrar
    var pluginRegistrar: FlutterPluginRegistrar { get }
    
    /// Get command line parameters for Godot initialization
    var commandLineParams: [String] { get }
    
    /// Check if Godot needs to be recreated
    func shouldRecreateGodot() -> Bool
    
    /// Get or create the Godot instance
    func getGodotInstance() -> GodotInstance?
}

/// Wrapper class to hold Godot instance and its state
class GodotInstance {
    var isInitialized: Bool = false
    var isRunning: Bool = false
    var rootView: UIView?
    
    // This will hold the actual Godot engine instance once integrated
    // For SwiftGodot: var godotEngine: GodotEngine?
    // For custom framework: var godotViewController: GodotViewController?
    var godotObject: Any?
    
    init() {
        print("GodotInstance: Created new instance")
    }
    
    deinit {
        print("GodotInstance: Deallocated")
    }
}

