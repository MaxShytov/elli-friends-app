// lib/core/services/audio_manager.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/supported_languages.dart';

/// Central service for managing all audio in the app
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Players
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _animalSoundPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  // Settings
  bool _isMusicEnabled = true;
  bool _areSfxEnabled = true;
  bool _isVoiceEnabled = true;
  double _musicVolume = 0.3;
  double _sfxVolume = 1.0;
  double _voiceVolume = 1.0;

  bool _isInitialized = false;
  String _currentLanguage = 'en';

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
  Future<void> speakDialogue(
    String text, {
    String character = 'bono',
  }) async {
    if (!_isVoiceEnabled) return;

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

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// Change language for TTS
  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _setupTts(languageCode);
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
    await _tts.stop();
  }

  /// Остановить все звуки
  Future<void> stopAll() async {
    await _sfxPlayer.stop();
    await _musicPlayer.stop();
    await _animalSoundPlayer.stop();
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
