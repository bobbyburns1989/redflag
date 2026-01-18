import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pink_flag/widgets/resources/resource_card.dart';

void main() {
  group('ResourceCard', () {
    testWidgets('displays title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ResourceCard(
                icon: Icons.phone,
                title: 'Test Hotline',
                subtitle: 'Test description',
                color: Colors.pink,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Hotline'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('displays phone number when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ResourceCard(
                icon: Icons.phone,
                title: 'Emergency',
                subtitle: 'Call for help',
                phoneNumber: '911',
                color: Colors.pink,
              ),
            ),
          ),
        ),
      );

      expect(find.text('911'), findsOneWidget);
      expect(find.text('Call Now'), findsOneWidget);
    });

    testWidgets('displays additional info when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ResourceCard(
                icon: Icons.message,
                title: 'Crisis Text Line',
                subtitle: 'Text-based support',
                color: Colors.pink,
                additionalInfo: 'Text HOME to 741741',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Text HOME to 741741'), findsOneWidget);
    });

    testWidgets('calls onCall callback when Call Now is tapped', (WidgetTester tester) async {
      String? calledNumber;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ResourceCard(
                icon: Icons.phone,
                title: 'Test',
                subtitle: 'Test',
                phoneNumber: '1-800-123-4567',
                color: Colors.pink,
                onCall: (number) => calledNumber = number,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Call Now'));
      await tester.pump();

      expect(calledNumber, '1-800-123-4567');
    });

    testWidgets('hides Call Now button when no phone number', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ResourceCard(
                icon: Icons.message,
                title: 'Text Only',
                subtitle: 'No phone',
                color: Colors.pink,
                additionalInfo: 'Text only service',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Call Now'), findsNothing);
    });

    testWidgets('displays correct icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ResourceCard(
                icon: Icons.healing,
                title: 'Health Line',
                subtitle: 'Medical support',
                color: Colors.pink,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.healing), findsOneWidget);
    });
  });
}
