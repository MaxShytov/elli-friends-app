// lib/core/services/audio_manager.dart

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/lessons/domain/entities/character_voice_profile.dart';
import '../../features/lessons/domain/entities/dialogue_voice_context.dart';
import '../constants/supported_languages.dart';
import '../database/character_repository.dart';
import 'audio_cache_service.dart';
import 'azure_tts_service.dart';
import 'hybrid_audio_service.dart';

/// Central service for managing all audio in the app
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Players
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _animalSoundPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer(); // For cached audio playback
  final FlutterTts _tts = FlutterTts();

  // Audio cache service (optional - set via setAudioCacheService)
  AudioCacheService? _audioCacheService;

  // Character repository for voice profiles (optional - set via setCharacterRepository)
  CharacterRepository? _characterRepository;

  // Azure TTS service (optional - set via setAzureTtsService)
  AzureTtsService? _azureTtsService;

  // Hybrid audio service (optional - set via setHybridAudioService)
  HybridAudioService? _hybridAudioService;

  // Current lesson ID for hybrid audio
  String? _currentLessonId;

  // Cached voice profiles per character (for current language)
  final Map<String, CharacterVoiceProfile> _voiceProfiles = {};

  // Settings
  bool _isMusicEnabled = true;
  bool _areSfxEnabled = true;
  bool _isVoiceEnabled = true;
  double _musicVolume = 0.3;
  double _sfxVolume = 1.0;
  double _voiceVolume = 1.0;

  bool _isInitialized = false;
  String _currentLanguage = 'en';

  /// Set audio cache service for cached TTS playback
  void setAudioCacheService(AudioCacheService service) {
    _audioCacheService = service;
  }

  /// Set character repository for loading voice profiles
  void setCharacterRepository(CharacterRepository repository) {
    _characterRepository = repository;
  }

  /// Set Azure TTS service for high-quality voice generation
  void setAzureTtsService(AzureTtsService service) {
    _azureTtsService = service;
  }

  /// Set hybrid audio service for bundled + cached + generated audio
  void setHybridAudioService(HybridAudioService service) {
    _hybridAudioService = service;
  }

  /// Set current lesson ID for hybrid audio lookups
  void setCurrentLesson(String lessonId) {
    _currentLessonId = lessonId;
  }

  /// Load voice profiles for all characters in current language
  ///
  /// Call this after setting character repository and changing language
  Future<void> loadVoiceProfiles() async {
    if (_characterRepository == null) {
      debugPrint('AudioManager: CharacterRepository not set, skipping voice profile loading');
      return;
    }

    try {
      final profiles = await _characterRepository!.getVoiceProfilesForLanguage(_currentLanguage);
      _voiceProfiles.clear();
      _voiceProfiles.addAll(profiles);
      debugPrint('AudioManager: Loaded ${profiles.length} voice profiles for $_currentLanguage');
    } catch (e) {
      debugPrint('AudioManager: Error loading voice profiles: $e');
    }
  }

  /// Get voice profile for a character (from cache or default)
  CharacterVoiceProfile? getVoiceProfile(String characterId) {
    return _voiceProfiles[characterId.toLowerCase()];
  }

  /// Initialize audio system with language
  Future<void> initialize({String languageCode = 'en'}) async {
    if (_isInitialized) return;

    _currentLanguage = languageCode;
    await _setupTts(languageCode);

    // Setup music player (loop)
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);

    // Setup sound effects (don't loop)
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _sfxPlayer.setVolume(_sfxVolume);

    // Setup animal sounds
    await _animalSoundPlayer.setReleaseMode(ReleaseMode.stop);
    await _animalSoundPlayer.setVolume(_sfxVolume);

    _isInitialized = true;
  }

  /// Setup Text-to-Speech with language
  Future<void> _setupTts(String languageCode) async {
    final ttsLanguage = SupportedLanguages.getTtsLanguageCode(languageCode);

    await _tts.setLanguage(ttsLanguage);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(_voiceVolume);
    await _tts.setPitch(1.0);

    // iOS specific - skip on web
    try {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
      );
    } catch (e) {
      // Ignore on web and other platforms
    }
  }

  // ==================== ОЗВУЧКА ДИАЛОГОВ ====================

  /// Озвучить диалог персонажа
  ///
  /// Приоритет воспроизведения:
  /// 1. HybridAudioService (bundled → cached → generated) если настроен
  /// 2. Кэшированное аудио (AudioCacheService) если есть sceneId
  /// 3. Azure TTS с voice profile (если настроен)
  /// 4. Системный TTS (fallback)
  Future<void> speakDialogue(
    String text, {
    String character = 'bono',
    int? sceneId,
    String? tone,
  }) async {
    if (!_isVoiceEnabled) return;

    // Try HybridAudioService first (bundled → cached → generated)
    if (_hybridAudioService != null && _currentLessonId != null && sceneId != null) {
      final result = await _hybridAudioService!.getAudioForDialogue(
        lessonId: _currentLessonId!,
        sceneIndex: sceneId,
        character: character,
        text: text,
        languageCode: _currentLanguage,
        tone: tone,
      );

      if (result.hasAudio) {
        debugPrint('AudioManager: Playing ${result.sourceType.name} audio for scene $sceneId');
        if (result.audioPath != null) {
          await _playCachedAudio(result.audioPath!);
          return;
        } else if (result.audioData != null) {
          await _playAudioData(result.audioData!);
          return;
        }
      }
    }

    // Try legacy AudioCacheService if sceneId is provided
    if (sceneId != null && _audioCacheService != null) {
      final cachedPath = await _audioCacheService!.getCachedAudioPath(
        sceneId: sceneId,
        languageCode: _currentLanguage,
        currentText: text,
      );

      if (cachedPath != null) {
        debugPrint('AudioManager: Playing legacy cached audio for scene $sceneId');
        await _playCachedAudio(cachedPath);
        return;
      }
    }

    // Try Azure TTS with voice profile
    final profile = getVoiceProfile(character);
    if (profile != null && _azureTtsService != null) {
      // Create voice context from tone if provided
      final context = tone != null ? DialogueVoiceContext.fromTone(tone) : null;

      final success = await _speakWithAzureTts(text, profile: profile, context: context);
      if (success) return;
    }

    // Fallback to system TTS
    await _speakWithSystemTts(text, character: character);
  }

  /// Озвучить диалог с полной поддержкой voice profiles
  ///
  /// Это РЕКОМЕНДУЕМЫЙ метод для использования с новой системой голосов.
  ///
  /// Приоритет воспроизведения:
  /// 1. Кэшированное аудио (если есть sceneId)
  /// 2. Azure TTS с profile и context
  /// 3. Системный TTS (fallback)
  Future<void> speakDialogueWithProfile(
    String text, {
    required CharacterVoiceProfile profile,
    DialogueVoiceContext? context,
    int? sceneId,
  }) async {
    if (!_isVoiceEnabled) return;

    // Try cached audio first if sceneId is provided
    if (sceneId != null && _audioCacheService != null) {
      final cachedPath = await _audioCacheService!.getCachedAudioPath(
        sceneId: sceneId,
        languageCode: _currentLanguage,
        currentText: text,
      );

      if (cachedPath != null) {
        debugPrint('AudioManager: Playing cached audio for scene $sceneId');
        await _playCachedAudio(cachedPath);
        return;
      }
    }

    // Try Azure TTS with voice profile
    if (_azureTtsService != null) {
      final success = await _speakWithAzureTts(text, profile: profile, context: context);
      if (success) return;
    }

    // Fallback to system TTS
    await _speakWithSystemTts(text, character: profile.characterId);
  }

  /// Speak using Azure TTS with voice profile
  ///
  /// Returns true if successful, false if failed (to allow fallback)
  Future<bool> _speakWithAzureTts(
    String text, {
    required CharacterVoiceProfile profile,
    DialogueVoiceContext? context,
  }) async {
    if (_azureTtsService == null) return false;

    try {
      debugPrint('AudioManager: Generating Azure TTS for "${text.substring(0, text.length > 30 ? 30 : text.length)}..." '
          'with voice ${profile.voiceName}');

      final audioData = await _azureTtsService!.generateAudioWithProfile(
        text: text,
        profile: profile,
        context: context,
      );

      // Play the generated audio
      await _voicePlayer.stop();
      await _voicePlayer.setVolume(_voiceVolume);
      await _voicePlayer.play(BytesSource(audioData));

      return true;
    } catch (e) {
      debugPrint('AudioManager: Azure TTS failed: $e, falling back to system TTS');
      return false;
    }
  }

  /// Play cached audio file
  Future<void> _playCachedAudio(String filePath) async {
    try {
      await _voicePlayer.stop();
      await _voicePlayer.setVolume(_voiceVolume);
      await _voicePlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      debugPrint('AudioManager: Error playing cached audio: $e');
    }
  }

  /// Play audio from bytes (e.g., bundled assets or generated audio)
  ///
  /// On iOS, BytesSource is not supported, so we save to a temp file first
  Future<void> _playAudioData(Uint8List audioData) async {
    try {
      await _voicePlayer.stop();
      await _voicePlayer.setVolume(_voiceVolume);

      // On iOS, BytesSource is not supported, so save to temp file
      if (Platform.isIOS || Platform.isMacOS) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await tempFile.writeAsBytes(audioData);
        await _voicePlayer.play(DeviceFileSource(tempFile.path));
        // Clean up temp file after a delay (audio should be done by then)
        Future.delayed(const Duration(seconds: 30), () {
          tempFile.delete().ignore();
        });
      } else {
        // On Android/Web, BytesSource should work
        await _voicePlayer.play(BytesSource(audioData));
      }
    } catch (e) {
      debugPrint('AudioManager: Error playing audio data: $e');
    }
  }

  /// Speak using system TTS
  Future<void> _speakWithSystemTts(String text, {String character = 'bono'}) async {
    // Разные настройки голоса для персонажей
    switch (character.toLowerCase()) {
      case 'bono':
        await _tts.setPitch(0.9); // Ниже - мудрый слон
        await _tts.setSpeechRate(0.45);
        break;
      case 'orson':
      case 'орсон':
        await _tts.setPitch(0.95); // Чуть выше чем Bono - дружелюбный кот
        await _tts.setSpeechRate(0.35); // Медленнее для детей
        break;
      case 'merv':
      case 'мерв':
        await _tts.setPitch(1.05); // Средне-высокий - мудрый волшебник
        await _tts.setSpeechRate(0.33); // Медленнее для детей
        break;
      case 'hippo':
      case 'гиппо':
        await _tts.setPitch(1.2); // Выше - весёлый бегемот
        await _tts.setSpeechRate(0.5);
        break;
      case 'elli':
      case 'элли':
        await _tts.setPitch(1.1); // Средний - дружелюбный слон
        await _tts.setSpeechRate(0.48);
        break;
      default:
        await _tts.setPitch(1.0);
        await _tts.setSpeechRate(0.45);
    }

    try {
      await _tts.speak(text);
    } catch (e) {
      // Если flutter_tts не работает, пытаемся использовать нативный API
      // (только для Web платформы)
      debugPrint('TTS error: $e. Text: $text, Language: $_currentLanguage');
    }
  }

  /// Stop speaking (both cached audio and TTS)
  Future<void> stopSpeaking() async {
    await _voicePlayer.stop();
    await _tts.stop();
  }

  /// Change language for TTS
  ///
  /// This also reloads voice profiles for the new language
  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _setupTts(languageCode);
    // Reload voice profiles for new language
    await loadVoiceProfiles();
  }

  /// Get current language
  String get currentLanguage => _currentLanguage;

  // ==================== ЗВУКОВЫЕ ЭФФЕКТЫ ====================

  /// Проиграть звуковой эффект
  Future<void> playSfx(SoundEffect effect) async {
    if (!_areSfxEnabled) return;

    final String path = _getSfxPath(effect);
    await _sfxPlayer.play(AssetSource(path));
  }

  /// Получить путь к звуковому эффекту
  String _getSfxPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.correct:
        return 'audio/sfx/correct.mp3';
      case SoundEffect.wrong:
        return 'audio/sfx/wrong.mp3';
      case SoundEffect.click:
        return 'audio/sfx/click.mp3';
      case SoundEffect.star:
        return 'audio/sfx/star.mp3';
      case SoundEffect.success:
        return 'audio/sfx/success.mp3';
      case SoundEffect.hint:
        return 'audio/sfx/hint.mp3';
      case SoundEffect.wow:
        return 'audio/sfx/wow.mp3';
    }
  }

  // ==================== ЗВУКИ ЖИВОТНЫХ ====================

  /// Проиграть звук животного
  Future<void> playAnimalSound(AnimalSound animal) async {
    if (!_areSfxEnabled) return;

    final String path = _getAnimalSoundPath(animal);
    await _animalSoundPlayer.play(AssetSource(path));
  }

  /// Получить путь к звуку животного
  String _getAnimalSoundPath(AnimalSound animal) {
    switch (animal) {
      case AnimalSound.butterfly:
        return 'audio/animals/butterfly.mp3';
      case AnimalSound.monkey:
        return 'audio/animals/monkey.mp3';
      case AnimalSound.bird:
        return 'audio/animals/bird.mp3';
      case AnimalSound.turtle:
        return 'audio/animals/turtle.mp3';
      case AnimalSound.frog:
        return 'audio/animals/frog.mp3';
    }
  }

  // ==================== ФОНОВАЯ МУЗЫКА ====================

  /// Проиграть фоновую музыку
  Future<void> playBackgroundMusic(BackgroundMusic music) async {
    if (!_isMusicEnabled) return;

    final String path = _getMusicPath(music);
    await _musicPlayer.play(AssetSource(path));
  }

  /// Остановить фоновую музыку
  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  /// Приглушить музыку (например, когда говорит персонаж)
  Future<void> duckMusic() async {
    await _musicPlayer.setVolume(_musicVolume * 0.3);
  }

  /// Вернуть громкость музыки
  Future<void> unduckMusic() async {
    await _musicPlayer.setVolume(_musicVolume);
  }

  /// Получить путь к музыкальному файлу
  String _getMusicPath(BackgroundMusic music) {
    switch (music) {
      case BackgroundMusic.jungleAmbient:
        return 'audio/music/jungle_ambient.mp3';
      case BackgroundMusic.lessonBackground:
        return 'audio/music/lesson_background.mp3';
      case BackgroundMusic.celebration:
        return 'audio/music/celebration.mp3';
    }
  }

  // ==================== НАСТРОЙКИ ====================

  /// Включить/выключить музыку
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
    }
  }

  /// Включить/выключить звуковые эффекты
  void setSfxEnabled(bool enabled) {
    _areSfxEnabled = enabled;
  }

  /// Включить/выключить озвучку
  void setVoiceEnabled(bool enabled) {
    _isVoiceEnabled = enabled;
    if (!enabled) {
      _voicePlayer.stop();
      _tts.stop();
    }
  }

  /// Установить громкость музыки (0.0 - 1.0)
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_musicVolume);
  }

  /// Установить громкость эффектов (0.0 - 1.0)
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
    await _animalSoundPlayer.setVolume(_sfxVolume);
  }

  /// Установить громкость голоса (0.0 - 1.0)
  Future<void> setVoiceVolume(double volume) async {
    _voiceVolume = volume.clamp(0.0, 1.0);
    await _voicePlayer.setVolume(_voiceVolume);
    await _tts.setVolume(_voiceVolume);
  }

  // Геттеры для настроек
  bool get isMusicEnabled => _isMusicEnabled;
  bool get areSfxEnabled => _areSfxEnabled;
  bool get isVoiceEnabled => _isVoiceEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  double get voiceVolume => _voiceVolume;

  // ==================== ОЧИСТКА ====================

  /// Остановить все звуки и очистить ресурсы
  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _musicPlayer.dispose();
    await _animalSoundPlayer.dispose();
    await _voicePlayer.dispose();
    await _tts.stop();
  }

  /// Остановить все звуки
  Future<void> stopAll() async {
    await _sfxPlayer.stop();
    await _musicPlayer.stop();
    await _animalSoundPlayer.stop();
    await _voicePlayer.stop();
    await _tts.stop();
  }
}

// ==================== ПЕРЕЧИСЛЕНИЯ ====================

/// Звуковые эффекты UI
enum SoundEffect {
  correct,  // Правильный ответ
  wrong,    // Неправильный ответ
  click,    // Клик по кнопке
  star,     // Получение звезды
  success,  // Завершение урока
  hint,     // Подсказка
  wow,      // Восклицание "Wow!" при правильном ответе
}

/// Звуки животных
enum AnimalSound {
  butterfly,  // Бабочка
  monkey,     // Обезьяна
  bird,       // Птица
  turtle,     // Черепаха
  frog,       // Лягушка
}

/// Фоновая музыка
enum BackgroundMusic {
  jungleAmbient,      // Атмосфера джунглей
  lessonBackground,   // Фон для урока
  celebration,        // Праздничная музыка
}
