// lib/core/services/hybrid_audio_service.dart

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../features/lessons/domain/entities/character_voice_profile.dart';
import '../../features/lessons/domain/entities/dialogue_voice_context.dart';
import '../database/app_database.dart';
import '../database/character_repository.dart';
import 'azure_tts_service.dart';

/// Audio source type for debugging and analytics
enum AudioSourceType {
  /// Pre-bundled audio from assets
  bundled,

  /// Cached audio (previously generated)
  cached,

  /// Freshly generated from Azure TTS
  generated,

  /// Fallback (system TTS will be used)
  fallback,
}

/// Result of getting audio for a dialogue
class HybridAudioResult {
  /// Path to audio file (null if fallback)
  final String? audioPath;

  /// Source type for this audio
  final AudioSourceType sourceType;

  /// Whether audio data is in memory (BytesSource) vs file path
  final Uint8List? audioData;

  /// Error message if generation failed
  final String? error;

  const HybridAudioResult({
    this.audioPath,
    required this.sourceType,
    this.audioData,
    this.error,
  });

  bool get hasAudio => audioPath != null || audioData != null;
  bool get isFallback => sourceType == AudioSourceType.fallback;
}

/// Service for hybrid audio management
///
/// This service combines three audio sources:
/// 1. **Bundled** - Pre-generated audio files shipped with the app
/// 2. **Cached** - Audio generated on-demand and cached locally
/// 3. **Generated** - Fresh audio generated via Azure TTS
///
/// Priority order: Bundled > Cached > Generated > Fallback (system TTS)
///
/// ## Usage Example
/// ```dart
/// final hybridAudio = HybridAudioService(
///   db: AppDatabase.instance,
///   characterRepository: characterRepository,
///   azureTtsService: azureTtsService, // optional
/// );
///
/// final result = await hybridAudio.getAudioForDialogue(
///   lessonId: 'counting',
///   sceneIndex: 0,
///   character: 'orson',
///   text: 'Hello!',
///   languageCode: 'en',
///   tone: 'friendly',
/// );
///
/// if (result.hasAudio) {
///   if (result.audioPath != null) {
///     // Play from file
///     player.play(DeviceFileSource(result.audioPath!));
///   } else if (result.audioData != null) {
///     // Play from memory
///     player.play(BytesSource(result.audioData!));
///   }
/// } else {
///   // Use system TTS fallback
///   tts.speak(text);
/// }
/// ```
class HybridAudioService {
  // ignore: unused_field - reserved for future use (audio cache metadata in DB)
  final AppDatabase _db;
  final CharacterRepository _characterRepository;
  final AzureTtsService? _azureTtsService;

  /// Cache directory for generated audio
  String? _cacheDir;

  /// In-memory cache for voice profiles (per language)
  final Map<String, Map<String, CharacterVoiceProfile>> _voiceProfileCache = {};

  HybridAudioService({
    required AppDatabase db,
    required CharacterRepository characterRepository,
    AzureTtsService? azureTtsService,
  })  : _db = db,
        _characterRepository = characterRepository,
        _azureTtsService = azureTtsService;

  // ═══════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════

  /// Get audio for a dialogue line
  ///
  /// Tries sources in order: Bundled > Cached > Generated
  /// Returns [HybridAudioResult] with audio path/data or fallback indicator
  Future<HybridAudioResult> getAudioForDialogue({
    required String lessonId,
    required int sceneIndex,
    required String character,
    required String text,
    required String languageCode,
    String? tone,
  }) async {
    // 1. Try bundled audio first
    final bundledResult = await _tryBundledAudio(
      lessonId: lessonId,
      sceneIndex: sceneIndex,
      languageCode: languageCode,
      text: text,
    );
    if (bundledResult != null) {
      debugPrint('HybridAudio: Using bundled audio for $lessonId/$sceneIndex/$languageCode');
      return bundledResult;
    }

    // 2. Try cached audio
    final cachedResult = await _tryCachedAudio(
      lessonId: lessonId,
      sceneIndex: sceneIndex,
      languageCode: languageCode,
      text: text,
    );
    if (cachedResult != null) {
      debugPrint('HybridAudio: Using cached audio for $lessonId/$sceneIndex/$languageCode');
      return cachedResult;
    }

    // 3. Try to generate new audio
    if (_azureTtsService != null) {
      final generatedResult = await _tryGenerateAudio(
        lessonId: lessonId,
        sceneIndex: sceneIndex,
        character: character,
        text: text,
        languageCode: languageCode,
        tone: tone,
      );
      if (generatedResult != null) {
        debugPrint('HybridAudio: Generated new audio for $lessonId/$sceneIndex/$languageCode');
        return generatedResult;
      }
    }

    // 4. Fallback to system TTS
    debugPrint('HybridAudio: Falling back to system TTS for $lessonId/$sceneIndex/$languageCode');
    return const HybridAudioResult(
      sourceType: AudioSourceType.fallback,
      error: 'No audio source available',
    );
  }

  /// Pre-warm cache for a lesson (download/generate all audio)
  ///
  /// This can be called when user selects a lesson to pre-cache all audio
  Future<PrewarmResult> prewarmLesson({
    required String lessonId,
    required List<DialogueInfo> dialogues,
    void Function(int current, int total)? onProgress,
  }) async {
    int success = 0;
    int failed = 0;
    int skipped = 0;

    for (int i = 0; i < dialogues.length; i++) {
      final dialogue = dialogues[i];
      onProgress?.call(i, dialogues.length);

      // Check if already cached or bundled
      final existing = await _tryBundledAudio(
        lessonId: lessonId,
        sceneIndex: dialogue.sceneIndex,
        languageCode: dialogue.languageCode,
        text: dialogue.text,
      );

      if (existing != null) {
        skipped++;
        continue;
      }

      final cached = await _tryCachedAudio(
        lessonId: lessonId,
        sceneIndex: dialogue.sceneIndex,
        languageCode: dialogue.languageCode,
        text: dialogue.text,
      );

      if (cached != null) {
        skipped++;
        continue;
      }

      // Generate and cache
      if (_azureTtsService != null) {
        final result = await _tryGenerateAudio(
          lessonId: lessonId,
          sceneIndex: dialogue.sceneIndex,
          character: dialogue.character,
          text: dialogue.text,
          languageCode: dialogue.languageCode,
          tone: dialogue.tone,
        );

        if (result != null && result.hasAudio) {
          success++;
        } else {
          failed++;
        }
      } else {
        failed++;
      }
    }

    onProgress?.call(dialogues.length, dialogues.length);

    return PrewarmResult(
      total: dialogues.length,
      success: success,
      failed: failed,
      skipped: skipped,
    );
  }

  /// Check audio availability for a lesson
  Future<LessonAudioStatus> checkLessonAudioStatus({
    required String lessonId,
    required List<DialogueInfo> dialogues,
  }) async {
    int bundled = 0;
    int cached = 0;
    int missing = 0;

    for (final dialogue in dialogues) {
      final bundledExists = await _bundledAudioExists(
        lessonId: lessonId,
        sceneIndex: dialogue.sceneIndex,
        languageCode: dialogue.languageCode,
      );

      if (bundledExists) {
        bundled++;
        continue;
      }

      final cachedExists = await _cachedAudioExists(
        lessonId: lessonId,
        sceneIndex: dialogue.sceneIndex,
        languageCode: dialogue.languageCode,
        text: dialogue.text,
      );

      if (cachedExists) {
        cached++;
      } else {
        missing++;
      }
    }

    return LessonAudioStatus(
      total: dialogues.length,
      bundled: bundled,
      cached: cached,
      missing: missing,
    );
  }

  /// Clear cached audio for a lesson
  Future<void> clearLessonCache(String lessonId) async {
    try {
      final cacheDir = await _getCacheDir();
      final lessonDir = Directory(p.join(cacheDir, lessonId));

      if (await lessonDir.exists()) {
        await lessonDir.delete(recursive: true);
        debugPrint('HybridAudio: Cleared cache for lesson $lessonId');
      }
    } catch (e) {
      debugPrint('HybridAudio: Error clearing lesson cache: $e');
    }
  }

  /// Clear all cached audio
  Future<void> clearAllCache() async {
    try {
      final cacheDir = Directory(await _getCacheDir());
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
        debugPrint('HybridAudio: Cleared all cache');
      }
    } catch (e) {
      debugPrint('HybridAudio: Error clearing all cache: $e');
    }
  }

  /// Get total cache size
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      final cacheDir = Directory(await _getCacheDir());

      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('HybridAudio: Error getting cache size: $e');
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE: BUNDLED AUDIO
  // ═══════════════════════════════════════════════════════════════

  /// Try to get bundled audio from assets
  Future<HybridAudioResult?> _tryBundledAudio({
    required String lessonId,
    required int sceneIndex,
    required String languageCode,
    required String text,
  }) async {
    final assetPath = _getBundledAssetPath(lessonId, sceneIndex, languageCode);
    debugPrint('HybridAudio: Looking for bundled audio at: $assetPath');

    try {
      // Check if asset exists by trying to load it
      final data = await rootBundle.load(assetPath);
      debugPrint('HybridAudio: Found bundled audio at: $assetPath (${data.lengthInBytes} bytes)');

      // Verify content hash matches (optional, for cache invalidation)
      // For now, we trust bundled assets

      return HybridAudioResult(
        audioData: data.buffer.asUint8List(),
        sourceType: AudioSourceType.bundled,
      );
    } catch (e) {
      // Asset doesn't exist
      debugPrint('HybridAudio: Bundled audio not found at: $assetPath');
      return null;
    }
  }

  /// Check if bundled audio exists (without loading)
  Future<bool> _bundledAudioExists({
    required String lessonId,
    required int sceneIndex,
    required String languageCode,
  }) async {
    final assetPath = _getBundledAssetPath(lessonId, sceneIndex, languageCode);

    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get asset path for bundled audio
  ///
  /// Format: assets/audio/lessons/{lessonId}/{languageCode}/scene_{index}.mp3
  String _getBundledAssetPath(String lessonId, int sceneIndex, String languageCode) {
    return 'assets/audio/lessons/$lessonId/$languageCode/scene_$sceneIndex.mp3';
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE: CACHED AUDIO
  // ═══════════════════════════════════════════════════════════════

  /// Try to get cached audio from local storage
  Future<HybridAudioResult?> _tryCachedAudio({
    required String lessonId,
    required int sceneIndex,
    required String languageCode,
    required String text,
  }) async {
    final filePath = await _getCachedFilePath(
      lessonId: lessonId,
      sceneIndex: sceneIndex,
      languageCode: languageCode,
      text: text,
    );

    final file = File(filePath);
    if (await file.exists()) {
      return HybridAudioResult(
        audioPath: filePath,
        sourceType: AudioSourceType.cached,
      );
    }

    return null;
  }

  /// Check if cached audio exists
  Future<bool> _cachedAudioExists({
    required String lessonId,
    required int sceneIndex,
    required String languageCode,
    required String text,
  }) async {
    final filePath = await _getCachedFilePath(
      lessonId: lessonId,
      sceneIndex: sceneIndex,
      languageCode: languageCode,
      text: text,
    );

    return File(filePath).exists();
  }

  /// Get cache file path
  ///
  /// Format: {cacheDir}/{lessonId}/{languageCode}/scene_{index}_{textHash}.mp3
  Future<String> _getCachedFilePath({
    required String lessonId,
    required int sceneIndex,
    required String languageCode,
    required String text,
  }) async {
    final cacheDir = await _getCacheDir();
    final textHash = _hashText(text);
    return p.join(cacheDir, lessonId, languageCode, 'scene_${sceneIndex}_$textHash.mp3');
  }

  /// Save audio to cache
  Future<String> _saveToCache({
    required String lessonId,
    required int sceneIndex,
    required String languageCode,
    required String text,
    required Uint8List audioData,
  }) async {
    final filePath = await _getCachedFilePath(
      lessonId: lessonId,
      sceneIndex: sceneIndex,
      languageCode: languageCode,
      text: text,
    );

    // Create directory if needed
    final dir = Directory(p.dirname(filePath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Write file
    final file = File(filePath);
    await file.writeAsBytes(audioData);

    return filePath;
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE: AUDIO GENERATION
  // ═══════════════════════════════════════════════════════════════

  /// Try to generate audio via Azure TTS
  Future<HybridAudioResult?> _tryGenerateAudio({
    required String lessonId,
    required int sceneIndex,
    required String character,
    required String text,
    required String languageCode,
    String? tone,
  }) async {
    if (_azureTtsService == null) return null;

    try {
      // Get voice profile for character
      final profile = await _getVoiceProfile(character, languageCode);
      if (profile == null) {
        debugPrint('HybridAudio: No voice profile for $character/$languageCode');
        return null;
      }

      // Create voice context from tone
      final context = tone != null ? DialogueVoiceContext.fromTone(tone) : null;

      // Generate audio (service is already null-checked above)
      final audioData = await _azureTtsService.generateAudioWithProfile(
        text: text,
        profile: profile,
        context: context,
      );

      // Save to cache
      final filePath = await _saveToCache(
        lessonId: lessonId,
        sceneIndex: sceneIndex,
        languageCode: languageCode,
        text: text,
        audioData: audioData,
      );

      return HybridAudioResult(
        audioPath: filePath,
        sourceType: AudioSourceType.generated,
      );
    } catch (e) {
      debugPrint('HybridAudio: Error generating audio: $e');
      return HybridAudioResult(
        sourceType: AudioSourceType.fallback,
        error: e.toString(),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE: HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Get cache directory
  Future<String> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;

    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = p.join(appDir.path, 'hybrid_audio_cache');

    final dir = Directory(_cacheDir!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return _cacheDir!;
  }

  /// Get voice profile for character (with caching)
  Future<CharacterVoiceProfile?> _getVoiceProfile(String character, String languageCode) async {
    // Check memory cache
    final langCache = _voiceProfileCache[languageCode];
    if (langCache != null && langCache.containsKey(character)) {
      return langCache[character];
    }

    // Load from repository
    final profile = await _characterRepository.getVoiceProfile(character, languageCode);

    // Cache it
    if (profile != null) {
      _voiceProfileCache[languageCode] ??= {};
      _voiceProfileCache[languageCode]![character] = profile;
    }

    return profile;
  }

  /// Hash text for cache key
  String _hashText(String text) {
    return md5.convert(utf8.encode(text)).toString().substring(0, 8);
  }
}

// ═══════════════════════════════════════════════════════════════
// DATA CLASSES
// ═══════════════════════════════════════════════════════════════

/// Information about a dialogue for prewarming
class DialogueInfo {
  final int sceneIndex;
  final String character;
  final String text;
  final String languageCode;
  final String? tone;

  const DialogueInfo({
    required this.sceneIndex,
    required this.character,
    required this.text,
    required this.languageCode,
    this.tone,
  });
}

/// Result of prewarming a lesson
class PrewarmResult {
  final int total;
  final int success;
  final int failed;
  final int skipped;

  const PrewarmResult({
    required this.total,
    required this.success,
    required this.failed,
    required this.skipped,
  });

  bool get isComplete => success + skipped == total;
  double get progress => total > 0 ? (success + skipped) / total : 0;

  @override
  String toString() => 'PrewarmResult(total: $total, success: $success, failed: $failed, skipped: $skipped)';
}

/// Audio status for a lesson
class LessonAudioStatus {
  final int total;
  final int bundled;
  final int cached;
  final int missing;

  const LessonAudioStatus({
    required this.total,
    required this.bundled,
    required this.cached,
    required this.missing,
  });

  int get available => bundled + cached;
  bool get isComplete => missing == 0;
  double get coverage => total > 0 ? available / total : 0;

  @override
  String toString() => 'LessonAudioStatus(total: $total, bundled: $bundled, cached: $cached, missing: $missing)';
}
