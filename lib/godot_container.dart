import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class GodotContainer extends StatefulWidget {
  const GodotContainer({super.key});

  @override
  _GodotContainerState createState() => _GodotContainerState();
}

class _GodotContainerState extends State<GodotContainer> {
  final GlobalKey _containerKey = GlobalKey();
  static const MethodChannel _channel = MethodChannel('flutter_godot_widget_plugin');
  final String viewType = 'godot-view';
  final Map<String, dynamic> creationParams = <String, dynamic>{};

  Widget _getIOSGodotView() {
    // iOS-specific platform view
    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }

  Widget _getAndroidGodotView() {
    // Android-specific platform view
    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }

  Widget _getGodotView() {
    // Platform-aware view selection
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _getIOSGodotView();
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return _getAndroidGodotView();
    } else {
      // Fallback for other platforms
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Godot view not supported on this platform',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _containerKey,
      child: _getGodotView(),
    );
  }

}
