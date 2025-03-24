import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_godot_widget/flutter_godot_widget.dart';
import 'package:flutter_godot_widget/godot_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterGodotWidgetPlugin = FlutterGodotWidget();
  static const methodChannel = MethodChannel("flutter_godot_widget_plugin");
  bool _showGodotView = false;



  final _eventStream = const EventChannel("kaiyo.ezgodot/generic");
  StreamSubscription<dynamic>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    startEvent();

    getIntentData();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _flutterGodotWidgetPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<Map<String, dynamic>> getIntentData() async {
    try {
      final Map result = await methodChannel.invokeMethod('getIntentData');
      final data = result.map((key, value) => MapEntry(key.toString(), value));
      print("Got intent data: $data");

      setState(() {
        _showGodotView = data.containsKey("showGodotView") && data["showGodotView"] == true;
      });

      return data;
    } on PlatformException catch (e) {
      print("Failed to get intent data: ${e.message}");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Visibility(
                visible: _showGodotView,
                // maintainState: true,
                // maintainAnimation: true,
                child: const GodotContainer(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (_showGodotView) ...[
                      const Expanded(child: Text("Showing Godot View")),
                      ElevatedButton(
                        onPressed: () {
                          unawaited(sendData2Game("Flutter says hello!"));
                        },
                        child: const Text("Flutter 2 Godot"),
                      ),
                    ] else
                      Expanded(
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showGodotView = true;
                              });
                            },
                            child: const Text("Show Godot View"),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendData2Game(String data) async {
    try {
      await methodChannel.invokeMethod("sendData2Godot", {"data": data});
    } catch (e) {
      print("Error sending data to native godot: $e");
    }
  }

  void _handleTakeString(dynamic event) {
    debugPrint("handling takeString");

    //send data to godot after processing
    sendData2Game(event["data"]);

    debugPrint("handled takeString");
  }


  void _handleCloseView() {
    debugPrint("handling close_view");

    setState(() {
      _showGodotView = false;
    });

    debugPrint("handled close_view");
  }

  void startEvent() {
    debugPrint("Started listening for events in SE");

    _eventSubscription = _eventStream.receiveBroadcastStream().listen((dynamic event) {
      // Handle incoming events here
      debugPrint('Received data from GD-Android: $event');

      if (event is Map && event["type"] != null) {
        //  Handle events with type
        switch (event["type"]) {
          case "takeString":
            _handleTakeString(event);
            break;
          default:
            debugPrint("Unknown/Unhandled event type: ${event["type"]}");
            break;
        }
      } else if (event == "close_view") {
        _handleCloseView();
      } else {
        debugPrint("Unknown/Unhandled event: $event");
      }
      // Update UI or perform other actions based on the received event
    }, onError: (error) {
      // Handle any errors here
      debugPrint('Error receiving data from GD-Android: $error');
    });
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _eventSubscription?.cancel();
    super.dispose();
  }
}
