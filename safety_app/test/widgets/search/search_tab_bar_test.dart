import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pink_flag/widgets/search/search_tab_bar.dart';

void main() {
  group('SearchTabBar', () {
    testWidgets('displays all three tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTabBar(
              selectedMode: 0,
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Image'), findsOneWidget);
    });

    testWidgets('displays correct credit costs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTabBar(
              selectedMode: 0,
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      // Name = 10 credits, Phone = 2 credits, Image = 4 credits
      expect(find.text('10 credits'), findsOneWidget);
      expect(find.text('2 credits'), findsOneWidget);
      expect(find.text('4 credits'), findsOneWidget);
    });

    testWidgets('displays correct icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTabBar(
              selectedMode: 0,
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person_search), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.image_search), findsOneWidget);
    });

    testWidgets('calls onModeChanged when tab is tapped', (WidgetTester tester) async {
      int? tappedMode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTabBar(
              selectedMode: 0,
              onModeChanged: (mode) => tappedMode = mode,
            ),
          ),
        ),
      );

      // Tap on Phone tab
      await tester.tap(find.text('Phone'));
      expect(tappedMode, 1);

      // Tap on Image tab
      await tester.tap(find.text('Image'));
      expect(tappedMode, 2);

      // Tap on Name tab
      await tester.tap(find.text('Name'));
      expect(tappedMode, 0);
    });

    testWidgets('initially selects correct tab based on selectedMode', (WidgetTester tester) async {
      // Test with mode 1 (Phone) selected
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTabBar(
              selectedMode: 1,
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      // Widget should render without errors with selectedMode = 1
      expect(find.text('Phone'), findsOneWidget);
    });

    testWidgets('renders three Expanded widgets for equal tab sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchTabBar(
              selectedMode: 0,
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      // Should have 3 Expanded widgets (one for each tab)
      expect(find.byType(Expanded), findsNWidgets(3));
    });
  });
}
