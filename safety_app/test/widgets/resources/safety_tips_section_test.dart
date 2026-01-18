import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pink_flag/widgets/resources/safety_tips_section.dart';

void main() {
  group('SafetyTipsSection', () {
    testWidgets('displays section title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SafetyTipsSection(
                isExpanded: false,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Safety Tips'), findsOneWidget);
    });

    testWidgets('displays lightbulb icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SafetyTipsSection(
                isExpanded: false,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('shows "show" text when collapsed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SafetyTipsSection(
                isExpanded: false,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tap to show safety guidelines'), findsOneWidget);
    });

    testWidgets('shows "hide" text when expanded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SafetyTipsSection(
                isExpanded: true,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tap to hide safety guidelines'), findsOneWidget);
    });

    testWidgets('calls onExpansionChanged when tapped', (WidgetTester tester) async {
      bool? expansionState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SafetyTipsSection(
                isExpanded: false,
                onExpansionChanged: (expanded) => expansionState = expanded,
              ),
            ),
          ),
        ),
      );

      // Tap on the expansion tile
      await tester.tap(find.text('Safety Tips'));
      await tester.pumpAndSettle();

      expect(expansionState, true);
    });

    testWidgets('displays safety tips when expanded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SafetyTipsSection(
                isExpanded: true,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for some of the safety tips
      expect(find.textContaining('Trust your instincts'), findsOneWidget);
      expect(find.textContaining('Share your location'), findsOneWidget);
      expect(find.textContaining('public, well-lit places'), findsOneWidget);
    });

    testWidgets('displays check circle icons for tips when expanded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SafetyTipsSection(
                isExpanded: true,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have 7 check circle icons (one per tip)
      expect(find.byIcon(Icons.check_circle), findsNWidgets(7));
    });
  });
}
