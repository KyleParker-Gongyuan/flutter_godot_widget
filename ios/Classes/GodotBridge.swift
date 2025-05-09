import Foundation
import SwiftGodot

class GodotBridge {
  static let shared = GodotBridge()

  func send(message: String) {
    // Call a Godot-exposed singleton/method
    let bridge = Godot.getSingleton(name: "FlutterBridge")
    bridge.call(method: "receive_message", arguments: [Variant(message)])
  }
}
