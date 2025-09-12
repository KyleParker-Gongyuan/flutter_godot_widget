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
    return Container(
      key: _containerKey,
      child: _getVDGodotView(),
      // child: _getHybridGodotView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getGodotView();
  }

}
