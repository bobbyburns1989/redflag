import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pink_flag/widgets/resources/additional_resources_section.dart';

void main() {
  group('AdditionalResourcesSection', () {
    testWidgets('displays section title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AdditionalResourcesSection(
                isExpanded: false,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Additional Resources'), findsOneWidget);
    });

    testWidgets('displays info icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AdditionalResourcesSection(
                isExpanded: false,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows "show more" text when collapsed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AdditionalResourcesSection(
                isExpanded: false,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tap to show more helplines'), findsOneWidget);
    });

    testWidgets('shows "hide" text when expanded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AdditionalResourcesSection(
                isExpanded: true,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tap to hide more helplines'), findsOneWidget);
    });

    testWidgets('calls onExpansionChanged when tapped', (WidgetTester tester) async {
      bool? expansionState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AdditionalResourcesSection(
                isExpanded: false,
                onExpansionChanged: (expanded) => expansionState = expanded,
              ),
            ),
          ),
        ),
      );

      // Tap on the expansion tile
      await tester.tap(find.text('Additional Resources'));
      await tester.pumpAndSettle();

      expect(expansionState, true);
    });

    testWidgets('displays hotline information when expanded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AdditionalResourcesSection(
                isExpanded: true,
                onExpansionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for the hotline names
      expect(find.text('National Center for Missing & Exploited Children'), findsOneWidget);
      expect(find.text('Childhelp National Child Abuse Hotline'), findsOneWidget);
      expect(find.text('National Human Trafficking Hotline'), findsOneWidget);
    });
  });
}
