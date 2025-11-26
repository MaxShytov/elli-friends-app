// test/unit/features/demo/widgets/voice_settings_panel_test.dart
//
// Note: VoiceSettingsPanel uses AppDatabase.instance internally (singleton),
// which makes it difficult to test with mock databases. These tests verify
// basic UI structure and rendering rather than full integration behavior.
// For full integration testing, the widget would need dependency injection.

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/features/demo/widgets/voice_settings_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Suppress drift multiple database warnings in tests
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('VoiceSettingsPanel', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VoiceSettingsPanel(
                characterId: 'orson',
                characterEmoji: '🦁',
                characterName: 'Orson',
              ),
            ),
          ),
        ),
      );

      // Should show loading indicator before any async work completes
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('widget can be instantiated with required parameters', (tester) async {
      // Verify the widget doesn't crash on instantiation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VoiceSettingsPanel(
                characterId: 'test_character',
                characterEmoji: '🐱',
                characterName: 'Test Cat',
              ),
            ),
          ),
        ),
      );

      // Just verify it mounted without crashing
      expect(find.byType(VoiceSettingsPanel), findsOneWidget);
    });

    testWidgets('accepts onProfileSaved callback', (tester) async {
      var callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VoiceSettingsPanel(
                characterId: 'orson',
                characterEmoji: '🦁',
                characterName: 'Orson',
                onProfileSaved: () {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Widget should accept the callback without errors
      expect(find.byType(VoiceSettingsPanel), findsOneWidget);
      // Note: We can't easily trigger the callback without full database integration
      expect(callbackCalled, isFalse);
    });

    testWidgets('is wrapped in a Card widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VoiceSettingsPanel(
                characterId: 'orson',
                characterEmoji: '🦁',
                characterName: 'Orson',
              ),
            ),
          ),
        ),
      );

      // Should be wrapped in a Card
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
