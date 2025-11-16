// Widget tests for Elli & Friends app

import 'package:flutter_test/flutter_test.dart';

import 'package:elli_friends_app/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Verify app can be instantiated and built
    await tester.pumpWidget(const MyApp());

    // Pump frames to complete initial build
    await tester.pump();

    // Wait a bit for any delayed timers
    await tester.pump(const Duration(milliseconds: 600));

    // If we get here without errors, the app builds successfully
    expect(find.byType(MyApp), findsOneWidget);
  });
}
