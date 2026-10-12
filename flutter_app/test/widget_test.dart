import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:harmfilter/screens/setup_needed_screen.dart';

void main() {
  testWidgets('Setup screen renders the brand and setup guidance',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SetupNeededScreen()),
    );

    expect(find.text('HarmFilter'), findsOneWidget);
    expect(find.text('Add your Supabase keys'), findsOneWidget);
  });
}
