import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GodotContainer extends StatefulWidget {
  @override
  _GodotContainerState createState() => _GodotContainerState();
}

class _GodotContainerState extends State<GodotContainer> {
  final GlobalKey _containerKey = GlobalKey();
  static const MethodChannel _channel = MethodChannel('flutter_godot_widget_plugin');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateGodotView(constraints);
        });

        return Container(
          key: _containerKey,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: AndroidView(
            viewType: 'platform-view-type',
            layoutDirection: TextDirection.ltr,
            creationParamsCodec: StandardMessageCodec(),
          ),
        );
      },
    );
  }

  /// Godot View, We pass its size and position to the native code
  Future<void> _updateGodotView(constraints) async {
    RenderBox? box = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    Offset position = box.localToGlobal(Offset.zero);
    // Size size = box.size;
    
    await _channel.invokeMethod('setGodotViewPositionAndSize', {
      "x": position.dx, // X location
      "y": position.dy, // Y location
      "width": constraints.maxWidth.toString() == 'Infinity' ? null : constraints.maxWidth, // width
      "height": constraints.maxHeight.toString() == 'Infinity' ? null : constraints.maxHeight, // Height
    });
  }
}
