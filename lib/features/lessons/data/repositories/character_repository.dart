import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/character_voice_profile.dart';

/// Repository for managing character data and voice profiles
class CharacterRepository {
  final AppDatabase db;

  CharacterRepository(this.db);

  /// Get all characters
  Future<List<Character>> getAllCharacters() async {
    return await db.select(db.characters).get();
  }

  /// Get character by ID
  Future<Character?> getCharacter(String characterId) async {
    return await (db.select(db.characters)
          ..where((c) => c.characterId.equals(characterId)))
        .getSingleOrNull();
  }

  /// Get localized name for character
  Future<String> getCharacterName(String characterId, String languageCode) async {
    final character = await getCharacter(characterId);
    if (character == null) return characterId;

    final nameJson = jsonDecode(character.nameJson) as Map<String, dynamic>;
    return nameJson[languageCode] as String? ??
        nameJson['en'] as String? ??
        characterId;
  }

  /// Get voice profile for character and language
  Future<CharacterVoiceProfile?> getVoiceProfile(
    String characterId,
    String languageCode,
  ) async {
    final character = await getCharacter(characterId);
    if (character == null) return null;

    final profilesJson =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;
    final profileData = profilesJson[languageCode] as Map<String, dynamic>?;

    if (profileData == null) {
      // Fallback to English if available
      final enProfile = profilesJson['en'] as Map<String, dynamic>?;
      if (enProfile == null) return null;

      return CharacterVoiceProfile.fromJson({
        ...enProfile,
        'characterId': characterId,
        'languageCode': 'en',
      });
    }

    return CharacterVoiceProfile.fromJson({
      ...profileData,
      'characterId': characterId,
      'languageCode': languageCode,
    });
  }

  /// Get all voice profiles for a character (all languages)
  Future<Map<String, CharacterVoiceProfile>> getAllVoiceProfiles(
    String characterId,
  ) async {
    final character = await getCharacter(characterId);
    if (character == null) return {};

    final profilesJson =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;

    final result = <String, CharacterVoiceProfile>{};
    for (final entry in profilesJson.entries) {
      final profileData = entry.value as Map<String, dynamic>;
      result[entry.key] = CharacterVoiceProfile.fromJson({
        ...profileData,
        'characterId': characterId,
        'languageCode': entry.key,
      });
    }

    return result;
  }

  /// Update voice profile for character and language
  Future<void> updateVoiceProfile(
    String characterId,
    String languageCode,
    CharacterVoiceProfile profile,
  ) async {
    final character = await getCharacter(characterId);
    if (character == null) {
      throw Exception('Character not found: $characterId');
    }

    final profilesJson =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;

    // Update the profile for this language
    profilesJson[languageCode] = {
      'voiceName': profile.voiceName,
      if (profile.role != null) 'role': profile.role,
      'basePitch': profile.basePitch,
      'baseRate': profile.baseRate,
      if (profile.defaultStyle != null) 'defaultStyle': profile.defaultStyle,
      'defaultStyleDegree': profile.defaultStyleDegree,
    };

    // Save to database
    await (db.update(db.characters)
          ..where((c) => c.characterId.equals(characterId)))
        .write(CharactersCompanion(
      voiceProfilesJson: Value(jsonEncode(profilesJson)),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Get list of language codes that have voice profiles for a character
  Future<List<String>> getConfiguredLanguages(String characterId) async {
    final character = await getCharacter(characterId);
    if (character == null) return [];

    final profilesJson =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;
    return profilesJson.keys.toList();
  }

  /// Check if character has voice profile for language
  Future<bool> hasVoiceProfile(String characterId, String languageCode) async {
    final character = await getCharacter(characterId);
    if (character == null) return false;

    final profilesJson =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;
    return profilesJson.containsKey(languageCode);
  }

  /// Get character emoji
  Future<String> getCharacterEmoji(String characterId) async {
    final character = await getCharacter(characterId);
    return character?.emoji ?? '❓';
  }

  /// Get character color (hex string)
  Future<String> getCharacterColor(String characterId) async {
    final character = await getCharacter(characterId);
    return character?.color ?? '#FF9800';
  }

  /// Check if character is a child character
  Future<bool> isChildCharacter(String characterId) async {
    final character = await getCharacter(characterId);
    return character?.isChild ?? false;
  }

  /// Check if character is male
  Future<bool> isMaleCharacter(String characterId) async {
    final character = await getCharacter(characterId);
    return character?.isMale ?? false;
  }

  /// Stream of all characters (for reactive UI)
  Stream<List<Character>> watchAllCharacters() {
    return db.select(db.characters).watch();
  }

  /// Stream of single character (for reactive UI)
  Stream<Character?> watchCharacter(String characterId) {
    return (db.select(db.characters)
          ..where((c) => c.characterId.equals(characterId)))
        .watchSingleOrNull();
  }
}
