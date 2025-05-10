import Flutter
import UIKit
import SwiftGodot

public class FlutterGodotWidgetPlugin: NSObject, FlutterPlugin {
  var godotView: UIView?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_godot_widget", binaryMessenger: registrar.messenger())
    let instance = FlutterGodotWidgetPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    case "openGame":
      openGodotGame()
      result(nil)

    case "sendData2Godot":
      if let args = call.arguments as? [String: Any],
         let data = args["data"] as? String {
        sendMessageToGodot(data)
      }
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func openGodotGame() {
    // Assuming SwiftGodot or a prebuilt Godot iOS view controller
    DispatchQueue.main.async {
      if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
        let godotVC = GodotHostingController()
        rootVC.present(godotVC, animated: true, completion: nil)
      }
    }
  }

  func sendMessageToGodot(_ message: String) {
    // You must define a SwiftGodot-exposed node or singleton to handle this
    GodotBridge.shared.send(message: message)
  }
}
