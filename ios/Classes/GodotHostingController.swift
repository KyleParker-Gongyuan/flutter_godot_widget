import UIKit
import SwiftGodot

class GodotHostingController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    GodotRuntime.run(gameScene: "res://Main.tscn") { result in
      print("Godot game started with result: \(result)")
    }
  }

  override var prefersStatusBarHidden: Bool { true }
}
