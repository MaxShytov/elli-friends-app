// Widget tests for Elli & Friends app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elli_friends_app/main.dart';

void main() {
  testWidgets('App launches with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialLocale: Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Elli & Friends'), findsOneWidget);
  });

  testWidgets('App displays welcome message', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialLocale: Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Hello! I\'m Elli!'), findsOneWidget);
    expect(find.text('Let\'s learn together!'), findsOneWidget);
  });

  testWidgets('App has all main navigation buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialLocale: Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
