// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_godot_widget_example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker/leak_tracker.dart';

void main() {
  testWidgets('Verify Platform version', (WidgetTester tester) async {
    // we wanna check and see if we have any leaks in our system
    // 99% of leaks will be on the native side, idk if this will help us tbh
    LeakTracking.start();
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that platform version is retrieved.
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text &&
                           widget.data!.startsWith('Running on:'),
      ),
      findsOneWidget,
    );
  });
  LeakTracking.stop();
}
