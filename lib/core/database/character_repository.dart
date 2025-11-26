import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../features/lessons/domain/entities/character_voice_profile.dart';
import 'app_database.dart';

/// Repository for managing character data and voice profiles
class CharacterRepository {
  final AppDatabase _db;

  CharacterRepository(this._db);

  // ═══════════════════════════════════════════════════════════════
  // CHARACTER OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Get all characters
  Future<List<Character>> getAllCharacters() {
    return _db.select(_db.characters).get();
  }

  /// Get character by ID
  Future<Character?> getCharacter(String characterId) {
    return (_db.select(_db.characters)
          ..where((c) => c.characterId.equals(characterId)))
        .getSingleOrNull();
  }

  /// Watch all characters (stream)
  Stream<List<Character>> watchAllCharacters() {
    return _db.select(_db.characters).watch();
  }

  /// Check if characters table has data
  Future<bool> hasCharacters() async {
    final count = await _db.managers.characters.count();
    return count > 0;
  }

  // ═══════════════════════════════════════════════════════════════
  // VOICE PROFILE OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Get voice profile for character and language
  ///
  /// Returns null if character doesn't exist.
  /// Returns default profile if language not configured.
  Future<CharacterVoiceProfile?> getVoiceProfile(
    String characterId,
    String languageCode,
  ) async {
    final character = await getCharacter(characterId);
    if (character == null) return null;

    final profiles =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;
    final profileJson = profiles[languageCode] as Map<String, dynamic>?;

    if (profileJson == null) {
      // Return default profile if language not configured
      return CharacterVoiceProfile.defaultFor(
        characterId: characterId,
        languageCode: languageCode,
        isChild: character.isChild,
        isMale: character.isMale,
      );
    }

    return CharacterVoiceProfile.fromVoiceJson(
      characterId: characterId,
      languageCode: languageCode,
      json: profileJson,
    );
  }

  /// Get all voice profiles for a character (all configured languages)
  Future<Map<String, CharacterVoiceProfile>> getAllVoiceProfiles(
    String characterId,
  ) async {
    final character = await getCharacter(characterId);
    if (character == null) return {};

    final profiles =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;
    final result = <String, CharacterVoiceProfile>{};

    for (final entry in profiles.entries) {
      final lang = entry.key;
      final profileJson = entry.value as Map<String, dynamic>;
      result[lang] = CharacterVoiceProfile.fromVoiceJson(
        characterId: characterId,
        languageCode: lang,
        json: profileJson,
      );
    }

    return result;
  }

  /// Get voice profiles for all characters for a specific language
  Future<Map<String, CharacterVoiceProfile>> getVoiceProfilesForLanguage(
    String languageCode,
  ) async {
    final characters = await getAllCharacters();
    final result = <String, CharacterVoiceProfile>{};

    for (final character in characters) {
      final profile = await getVoiceProfile(character.characterId, languageCode);
      if (profile != null) {
        result[character.characterId] = profile;
      }
    }

    return result;
  }

  /// Update voice profile for a specific language
  Future<void> updateVoiceProfile(CharacterVoiceProfile profile) async {
    final character = await getCharacter(profile.characterId);
    if (character == null) {
      debugPrint(
        'CharacterRepository: Cannot update profile - character ${profile.characterId} not found',
      );
      return;
    }

    final profiles =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;

    // Update profile for this language (exclude characterId and languageCode)
    profiles[profile.languageCode] = {
      'voiceName': profile.voiceName,
      if (profile.role != null) 'role': profile.role,
      'basePitch': profile.basePitch,
      'baseRate': profile.baseRate,
      if (profile.defaultStyle != null) 'defaultStyle': profile.defaultStyle,
      'defaultStyleDegree': profile.defaultStyleDegree,
    };

    await (_db.update(_db.characters)
          ..where((c) => c.characterId.equals(profile.characterId)))
        .write(CharactersCompanion(
      voiceProfilesJson: Value(jsonEncode(profiles)),
      updatedAt: Value(DateTime.now()),
    ));

    debugPrint(
      'CharacterRepository: Updated voice profile for ${profile.characterId} (${profile.languageCode})',
    );
  }

  /// Delete voice profile for a specific language
  Future<void> deleteVoiceProfile(
    String characterId,
    String languageCode,
  ) async {
    final character = await getCharacter(characterId);
    if (character == null) return;

    final profiles =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;
    profiles.remove(languageCode);

    await (_db.update(_db.characters)
          ..where((c) => c.characterId.equals(characterId)))
        .write(CharactersCompanion(
      voiceProfilesJson: Value(jsonEncode(profiles)),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ═══════════════════════════════════════════════════════════════
  // CHARACTER CRUD
  // ═══════════════════════════════════════════════════════════════

  /// Insert or update character
  Future<void> upsertCharacter(CharactersCompanion character) async {
    await _db.into(_db.characters).insertOnConflictUpdate(character);
  }

  /// Delete character by ID
  Future<void> deleteCharacter(String characterId) async {
    await (_db.delete(_db.characters)
          ..where((c) => c.characterId.equals(characterId)))
        .go();
  }

  /// Delete all characters
  Future<void> deleteAllCharacters() async {
    await _db.delete(_db.characters).go();
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Get localized character name
  Future<String?> getCharacterName(
    String characterId,
    String languageCode,
  ) async {
    final character = await getCharacter(characterId);
    if (character == null) return null;

    final names = jsonDecode(character.nameJson) as Map<String, dynamic>;
    return names[languageCode] as String? ??
        names['en'] as String? ??
        characterId;
  }

  /// Get character emoji
  Future<String?> getCharacterEmoji(String characterId) async {
    final character = await getCharacter(characterId);
    return character?.emoji;
  }

  /// Get all character IDs
  Future<List<String>> getAllCharacterIds() async {
    final characters = await getAllCharacters();
    return characters.map((c) => c.characterId).toList();
  }

  /// Check if character has voice profile for language
  Future<bool> hasVoiceProfileForLanguage(
    String characterId,
    String languageCode,
  ) async {
    final character = await getCharacter(characterId);
    if (character == null) return false;

    final profiles =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;
    return profiles.containsKey(languageCode);
  }

  /// Get languages configured for a character
  Future<List<String>> getConfiguredLanguages(String characterId) async {
    final character = await getCharacter(characterId);
    if (character == null) return [];

    final profiles =
        jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;
    return profiles.keys.toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // RESET TO DEFAULT
  // ═══════════════════════════════════════════════════════════════

  /// Reset voice profile for character/language to default values
  Future<void> resetVoiceProfileToDefault(
    String characterId,
    String languageCode,
  ) async {
    final defaultProfile = await _loadDefaultProfile(characterId, languageCode);
    if (defaultProfile != null) {
      await updateVoiceProfile(defaultProfile);
      debugPrint(
        'CharacterRepository: Reset $characterId/$languageCode to default',
      );
    } else {
      debugPrint(
        'CharacterRepository: No default profile found for $characterId/$languageCode',
      );
    }
  }

  /// Reset all voice profiles for a character to defaults
  Future<void> resetAllVoiceProfilesToDefault(String characterId) async {
    final defaults = await _loadAllDefaultProfiles(characterId);
    for (final profile in defaults) {
      await updateVoiceProfile(profile);
    }
    debugPrint(
      'CharacterRepository: Reset all profiles for $characterId (${defaults.length} languages)',
    );
  }

  /// Load default profile from assets
  Future<CharacterVoiceProfile?> _loadDefaultProfile(
    String characterId,
    String languageCode,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/default_voice_profiles.json',
      );
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final charDefaults = data[characterId] as Map<String, dynamic>?;
      if (charDefaults == null) return null;

      final langDefaults = charDefaults[languageCode] as Map<String, dynamic>?;
      if (langDefaults == null) return null;

      return CharacterVoiceProfile.fromVoiceJson(
        characterId: characterId,
        languageCode: languageCode,
        json: langDefaults,
      );
    } catch (e) {
      debugPrint('CharacterRepository: Failed to load default profile: $e');
      return null;
    }
  }

  /// Load all default profiles for a character
  Future<List<CharacterVoiceProfile>> _loadAllDefaultProfiles(
    String characterId,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/default_voice_profiles.json',
      );
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final charDefaults = data[characterId] as Map<String, dynamic>?;
      if (charDefaults == null) return [];

      final profiles = <CharacterVoiceProfile>[];
      for (final entry in charDefaults.entries) {
        final langCode = entry.key;
        final langDefaults = entry.value as Map<String, dynamic>;
        profiles.add(CharacterVoiceProfile.fromVoiceJson(
          characterId: characterId,
          languageCode: langCode,
          json: langDefaults,
        ));
      }
      return profiles;
    } catch (e) {
      debugPrint('CharacterRepository: Failed to load default profiles: $e');
      return [];
    }
  }
}
