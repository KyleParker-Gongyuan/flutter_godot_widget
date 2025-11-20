import Flutter
import Foundation

/// Factory for creating GodotView platform views
/// This is the iOS equivalent of the Android GodotViewFactory.kt
class GodotViewFactory: NSObject, FlutterPlatformViewFactory {
    
    // MARK: - Properties
    
    private weak var provider: GodotPluginProvider?
    private let messenger: FlutterBinaryMessenger
    
    // MARK: - Initialization
    
    init(messenger: FlutterBinaryMessenger, provider: GodotPluginProvider) {
        self.messenger = messenger
        self.provider = provider
        super.init()
        print("GodotViewFactory: Initialized")
    }
    
    // MARK: - FlutterPlatformViewFactory
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        print("GodotViewFactory: Creating GodotView with id: \(viewId)")
        
        guard let provider = provider else {
            fatalError("GodotViewFactory: Provider is nil, cannot create GodotView")
        }
        
        return GodotView(
            frame: frame,
            viewId: viewId,
            args: args,
            provider: provider
        )
    }
    
    /// Return the message codec for creation arguments
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

