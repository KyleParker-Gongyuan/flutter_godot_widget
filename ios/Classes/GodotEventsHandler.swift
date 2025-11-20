import Flutter
import Foundation

/// Handles event streaming from Godot to Flutter
/// Singleton pattern to maintain a single event stream across the application
class GodotEventsHandler: NSObject, FlutterStreamHandler {
    
    // MARK: - Singleton
    static let shared = GodotEventsHandler()
    
    // MARK: - Properties
    private var eventSink: FlutterEventSink?
    private var isListening: Bool = false
    private let lock = NSLock()
    
    private override init() {
        super.init()
        print("GodotEventsHandler: Initialized")
    }
    
    // MARK: - FlutterStreamHandler
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        lock.lock()
        defer { lock.unlock() }
        
        print("GodotEventsHandler: onListen - starting listening")
        
        if isListening {
            print("GodotEventsHandler: Already listening for events, ignoring duplicate request")
            return nil
        }
        
        eventSink = events
        isListening = true
        
        print("GodotEventsHandler: Event listening started successfully")
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        lock.lock()
        defer { lock.unlock() }
        
        print("GodotEventsHandler: onCancel - stopping Godot event listening")
        
        isListening = false
        eventSink = nil
        
        return nil
    }
    
    // MARK: - Public Methods
    
    /// Send an event to Flutter
    /// - Parameter event: Dictionary containing event data
    func sendEvent(_ event: [String: Any]) {
        lock.lock()
        let sink = eventSink
        let listening = isListening
        lock.unlock()
        
        guard listening else {
            print("GodotEventsHandler: Attempted to send event while not listening: \(event)")
            return
        }
        
        guard let sink = sink else {
            print("GodotEventsHandler: EventSink is null, cannot send event")
            return
        }
        
        // Must send on main thread for Flutter
        DispatchQueue.main.async {
            sink(event)
            if let eventType = event["type"] as? String {
                print("GodotEventsHandler: Event sent to Flutter: \(eventType)")
            }
        }
    }
    
    /// Send a simple string event to Flutter (for backward compatibility)
    /// - Parameter message: String message to send
    func sendSimpleEvent(_ message: String) {
        lock.lock()
        let sink = eventSink
        let listening = isListening
        lock.unlock()
        
        guard listening else {
            print("GodotEventsHandler: Attempted to send event while not listening: \(message)")
            return
        }
        
        guard let sink = sink else {
            print("GodotEventsHandler: EventSink is null, cannot send event")
            return
        }
        
        DispatchQueue.main.async {
            sink(message)
            print("GodotEventsHandler: Simple event sent to Flutter: \(message)")
        }
    }
    
    /// Send an error to Flutter
    /// - Parameters:
    ///   - code: Error code
    ///   - message: Error message
    ///   - details: Additional error details
    func sendError(code: String, message: String?, details: Any?) {
        lock.lock()
        let sink = eventSink
        lock.unlock()
        
        guard let sink = sink else {
            print("GodotEventsHandler: EventSink is null, cannot send error")
            return
        }
        
        DispatchQueue.main.async {
            sink(FlutterError(code: code, message: message, details: details))
            print("GodotEventsHandler: Error sent to Flutter: \(code)")
        }
    }
}

