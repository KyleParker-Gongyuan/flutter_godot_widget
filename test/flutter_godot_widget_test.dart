import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_godot_widget/flutter_godot_widget.dart';
import 'package:flutter_godot_widget/flutter_godot_widget_platform_interface.dart';
import 'package:flutter_godot_widget/flutter_godot_widget_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterGodotWidgetPlatform
    with MockPlatformInterfaceMixin
    implements FlutterGodotWidgetPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> openGame() {
    // TODO: implement openGame
    throw UnimplementedError();
  }

  @override
  Future<String?> sendData2Game(String data) {
    // TODO: implement sendData2Game
    throw UnimplementedError();
  }
}

void main() {
  final FlutterGodotWidgetPlatform initialPlatform = FlutterGodotWidgetPlatform.instance;

  test('$MethodChannelFlutterGodotWidget is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterGodotWidget>());
  });

  test('getPlatformVersion', () async {
    FlutterGodotWidget flutterGodotWidgetPlugin = FlutterGodotWidget();
    MockFlutterGodotWidgetPlatform fakePlatform = MockFlutterGodotWidgetPlatform();
    FlutterGodotWidgetPlatform.instance = fakePlatform;

    expect(await flutterGodotWidgetPlugin.getPlatformVersion(), '42');
  });
}
