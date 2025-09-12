
import 'flutter_godot_widget_platform_interface.dart';

class FlutterGodotWidget {
  Future<String?> getPlatformVersion() {
    return FlutterGodotWidgetPlatform.instance.getPlatformVersion();
  }
  
  Future<void> openGame() {
    return FlutterGodotWidgetPlatform.instance.openGame();
  }
  
  Future<String?> sendData2Game(String data) {
    return FlutterGodotWidgetPlatform.instance.sendData2Game(data);
  }
  
  /// Set the .pck file name to load (does not reload the engine)
  /// Example: await flutterGodotWidget.setPckName("mygame.pck");
  Future<String?> setPckName(String pckName) {
    return FlutterGodotWidgetPlatform.instance.setPckName(pckName);
  }
  
  /// Reload the Godot engine with the specified .pck file
  /// If pckName is not provided, uses the currently set pck name or "game.pck" as default
  /// Example: await flutterGodotWidget.reloadGodot(pckName: "newgame.pck");
  Future<String?> reloadGodot({String? pckName}) {
    return FlutterGodotWidgetPlatform.instance.reloadGodot(pckName: pckName);
  }
}
