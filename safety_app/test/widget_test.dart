// Pink Flag - Widget Tests
//
// Basic widget tests for the Pink Flag safety app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pink_flag/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PinkFlagApp());

    // Verify that the app initializes without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const PinkFlagApp());

    // Get the MaterialApp widget
    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify the title
    expect(app.title, 'Pink Flag');
  });
}
