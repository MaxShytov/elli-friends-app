import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';

/// Service for caching TTS-generated audio files
class AudioCacheService {
  final AppDatabase _db;
  String? _cacheDir;

  AudioCacheService(this._db);

  /// Initialize cache directory
  Future<String> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;

    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = p.join(appDir.path, 'audio_cache');

    // Create directory if it doesn't exist
    final dir = Directory(_cacheDir!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return _cacheDir!;
  }

  /// Generate a unique filename for cached audio
  String _generateFileName(int sceneId, String languageCode, String textHash) {
    return 'scene_${sceneId}_${languageCode}_$textHash.mp3';
  }

  /// Generate MD5 hash of text for cache invalidation
  String _hashText(String text) {
    return md5.convert(utf8.encode(text)).toString();
  }

  /// Get cached audio file path if it exists and is valid
  ///
  /// Returns null if audio is not cached or is stale
  Future<String?> getCachedAudioPath({
    required int sceneId,
    required String languageCode,
    required String currentText,
  }) async {
    try {
      // Check database for cached entry
      final cache = await (_db.select(_db.audioCaches)
            ..where((t) => t.sceneId.equals(sceneId))
            ..where((t) => t.languageCode.equals(languageCode)))
          .getSingleOrNull();

      if (cache == null) {
        debugPrint('AudioCache: No cache entry for scene $sceneId, lang $languageCode');
        return null;
      }

      // Check if text has changed (cache is stale)
      final currentHash = _hashText(currentText);
      if (cache.textHash != currentHash) {
        debugPrint('AudioCache: Cache stale for scene $sceneId (hash mismatch)');
        return null;
      }

      // Check if file exists
      final file = File(cache.filePath);
      if (!await file.exists()) {
        debugPrint('AudioCache: File not found: ${cache.filePath}');
        // Clean up orphaned database entry
        await (_db.delete(_db.audioCaches)
              ..where((t) => t.id.equals(cache.id)))
            .go();
        return null;
      }

      debugPrint('AudioCache: Hit for scene $sceneId, lang $languageCode');
      return cache.filePath;
    } catch (e) {
      debugPrint('AudioCache: Error getting cache: $e');
      return null;
    }
  }

  /// Save audio data to cache
  ///
  /// Returns the file path where audio was saved
  Future<String> saveAudio({
    required int sceneId,
    required String languageCode,
    required String character,
    required String text,
    required Uint8List audioData,
    String ttsProvider = 'azure',
  }) async {
    final cacheDir = await _getCacheDir();
    final textHash = _hashText(text);
    final fileName = _generateFileName(sceneId, languageCode, textHash);
    final filePath = p.join(cacheDir, fileName);

    try {
      // Save audio file
      final file = File(filePath);
      await file.writeAsBytes(audioData);

      // Update or insert database entry
      final existingCache = await (_db.select(_db.audioCaches)
            ..where((t) => t.sceneId.equals(sceneId))
            ..where((t) => t.languageCode.equals(languageCode)))
          .getSingleOrNull();

      if (existingCache != null) {
        // Delete old file if different path
        if (existingCache.filePath != filePath) {
          final oldFile = File(existingCache.filePath);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        }

        // Update entry
        await (_db.update(_db.audioCaches)
              ..where((t) => t.id.equals(existingCache.id)))
            .write(AudioCachesCompanion(
          filePath: Value(filePath),
          character: Value(character),
          ttsProvider: Value(ttsProvider),
          generatedAt: Value(DateTime.now()),
          textHash: Value(textHash),
        ));
      } else {
        // Insert new entry
        await _db.into(_db.audioCaches).insert(AudioCachesCompanion(
              sceneId: Value(sceneId),
              languageCode: Value(languageCode),
              character: Value(character),
              filePath: Value(filePath),
              ttsProvider: Value(ttsProvider),
              generatedAt: Value(DateTime.now()),
              textHash: Value(textHash),
            ));
      }

      debugPrint('AudioCache: Saved audio for scene $sceneId, lang $languageCode');
      return filePath;
    } catch (e) {
      debugPrint('AudioCache: Error saving audio: $e');
      rethrow;
    }
  }

  /// Mark cached audio as stale (needs regeneration)
  ///
  /// This doesn't delete the file, just marks it as stale in the database
  Future<void> markAsStale(int sceneId, {String? languageCode}) async {
    try {
      var query = _db.select(_db.audioCaches)
        ..where((t) => t.sceneId.equals(sceneId));

      if (languageCode != null) {
        query = query..where((t) => t.languageCode.equals(languageCode));
      }

      final caches = await query.get();

      for (final cache in caches) {
        // Delete the cache entry (file will be orphaned but that's OK)
        await (_db.delete(_db.audioCaches)
              ..where((t) => t.id.equals(cache.id)))
            .go();
      }

      debugPrint('AudioCache: Marked scene $sceneId as stale');
    } catch (e) {
      debugPrint('AudioCache: Error marking as stale: $e');
    }
  }

  /// Check if audio is stale for a scene/language
  Future<bool> isStale({
    required int sceneId,
    required String languageCode,
    required String currentText,
  }) async {
    final cachedPath = await getCachedAudioPath(
      sceneId: sceneId,
      languageCode: languageCode,
      currentText: currentText,
    );
    return cachedPath == null;
  }

  /// Get cache status for all languages of a scene
  Future<Map<String, bool>> getCacheStatus(int sceneId, Map<String, String> dialogues) async {
    final status = <String, bool>{};

    for (final entry in dialogues.entries) {
      final languageCode = entry.key;
      final text = entry.value;

      final cachedPath = await getCachedAudioPath(
        sceneId: sceneId,
        languageCode: languageCode,
        currentText: text,
      );

      status[languageCode] = cachedPath != null;
    }

    return status;
  }

  /// Clear all cached audio for a scene
  Future<void> clearSceneCache(int sceneId) async {
    try {
      final caches = await (_db.select(_db.audioCaches)
            ..where((t) => t.sceneId.equals(sceneId)))
          .get();

      for (final cache in caches) {
        // Delete file
        final file = File(cache.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Delete database entries
      await (_db.delete(_db.audioCaches)
            ..where((t) => t.sceneId.equals(sceneId)))
          .go();

      debugPrint('AudioCache: Cleared cache for scene $sceneId');
    } catch (e) {
      debugPrint('AudioCache: Error clearing scene cache: $e');
    }
  }

  /// Clear entire audio cache
  Future<void> clearAllCache() async {
    try {
      // Get all cached files
      final caches = await _db.select(_db.audioCaches).get();

      // Delete all files
      for (final cache in caches) {
        final file = File(cache.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Clear database
      await _db.delete(_db.audioCaches).go();

      // Also clean up any orphaned files in cache directory
      final cacheDir = Directory(await _getCacheDir());
      if (await cacheDir.exists()) {
        await for (final file in cacheDir.list()) {
          if (file is File && file.path.endsWith('.mp3')) {
            await file.delete();
          }
        }
      }

      debugPrint('AudioCache: Cleared all cache');
    } catch (e) {
      debugPrint('AudioCache: Error clearing all cache: $e');
    }
  }

  /// Get total cache size in bytes
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      final cacheDir = Directory(await _getCacheDir());

      if (await cacheDir.exists()) {
        await for (final file in cacheDir.list()) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('AudioCache: Error getting cache size: $e');
      return 0;
    }
  }

  /// Get human-readable cache size string
  Future<String> getCacheSizeString() async {
    final bytes = await getCacheSize();

    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
