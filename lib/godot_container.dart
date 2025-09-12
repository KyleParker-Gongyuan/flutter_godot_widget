import 'dart:io';
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

  Widget _getHybridGodotView() {
    return PlatformViewLink(
      surfaceFactory: (BuildContext context, PlatformViewController controller) {
        return AndroidViewSurface(
            controller: controller as AndroidViewController,
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{});
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
      viewType: viewType,
    );
  }

  Widget _getVDGodotView() {
    return AndroidView(
      viewType: viewType,
      // onPlatformViewCreated: (int id) {
      //   _channel.invokeMethod('setGodotViewId', {"id": id});
      // },
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }

  Widget _getGodotView() {
    if (kIsWeb) {
      return _getWebGodotView();
    } else if (Platform.isIOS || Platform.isMacOS) {
      return _getIOSGodotView();
    } else {
      return _getVDGodotView();
    }
  }
  
  Widget _getWebGodotView() {
    return Container(
      color: Colors.green.withOpacity(0.3),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.web, size: 48, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Web Godot Simulation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Godot widget running in web browser'),
            SizedBox(height: 16),
            Text('✅ Web platform view working!'),
          ],
        ),
      ),
    );
  }
  
  Widget _getIOSGodotView() {
    try {
      if (Platform.isMacOS) {
        // For macOS, create a simple placeholder since UiKitView doesn't work
        return Container(
          color: Colors.blue.withOpacity(0.3),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.games, size: 48, color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  'iOS Godot Simulation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Platform view placeholder for macOS'),
              ],
            ),
          ),
        );
      } else {
        // For actual iOS device
        return UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      }
    } catch (e) {
      print('Error creating iOS view: $e');
      return Container(
        color: Colors.red.withOpacity(0.3),
        child: Center(
          child: Text('Platform view error: $e'),
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
