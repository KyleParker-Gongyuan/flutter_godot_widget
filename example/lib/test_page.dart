import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_godot_widget/godot_container.dart';

/// Comprehensive test page for iOS integration testing
/// This allows you to test all communication channels and size conformance
class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  static const methodChannel = MethodChannel("flutter_godot_widget_plugin");
  static const eventStream = EventChannel("kaiyo.ezgodot/generic");
  
  final List<String> logs = [];
  bool showGodot = false;
  double containerWidth = 300;
  double containerHeight = 400;
  int messagesSent = 0;
  int messagesReceived = 0;
  StreamSubscription<dynamic>? _subscription;
  
  @override
  void initState() {
    super.initState();
    startListening();
    addLog("🚀 Test page initialized");
  }
  
  void startListening() {
    addLog("👂 Starting event listener...");
    
    _subscription = eventStream.receiveBroadcastStream().listen(
      (event) {
        messagesReceived++;
        addLog("📥 Received (#$messagesReceived): $event");
        print("TEST: Received from iOS: $event");
      },
      onError: (error) {
        addLog("❌ Error: $error");
      },
    );
  }
  
  void addLog(String message) {
    setState(() {
      logs.insert(0, "[${DateTime.now().toString().substring(11, 19)}] $message");
      if (logs.length > 50) logs.removeLast();
    });
  }
  
  Future<void> sendToGodot(String message) async {
    try {
      await methodChannel.invokeMethod("sendData2Godot", {"data": message});
      messagesSent++;
      addLog("📤 Sent (#$messagesSent): $message");
    } catch (e) {
      addLog("❌ Send error: $e");
    }
  }
  
  Future<void> getPlatformVersion() async {
    try {
      final version = await methodChannel.invokeMethod("getPlatformVersion");
      addLog("ℹ️ Platform: $version");
    } catch (e) {
      addLog("❌ Version error: $e");
    }
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("iOS Integration Test"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            children: [
              // Stats Bar
              _buildStatsBar(),
          
              // Control Panel
              _buildControlPanel(context),
          
              // Godot View
              if (showGodot) _buildGodotView(),
          
              // Logs
              Expanded(child: _buildLogsView()),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatsBar() {
    return Container(
      color: Colors.green.shade50,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("📤 Sent: $messagesSent", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("📥 Received: $messagesReceived", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("📊 Logs: ${logs.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildControlPanel(BuildContext context) {
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Container Size: ${containerWidth.toInt()} x ${containerHeight.toInt()}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text("Width", style: TextStyle(fontSize: 12)),
                    Slider(
                      value: containerWidth,
                      min: 100,
                      max: MediaQuery.of(context).size.width - 40,
                      onChanged: (v) => setState(() => containerWidth = v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text("Height", style: TextStyle(fontSize: 12)),
                    Slider(
                      value: containerHeight,
                      min: 100,
                      max: 600,
                      onChanged: (v) => setState(() => containerHeight = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => showGodot = !showGodot);
                  addLog(showGodot ? "✅ Showing Godot view" : "❌ Hiding Godot view");
                },
                icon: Icon(showGodot ? Icons.visibility_off : Icons.visibility),
                label: Text(showGodot ? "Hide Godot" : "Show Godot"),
              ),
              ElevatedButton.icon(
                onPressed: () => sendToGodot("Test message ${DateTime.now().millisecondsSinceEpoch}"),
                icon: const Icon(Icons.send),
                label: const Text("Send Test"),
              ),
              ElevatedButton.icon(
                onPressed: () => sendToGodot("Hello from Flutter!"),
                icon: const Icon(Icons.message),
                label: const Text("Send Hello"),
              ),
              ElevatedButton.icon(
                onPressed: getPlatformVersion,
                icon: const Icon(Icons.info),
                label: const Text("Get Version"),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    logs.clear();
                    messagesSent = 0;
                    messagesReceived = 0;
                  });
                  addLog("🧹 Logs cleared");
                },
                icon: const Icon(Icons.clear_all),
                label: const Text("Clear"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGodotView() {
    return Container(
      width: containerWidth,
      height: containerHeight,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          const GodotContainer(),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${containerWidth.toInt()}x${containerHeight.toInt()}",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogsView() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Communication Log:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                "${logs.length} entries",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          "No logs yet. Start testing!",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, i) {
                      final log = logs[i];
                      Color bgColor = Colors.white;
                      if (log.contains("📥")) bgColor = Colors.green.shade50;
                      if (log.contains("📤")) bgColor = Colors.blue.shade50;
                      if (log.contains("❌")) bgColor = Colors.red.shade50;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          log,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

