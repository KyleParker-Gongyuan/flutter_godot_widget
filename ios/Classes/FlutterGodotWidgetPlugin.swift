import Flutter
import UIKit

/// Main Flutter plugin for Godot widget integration
/// This is the iOS equivalent of the Android FlutterGodotWidgetPlugin.kt
public class FlutterGodotWidgetPlugin: NSObject, FlutterPlugin {
    
    // MARK: - Constants
    
    private static let METHOD_CHANNEL_NAME = "flutter_godot_widget_plugin"
    private static let EVENT_CHANNEL_NAME = "kaiyo.ezgodot/generic"
    private static let PLATFORM_VIEW_TYPE = "godot-view"
    private static let EXTRA_COMMAND_LINE_PARAMS = "command_line_params"
    private static let DEFAULT_WINDOW_ID = 664
    
    // MARK: - Properties
    
    private var registrar: FlutterPluginRegistrar?
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var godotInstance: GodotInstance?
    var commandLineParams: [String] = [] // Internal for protocol conformance
    
    // MARK: - Plugin Registration
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        print("FlutterGodotWidgetPlugin: Registering plugin")
        
        let instance = FlutterGodotWidgetPlugin()
        instance.registrar = registrar
        
        // Setup method channel
        let methodChannel = FlutterMethodChannel(
            name: METHOD_CHANNEL_NAME,
            binaryMessenger: registrar.messenger()
        )
        instance.methodChannel = methodChannel
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        // Setup event channel for Godot -> Flutter communication
        let eventChannel = FlutterEventChannel(
            name: EVENT_CHANNEL_NAME,
            binaryMessenger: registrar.messenger()
        )
        instance.eventChannel = eventChannel
        eventChannel.setStreamHandler(GodotEventsHandler.shared)
        
        // Register platform view factory
        let factory = GodotViewFactory(
            messenger: registrar.messenger(),
            provider: instance
        )
        registrar.register(
            factory,
            withId: PLATFORM_VIEW_TYPE
        )
        
        print("FlutterGodotWidgetPlugin: Registration complete")
    }
    
    // MARK: - FlutterPlugin Method Handler
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("FlutterGodotWidgetPlugin: Method call: \(call.method)")
        
        switch call.method {
        case "getPlatformVersion":
            handleGetPlatformVersion(result: result)
            
        case "sendData2Godot":
            handleSendData2Godot(call: call, result: result)
            
        case "getIntentData":
            handleGetIntentData(result: result)
            
        case "openGame":
            handleOpenGame(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Method Handlers
    
    private func handleGetPlatformVersion(result: @escaping FlutterResult) {
        let version = "iOS " + UIDevice.current.systemVersion
        result(version)
    }
    
    private func handleSendData2Godot(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let data = args["data"] as? String else {
            print("FlutterGodotWidgetPlugin: ERROR - Missing data argument")
            result(FlutterError(
                code: "MISSING_DATA",
                message: "Data argument is missing",
                details: nil
            ))
            return
        }
        
        print("FlutterGodotWidgetPlugin: Received data from Flutter, passing to Godot: \(data)")
        
        // Get Godot instance and send data
        if let godotInstance = godotInstance, godotInstance.isInitialized {
            // Send signal to Godot
            // This will be picked up by the GodotPluginMaster
            NotificationCenter.default.post(
                name: NSNotification.Name("GodotReceiveData"),
                object: nil,
                userInfo: ["data": data, "signal": GodotPluginMaster.SHOW_STRING_SIGNAL]
            )
            
            result("Data sent to Godot: \(data)")
        } else {
            print("FlutterGodotWidgetPlugin: WARNING - Godot not initialized yet")
            result("Godot not initialized")
        }
    }
    
    private func handleGetIntentData(result: @escaping FlutterResult) {
        // iOS doesn't have intents like Android, but we can check UserDefaults or launch options
        // Return data similar to Android's intent extras
        
        let showGodotView = UserDefaults.standard.bool(forKey: "showGodotView")
        let data: [String: Any] = [
            "showGodotView": showGodotView
        ]
        
        result(data)
    }
    
    private func handleOpenGame(result: @escaping FlutterResult) {
        print("FlutterGodotWidgetPlugin: Opening game")
        
        // Signal to show Godot view
        UserDefaults.standard.set(true, forKey: "showGodotView")
        
        result(nil)
    }
    
    // MARK: - Godot Instance Management
    
    private func initializeGodot() {
        guard godotInstance == nil else {
            print("FlutterGodotWidgetPlugin: Godot already initialized")
            return
        }
        
        print("FlutterGodotWidgetPlugin: Initializing Godot instance")
        
        let instance = GodotInstance()
        godotInstance = instance
        
        // When Godot framework is integrated, initialize it here
        // For SwiftGodot:
        // let engine = GodotEngine()
        // engine.initialize(commandLineParams: commandLineParams)
        // instance.godotObject = engine
        
        instance.isInitialized = true
        
        print("FlutterGodotWidgetPlugin: Godot instance created")
    }
    
    deinit {
        print("FlutterGodotWidgetPlugin: Deinitializing")
        godotInstance = nil
    }
}

// MARK: - GodotPluginProvider Implementation

extension FlutterGodotWidgetPlugin: GodotPluginProvider {
    
    var pluginRegistrar: FlutterPluginRegistrar {
        guard let registrar = registrar else {
            fatalError("FlutterGodotWidgetPlugin: Registrar is nil")
        }
        return registrar
    }
    
    func shouldRecreateGodot() -> Bool {
        // For now, never recreate
        // In production, might recreate if context changes
        return false
    }
    
    func getGodotInstance() -> GodotInstance? {
        if godotInstance == nil {
            initializeGodot()
        }
        return godotInstance
    }
}
