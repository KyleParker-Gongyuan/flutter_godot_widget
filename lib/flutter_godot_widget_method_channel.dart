import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_godot_widget_platform_interface.dart';

/// An implementation of [FlutterGodotWidgetPlatform] that uses method channels.
class MethodChannelFlutterGodotWidget extends FlutterGodotWidgetPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_godot_widget');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  @override
  Future<void> openGame() async {
    
    //final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    //startEvent();
    await methodChannel.invokeMethod("openGame");//GodotHandler("ad");
    print('Result from Android: WE STARTED GODOT');
    
  }
  
  @override
  Future<String?> sendData2Game(String data) async {
    try {
      await methodChannel.invokeMethod("sendData2Godot", {"data": data});
      return "a";
    } catch (e) {
      print("Error sending data to native godot: $e");
      return "";
    }
    return"";
  }

  /// Send a string to native platform (iOS/Android)
  Future<String?> sendStringToNative(String data) async {
    try {
      final result = await methodChannel.invokeMethod<String>('sendString', {'data': data});
      return result;
    } catch (e) {
      print('Error sending string to native: $e');
      return null;
    }
  }

  /// Register a callback to receive strings from native platform
  void setOnStringFromNativeHandler(void Function(String data) handler) {
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'onStringFromNative') {
        final data = call.arguments['data'] as String?;
        if (data != null) {
          handler(data);
        }
      }
    });
  }

  @override
  Future<String?> setPckName(String pckName) async {
    try {
      final result = await methodChannel.invokeMethod<String>('setPckName', {'pckName': pckName});
      return result;
    } catch (e) {
      print('Error setting PCK name: $e');
      return null;
    }
  }

  @override
  Future<String?> reloadGodot({String? pckName}) async {
    try {
      final Map<String, dynamic> args = {};
      if (pckName != null) {
        args['pckName'] = pckName;
      }
      final result = await methodChannel.invokeMethod<String>('reloadGodot', args);
      return result;
    } catch (e) {
      print('Error reloading Godot: $e');
      return null;
    }
  }
}