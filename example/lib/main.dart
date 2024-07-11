import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_godot_widget/flutter_godot_widget.dart';
import 'package:flutter_godot_widget/gamewidget.dart';
import 'package:flutter_godot_widget/viewPort.dart';

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

  @override
  void initState() {
    super.initState();
    //initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterGodotWidgetPlugin.getPlatformVersion() ?? 'Unknown platform version';
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
    return MaterialApp(
      home: Gamewidget()
      /*home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(children: [

          TextButton(onPressed:() async{

              await _flutterGodotWidgetPlugin.openGame();
              //await sendData2Game("GUY NAMED DAVE!");

            }, child: Text("openGame")),
          TextButton(onPressed:() async{

              //await openGodot();
              //await _flutterGodotWidgetPlugin.sendData2Game("Sent data from flutter");

            }, child: Text("sendData2Game")),
          Text('Running on: $_platformVersion\n'),
          ],)
          
        ),
      ),*/
    );
  }
}
