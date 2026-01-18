import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pink_flag/widgets/search/search_error_banner.dart';

void main() {
  group('SearchErrorBanner', () {
    testWidgets('displays error message when provided', (WidgetTester tester) async {
      const errorMsg = 'Something went wrong';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchErrorBanner(errorMessage: errorMsg),
          ),
        ),
      );

      expect(find.text(errorMsg), findsOneWidget);
    });

    testWidgets('shows error icon when message provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchErrorBanner(errorMessage: 'Error occurred'),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('returns empty widget when errorMessage is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchErrorBanner(errorMessage: null),
          ),
        ),
      );

      // Should find SizedBox.shrink (empty widget)
      expect(find.byType(SizedBox), findsOneWidget);
      // Should not find the error icon
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
    });

    testWidgets('displays long error message correctly', (WidgetTester tester) async {
      const longError = 'This is a very long error message that should wrap properly within the banner container without causing overflow issues';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchErrorBanner(errorMessage: longError),
          ),
        ),
      );

      expect(find.text(longError), findsOneWidget);
      // Text should be in an Expanded widget for proper wrapping
      expect(find.byType(Expanded), findsOneWidget);
    });
  });
}
