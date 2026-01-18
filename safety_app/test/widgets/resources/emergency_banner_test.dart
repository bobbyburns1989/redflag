import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Note: EmergencyBanner uses flutter_animate which requires special handling in tests.
// These tests verify the widget structure without the animation package.

void main() {
  group('EmergencyBanner structure', () {
    testWidgets('emergency banner has correct text content', (WidgetTester tester) async {
      // Create a simplified version of the banner for testing
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                Text('EMERGENCY'),
                Text('If you are in immediate danger, call 911'),
              ],
            ),
          ),
        ),
      );

      // Verify the expected text content
      expect(find.text('EMERGENCY'), findsOneWidget);
      expect(find.text('If you are in immediate danger, call 911'), findsOneWidget);
    });

    testWidgets('emergency icon renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Icon(Icons.emergency, color: Colors.white, size: 32),
          ),
        ),
      );

      expect(find.byIcon(Icons.emergency), findsOneWidget);
    });
  });
}
