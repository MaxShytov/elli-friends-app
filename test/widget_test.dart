// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elli_friends_app/main.dart';

void main() {
  testWidgets('App launches with correct title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(initialLocale: Locale('en')));

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('Elli & Friends'), findsOneWidget);
  });

  testWidgets('Language can be changed', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp(initialLocale: Locale('en')));
    await tester.pumpAndSettle();

    // Verify English is displayed
    expect(find.text('Hello! I\'m Elli!'), findsOneWidget);

    // Tap settings button
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Select French
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    // Verify French is displayed
    expect(find.text('Bonjour! Je suis Elli!'), findsOneWidget);
  });
}
