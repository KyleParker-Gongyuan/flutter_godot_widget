import 'package:flutter/material.dart';
import 'dart:async';

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
  static const methodChannel = MethodChannel("com.kaiyo.ezgodot/method/start");
  bool _showNativeView = false;

  double _width = 300.0; // Default width for resizable widget
  double _height = 300.0; // Default height for resizable widget

  final _eventStream = const EventChannel("kaiyo.ezgodot/generic");
  StreamSubscription<dynamic>? _eventSubscription;


  @override
  void initState() {
    super.initState();
    startEvent();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _flutterGodotWidgetPlugin.getPlatformVersion() ??
          'Unknown platform version';
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

  @override
  Widget build(BuildContext context) {
    double _width = 300.0; // Use the passed width or default to 300.0
    double _height = 300.0; // Use the passed height or default to 300.0

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PlatformView Example'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showNativeView = true;
                    });
                  },
                  child: const Text('Show Godot View'),
                ),
                if (_showNativeView)
                  Padding(
                    padding: const EdgeInsets.all(
                        16.0), // Add padding around the view
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        // Update the width and height when the user drags to resize
                        setState(() {
                          _width += details.delta.dx;
                          _height += details.delta.dy;

                          _width = _width.clamp(
                              100.0, MediaQuery.of(context).size.width - 20);
                          _height = _height.clamp(
                              100.0, MediaQuery.of(context).size.height - 20);
                        });
                      },
                      child: SizedBox(
                        width: _width,
                        height: _height,
                        child: GodotContainer(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // godot
  //!{column[
  // "header"={row:[
  // pic of bot/us (do we wanna change this if a human is on the line?),
  // name of bot,
  // options of our chat,
  // exit btn
  // ]},
  // 
  //this will have a list of msgs,
  // maybe have btns a user can click for what their issue is ("❓ question ❓", "➕ feature request incl➕", "🐞 report bug 🐞")
  //?   depending on what btn they press it will help us on how to respond and shit like that
  // {row:[
  //  textbox,
  //  send btn
  // ]},
  //! maybe we should have a way for us to view a users issue (eg a live video inside the app?)
  //? we need inapp reporting
  //]}

  Future<void> sendData2Game(String data) async {
    try {
      await methodChannel.invokeMethod("sendData2Godot", {"data": data});
    } catch (e) {
      print("Error sending data to native godot: $e");
    }
  }

  void TakeString() {
    String data = "";
    print("Function to take String and process it");
    //send data to godot after processing
    /*sendData2Game(data);*/
  }

  /*Stream<dynamic> networkStream(){return _eventStream.receiveBroadcastStream().distinct().map((dynamic event) {
    debugPrint("flutter data: $event");
    return event;

  });}*/

  void startEvent() {
    print("Started listening for events in SE");
    _eventSubscription =
        _eventStream.receiveBroadcastStream().listen((dynamic event) {
      // Handle incoming events here
      print('Received data from GD-Android: $event');
      if (event == "close_view") {
        // Hide the native view and show the Flutter view again
        setState(() {
          _showNativeView = false;
        });
      } else if (event == "TakeString") {
        TakeString();
      }
      // Update UI or perform other actions based on the received event
    }, onError: (error) {
      // Handle any errors here
      print('Error receiving data from GD-Android: $error');
    });
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _eventSubscription?.cancel();
    super.dispose();
  }
}
