import 'flutter_godot_widget_method_channel.dart';

class GodotMessagingTestPage extends StatefulWidget {
  @override
  _GodotMessagingTestPageState createState() => _GodotMessagingTestPageState();
}

class _GodotMessagingTestPageState extends State<GodotMessagingTestPage> {
  final _controller = TextEditingController();
  String _received = '';
  final _godotChannel = MethodChannelFlutterGodotWidget();

  @override
  void initState() {
    super.initState();
    _godotChannel.setOnStringFromNativeHandler((data) {
      setState(() {
        _received = data;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendToNative() async {
    final text = _controller.text;
    final result = await _godotChannel.sendStringToNative(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sent to iOS, result: $result')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Godot iOS Messaging Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Send string to iOS'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendToNative,
              child: Text('Send to iOS'),
            ),
            SizedBox(height: 32),
            Text('Received from iOS:'),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text(_received, style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
} 