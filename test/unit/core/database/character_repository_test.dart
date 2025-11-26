// test/unit/core/database/character_repository_test.dart

import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/core/database/app_database.dart';
import 'package:elli_friends_app/core/database/character_repository.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/character_voice_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CharacterRepository repo;

  // Mock data for default voice profiles
  // basePitch can be int (as in JSON files) - CharacterVoiceProfile.fromVoiceJson handles conversion
  final mockDefaultProfiles = jsonEncode({
    "orson": {
      "en": {
        "voiceName": "en-US-GuyNeural",
        "role": null,
        "basePitch": 0,
        "baseRate": 0.90,
        "defaultStyle": "friendly",
        "defaultStyleDegree": 1.1
      },
      "ru": {
        "voiceName": "ru-RU-DmitryNeural",
        "role": null,
        "basePitch": 0,
        "baseRate": 0.90,
        "defaultStyle": null,
        "defaultStyleDegree": 1.0
      },
    },
    "merv": {
      "en": {
        "voiceName": "en-US-AnaNeural",
        "role": null,
        "basePitch": 5,
        "baseRate": 0.92,
        "defaultStyle": "friendly",
        "defaultStyleDegree": 1.2
      },
    },
  });

  // Mock for rootBundle.loadString
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message == null) return null;
        // Decode the asset key from the message
        final buffer = message.buffer;
        final list = buffer.asUint8List(message.offsetInBytes, message.lengthInBytes);
        final key = utf8.decode(list);

        if (key.contains('default_voice_profiles.json')) {
          final encoded = utf8.encode(mockDefaultProfiles);
          return ByteData.view(Uint8List.fromList(encoded).buffer);
        }
        return null;
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'flutter/assets',
      null,
    );
  });

  setUp(() async {
    // Create in-memory database for testing
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CharacterRepository(db);

    // Seed test characters
    await db.into(db.characters).insert(
      CharactersCompanion.insert(
        characterId: 'orson',
        nameJson: jsonEncode({'en': 'Orson', 'ru': 'Орсон'}),
        emoji: '🦁',
        voiceProfilesJson: jsonEncode({
          'en': {
            'voiceName': 'en-US-GuyNeural',
            'role': null,
            'basePitch': '+0%',
            'baseRate': 0.90,
            'defaultStyle': 'friendly',
            'defaultStyleDegree': 1.1,
          },
          'ru': {
            'voiceName': 'ru-RU-DmitryNeural',
            'role': null,
            'basePitch': '+0%',
            'baseRate': 0.90,
            'defaultStyle': null,
            'defaultStyleDegree': 1.0,
          },
        }),
        color: const Value('#FF9800'),
        isChild: const Value(false),
        isMale: const Value(true),
      ),
    );

    await db.into(db.characters).insert(
      CharactersCompanion.insert(
        characterId: 'merv',
        nameJson: jsonEncode({'en': 'Merv', 'ru': 'Мерв'}),
        emoji: '🧙',
        voiceProfilesJson: jsonEncode({
          'en': {
            'voiceName': 'en-US-AnaNeural',
            'role': null,
            'basePitch': '+5%',
            'baseRate': 0.92,
            'defaultStyle': 'friendly',
            'defaultStyleDegree': 1.2,
          },
        }),
        color: const Value('#9C27B0'),
        isChild: const Value(true),
        isMale: const Value(false),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('CharacterRepository', () {
    group('getVoiceProfile', () {
      test('returns correct profile for Orson EN', () async {
        final profile = await repo.getVoiceProfile('orson', 'en');

        expect(profile, isNotNull);
        expect(profile!.characterId, 'orson');
        expect(profile.languageCode, 'en');
        expect(profile.voiceName, 'en-US-GuyNeural');
        expect(profile.baseRate, 0.90);
        expect(profile.defaultStyle, 'friendly');
        expect(profile.defaultStyleDegree, 1.1);
      });

      test('returns correct profile for Merv EN with child voice', () async {
        final profile = await repo.getVoiceProfile('merv', 'en');

        expect(profile, isNotNull);
        expect(profile!.characterId, 'merv');
        expect(profile.voiceName, 'en-US-AnaNeural');
        expect(profile.baseRate, 0.92);
        expect(profile.defaultStyle, 'friendly');
        expect(profile.defaultStyleDegree, 1.2);
      });

      test('returns null for non-existent character', () async {
        final profile = await repo.getVoiceProfile('unknown', 'en');

        expect(profile, isNull);
      });

      test('returns default profile for unconfigured language', () async {
        final profile = await repo.getVoiceProfile('merv', 'de');

        // Should return a default profile since 'de' is not configured
        expect(profile, isNotNull);
        expect(profile!.languageCode, 'de');
      });
    });

    group('updateVoiceProfile', () {
      test('updates voice profile correctly', () async {
        // Update Orson's EN profile
        await repo.updateVoiceProfile(
          CharacterVoiceProfile(
            characterId: 'orson',
            languageCode: 'en',
            voiceName: 'en-US-AriaNeural', // Changed voice
            basePitch: '+10%',
            baseRate: 0.85,
            defaultStyle: 'cheerful',
            defaultStyleDegree: 1.5,
          ),
        );

        // Verify the update
        final profile = await repo.getVoiceProfile('orson', 'en');
        expect(profile!.voiceName, 'en-US-AriaNeural');
        expect(profile.basePitch, '+10%');
        expect(profile.baseRate, 0.85);
        expect(profile.defaultStyle, 'cheerful');
        expect(profile.defaultStyleDegree, 1.5);
      });

      test('preserves other language profiles when updating one', () async {
        // Update only EN profile
        await repo.updateVoiceProfile(
          CharacterVoiceProfile(
            characterId: 'orson',
            languageCode: 'en',
            voiceName: 'en-US-ChristopherNeural',
            basePitch: '+20%',
            baseRate: 1.5,
            defaultStyleDegree: 2.0,
          ),
        );

        // Verify RU profile is unchanged
        final ruProfile = await repo.getVoiceProfile('orson', 'ru');
        expect(ruProfile!.voiceName, 'ru-RU-DmitryNeural');
        expect(ruProfile.baseRate, 0.90);
      });
    });

    group('resetVoiceProfileToDefault', () {
      test('resets modified profile to default values', () async {
        // First modify the profile
        await repo.updateVoiceProfile(
          CharacterVoiceProfile(
            characterId: 'orson',
            languageCode: 'en',
            voiceName: 'en-US-JennyNeural', // Wrong voice
            basePitch: '+50%',
            baseRate: 2.0,
            defaultStyle: 'angry',
            defaultStyleDegree: 0.5,
          ),
        );

        // Verify modification
        var profile = await repo.getVoiceProfile('orson', 'en');
        expect(profile!.voiceName, 'en-US-JennyNeural');
        expect(profile.basePitch, '+50%');

        // Reset to default
        await repo.resetVoiceProfileToDefault('orson', 'en');

        // Verify reset
        profile = await repo.getVoiceProfile('orson', 'en');
        expect(profile!.voiceName, 'en-US-GuyNeural');
        expect(profile.baseRate, 0.90);
        expect(profile.defaultStyle, 'friendly');
      });
    });

    group('getAllCharacters', () {
      test('returns all seeded characters', () async {
        final characters = await repo.getAllCharacters();

        expect(characters.length, 2);
        expect(characters.map((c) => c.characterId), containsAll(['orson', 'merv']));
      });
    });

    group('getCharacter', () {
      test('returns character by ID', () async {
        final character = await repo.getCharacter('orson');

        expect(character, isNotNull);
        expect(character!.characterId, 'orson');
        expect(character.emoji, '🦁');
        expect(character.isMale, true);
        expect(character.isChild, false);
      });

      test('returns null for non-existent character', () async {
        final character = await repo.getCharacter('unknown');

        expect(character, isNull);
      });
    });

    group('getCharacterName', () {
      test('returns localized name', () async {
        final name = await repo.getCharacterName('orson', 'en');
        expect(name, 'Orson');

        final ruName = await repo.getCharacterName('orson', 'ru');
        expect(ruName, 'Орсон');
      });

      test('falls back to EN when language not available', () async {
        final name = await repo.getCharacterName('merv', 'de'); // DE not configured
        expect(name, 'Merv'); // Falls back to EN
      });
    });
  });
}
