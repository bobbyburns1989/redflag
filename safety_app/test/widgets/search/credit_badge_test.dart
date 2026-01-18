import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pink_flag/widgets/search/credit_badge.dart';

void main() {
  group('CreditBadge', () {
    testWidgets('displays correct credit count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreditBadge(credits: 25),
          ),
        ),
      );

      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('displays zero credits', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreditBadge(credits: 0),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('displays large credit count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreditBadge(credits: 1000),
          ),
        ),
      );

      expect(find.text('1000'), findsOneWidget);
    });

    testWidgets('contains toll icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreditBadge(credits: 10),
          ),
        ),
      );

      expect(find.byIcon(Icons.toll), findsOneWidget);
    });

    testWidgets('renders as a row with icon and text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreditBadge(credits: 50),
          ),
        ),
      );

      // Should find a Row widget containing the icon and text
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });
  });
}
