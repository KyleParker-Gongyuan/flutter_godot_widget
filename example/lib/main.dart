import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_godot_widget/flutter_godot_widget.dart';
import 'package:flutter_godot_widget/flutter_godot_widget_method_channel.dart';
import 'package:flutter_godot_widget/godot_container.dart';

// Method channel for iOS messaging
class GodotMessaging {
  static const MethodChannel _channel = MethodChannel('flutter_godot_widget/method_channel');
  
  static Future<String?> sendStringToNative(String data) async {
    try {
      final String? result = await _channel.invokeMethod<String>('sendString', {'data': data});
      return result;
    } catch (e) {
      print('Error sending string to iOS: $e');
      return null;
    }
  }
  
  static void setOnStringFromNativeHandler(void Function(String data) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onStringFromNative') {
        final String? data = call.arguments['data'] as String?;
        if (data != null) {
          handler(data);
        }
      }
    });
  }
}

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
  
  // iOS messaging test variables
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _pckNameController = TextEditingController(text: 'game.pck');
  String _receivedMessage = '';

  @override
  void initState() {
    super.initState();
    
    if (!kIsWeb && Platform.isAndroid) {
      startEvent();
      getIntentData();
      // Set up real-time string messaging for Android
      _setupAndroidStringMessaging();
    } else if (!kIsWeb) {
      // Set up iOS messaging handler
      GodotMessaging.setOnStringFromNativeHandler((data) {
        setState(() {
          _receivedMessage = data;
        });
      });
    }
  }

  void _setupAndroidStringMessaging() {
    // Set up the library method channel for real-time messaging
    final libraryChannel = MethodChannelFlutterGodotWidget();
    libraryChannel.setOnStringFromNativeHandler((data) {
      setState(() {
        _receivedMessage = 'Real-time: $data';
      });
    });
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
                      if (!kIsWeb && Platform.isIOS) ...[
                        // iOS messaging UI
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Showing iOS Godot Simulation"),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                        labelText: 'Send to iOS',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                                                ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _sendMessageToiOS,
                                child: const Text("Send"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _pckNameController,
                                  decoration: const InputDecoration(
                                    labelText: '.pck filename',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _setPckName,
                                child: const Text("Set PCK"),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _reloadGodot,
                                child: const Text("Reload"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Received from iOS: $_receivedMessage'),
                            ],
                          ),
                        ),
                                             ] else ...[
                         // Platform-specific UI
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(!kIsWeb && Platform.isAndroid 
                                 ? "Showing Real Android Godot" 
                                 : kIsWeb ? "Showing Web Simulation" : "Showing iOS Godot Simulation"),
                               const SizedBox(height: 8),
                               Row(
                                 children: [
                                   Expanded(
                                     child: TextField(
                                       controller: _messageController,
                                       decoration: InputDecoration(
                                         labelText: !kIsWeb && Platform.isAndroid 
                                           ? 'Send to Godot' 
                                           : kIsWeb ? 'Send to Web Simulation' : 'Send to iOS Simulation',
                                         border: const OutlineInputBorder(),
                                       ),
                                     ),
                                   ),
                                   const SizedBox(width: 8),
                                   ElevatedButton(
                                     onPressed: _sendStringToPlatform,
                                     child: const Text("Send"),
                                   ),
                                 ],
                               ),
                               const SizedBox(height: 8),
                               ElevatedButton(
                                 onPressed: () {
                                   unawaited(sendData2Game("Flutter says hello!"));
                                 },
                                                                      child: Text(!kIsWeb && Platform.isAndroid 
                                   ? "Flutter 2 Godot (Legacy)" 
                                   : kIsWeb ? "Flutter 2 Web (Legacy)" : "Flutter 2 iOS (Legacy)"),
                               ),
                               const SizedBox(height: 8),
                               Text('Received Messages: $_receivedMessage'),
                             ],
                           ),
                         ),
                       ],
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
      if (!kIsWeb && Platform.isAndroid) {
        // Use Android method channel
        await methodChannel.invokeMethod("sendData2Godot", {"data": data});
        print("Data sent to Android Godot: $data");
      } else if (kIsWeb) {
        // Web simulation
        print("Data sent to Web simulation: $data");
        setState(() {
          _receivedMessage = 'Web simulation received: $data';
        });
      } else {
        // For iOS/macOS, use iOS messaging or simulate
        final result = await GodotMessaging.sendStringToNative(data);
        print("Data sent to iOS simulation: $result");
        
        // Simulate receiving a response from iOS "Godot"
        setState(() {
          _receivedMessage = 'iOS Godot received: $data';
        });
      }
    } catch (e) {
      print("Error sending data to native: $e");
    }
  }

  void _sendMessageToiOS() async {
    final String text = _messageController.text;
    if (text.isNotEmpty) {
      try {
        final String? result = await GodotMessaging.sendStringToNative(text);
        print('Message sent successfully: $result');
        _messageController.clear();
        
        // Show success message
        setState(() {
          _receivedMessage = 'Sent: $text, Response: ${result ?? "null"}';
        });
      } catch (e) {
        print('Error sending message: $e');
        setState(() {
          _receivedMessage = 'Error: $e';
        });
      }
    }
  }

  void _sendStringToPlatform() async {
    final String text = _messageController.text;
    if (text.isNotEmpty) {
      try {
        String? result;
        if (!kIsWeb && Platform.isAndroid) {
          // Use Android-specific method channel
          final libraryChannel = MethodChannelFlutterGodotWidget();
          result = await libraryChannel.sendStringToNative(text);
          print('Message sent to Android/Godot: $result');
        } else if (kIsWeb) {
          // Web simulation
          result = 'Web simulation received: $text';
          print('Message simulated on Web: $result');
          
          // Simulate response for web
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _receivedMessage = 'Web Godot says: Hello back to "$text"!';
            });
          });
        } else {
          // For iOS/macOS, simulate the response since we don't have real Godot
          result = 'iOS simulation received: $text';
          print('Message simulated on iOS/macOS: $result');
          
          // Simulate bidirectional messaging - iOS "responds" after a delay
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _receivedMessage = 'iOS Godot says: Hello back to "$text"!';
            });
          });
        }
        
        _messageController.clear();
        
        // Show success message
        setState(() {
          _receivedMessage = 'Sent: $text, Response: ${result ?? "null"}';
        });
      } catch (e) {
        print('Error sending message: $e');
        setState(() {
          _receivedMessage = 'Error: $e';
        });
      }
    }
  }

  void _handleTakeString(dynamic event) {
    debugPrint("handling takeString");

    //send data to godot after processing
    sendData2Game(event["data"]);

    debugPrint("handled takeString");
  }

  void _handleStringMessage(dynamic event) {
    debugPrint("handling stringMessage from Godot");
    
    final String message = event["data"] ?? "";
    setState(() {
      _receivedMessage = 'From Godot: $message';
    });

    debugPrint("handled stringMessage: $message");
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
          case "stringMessage":
            _handleStringMessage(event);
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

  void _setPckName() async {
    final String pckName = _pckNameController.text.trim();
    if (pckName.isNotEmpty) {
      try {
        final result = await _flutterGodotWidgetPlugin.setPckName(pckName);
        print('PCK name set: $result');
        setState(() {
          _receivedMessage = 'PCK name set to: $pckName';
        });
      } catch (e) {
        print('Error setting PCK name: $e');
        setState(() {
          _receivedMessage = 'Error setting PCK name: $e';
        });
      }
    }
  }

  void _reloadGodot() async {
    final String pckName = _pckNameController.text.trim();
    try {
      final result = await _flutterGodotWidgetPlugin.reloadGodot(
        pckName: pckName.isNotEmpty ? pckName : null
      );
      print('Godot reloaded: $result');
      setState(() {
        _receivedMessage = 'Godot reloaded with: ${pckName.isNotEmpty ? pckName : "current PCK"}';
      });
    } catch (e) {
      print('Error reloading Godot: $e');
      setState(() {
        _receivedMessage = 'Error reloading Godot: $e';
      });
    }
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _eventSubscription?.cancel();
    _messageController.dispose();
    _pckNameController.dispose();
    super.dispose();
  }
}
