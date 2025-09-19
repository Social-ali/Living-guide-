import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:living_guide/main.dart'; // ✅ Make sure this matches your project name in pubspec.yaml

void main() {
  testWidgets('Main screen loads with Home tab by default', (WidgetTester tester) async {
    // Load the app
    await tester.pumpWidget(const LivingGuideApp());

    // Wait for rendering
    await tester.pumpAndSettle();

    // Check that the HomeScreen content is visible
    expect(find.textContaining('Home'), findsWidgets); // Adjust if you have a specific widget/text

    // Check bottom navigation bar items exist
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.dashboard), findsOneWidget);
    expect(find.byIcon(Icons.photo), findsOneWidget);
    expect(find.byIcon(Icons.info), findsOneWidget);
    expect(find.byIcon(Icons.contact_mail), findsOneWidget);
  });
}
