import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test to verify testing setup', (WidgetTester tester) async {
    // Build a test widget with basic scaffolding
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Widget Testing Works'),
          ),
        ),
      ),
    );

    // Verify the widget was built
    expect(find.text('Widget Testing Works'), findsOneWidget);
  });
} 