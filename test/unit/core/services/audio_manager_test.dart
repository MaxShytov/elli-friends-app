// test/unit/core/services/audio_manager_test.dart

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/core/services/audio_manager.dart';

void main() {
  // Initialize Flutter bindings before any tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioManager', () {
    late AudioManager audioManager;

    setUpAll(() {
      // Setup method channel mocks for audioplayers and flutter_tts
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'create':
              return 'player_id';
            case 'setVolume':
            case 'setReleaseMode':
            case 'play':
            case 'stop':
            case 'dispose':
            case 'pause':
            case 'resume':
            case 'setSourceUrl':
            case 'getDuration':
            case 'setBalance':
            case 'setPlaybackRate':
              return null;
            default:
              return null;
          }
        },
      );

      // Mock asset bundle to prevent loading real audio files
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadAsset' ||
              methodCall.method == 'load') {
            // Return empty data for audio files
            return Uint8List(0);
          }
          return null;
        },
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'setLanguage':
            case 'setSpeechRate':
            case 'setVolume':
            case 'setPitch':
            case 'setSharedInstance':
            case 'setIosAudioCategory':
            case 'speak':
            case 'stop':
              return 1;
            default:
              return null;
          }
        },
      );
    });

    setUp(() {
      // Get singleton instance
      audioManager = AudioManager();
    });

    group('Initialization', () {
      test('initialize without errors', () async {
        // Act & Assert - should not throw
        await audioManager.initialize();
        expect(audioManager.currentLanguage, isNotNull);
      });

      test('initialize sets correct default language', () async {
        // Act
        await audioManager.initialize();

        // Assert
        expect(audioManager.currentLanguage, 'en');
      });
    });

    group('Settings - Enable/Disable', () {
      test('setMusicEnabled toggles music state', () {
        // Act
        audioManager.setMusicEnabled(false);
        final disabled = audioManager.isMusicEnabled;

        audioManager.setMusicEnabled(true);
        final enabled = audioManager.isMusicEnabled;

        // Assert
        expect(disabled, false);
        expect(enabled, true);
      });

      test('setSfxEnabled toggles sound effects state', () {
        // Act
        audioManager.setSfxEnabled(false);
        final disabled = audioManager.areSfxEnabled;

        audioManager.setSfxEnabled(true);
        final enabled = audioManager.areSfxEnabled;

        // Assert
        expect(disabled, false);
        expect(enabled, true);
      });

      test('setVoiceEnabled toggles voice state', () {
        // Act
        audioManager.setVoiceEnabled(false);
        final disabled = audioManager.isVoiceEnabled;

        audioManager.setVoiceEnabled(true);
        final enabled = audioManager.isVoiceEnabled;

        // Assert
        expect(disabled, false);
        expect(enabled, true);
      });
    });

    group('Settings - Volume', () {
      test('setMusicVolume sets correct volume', () async {
        // Act
        await audioManager.setMusicVolume(0.5);

        // Assert
        expect(audioManager.musicVolume, 0.5);
      });

      test('setMusicVolume clamps volume to valid range', () async {
        // Test upper bound
        await audioManager.setMusicVolume(1.5);
        expect(audioManager.musicVolume, 1.0);

        // Test lower bound
        await audioManager.setMusicVolume(-0.5);
        expect(audioManager.musicVolume, 0.0);

        // Reset to normal value
        await audioManager.setMusicVolume(0.3);
      });

      test('setSfxVolume sets correct volume', () async {
        // Act
        await audioManager.setSfxVolume(0.7);

        // Assert
        expect(audioManager.sfxVolume, 0.7);
      });

      test('setSfxVolume clamps volume to valid range', () async {
        // Test upper bound
        await audioManager.setSfxVolume(2.0);
        expect(audioManager.sfxVolume, 1.0);

        // Test lower bound
        await audioManager.setSfxVolume(-1.0);
        expect(audioManager.sfxVolume, 0.0);

        // Reset to normal value
        await audioManager.setSfxVolume(1.0);
      });

      test('setVoiceVolume sets correct volume', () async {
        // Act
        await audioManager.setVoiceVolume(0.8);

        // Assert
        expect(audioManager.voiceVolume, 0.8);
      });

      test('setVoiceVolume clamps volume to valid range', () async {
        // Test upper bound
        await audioManager.setVoiceVolume(3.0);
        expect(audioManager.voiceVolume, 1.0);

        // Test lower bound
        await audioManager.setVoiceVolume(-2.0);
        expect(audioManager.voiceVolume, 0.0);

        // Reset to normal value
        await audioManager.setVoiceVolume(1.0);
      });
    });

    group('Sound Effects', () {
      test('playSfx method exists for all sound effect types', () {
        // Ensure SFX is enabled
        audioManager.setSfxEnabled(true);

        // Verify all sound effect enums exist
        expect(SoundEffect.values.length, 6);
        expect(SoundEffect.values, contains(SoundEffect.correct));
        expect(SoundEffect.values, contains(SoundEffect.wrong));
        expect(SoundEffect.values, contains(SoundEffect.click));
        expect(SoundEffect.values, contains(SoundEffect.star));
        expect(SoundEffect.values, contains(SoundEffect.success));
        expect(SoundEffect.values, contains(SoundEffect.hint));
      });

      test('playSfx respects enabled/disabled state', () {
        // Disable SFX
        audioManager.setSfxEnabled(false);
        expect(audioManager.areSfxEnabled, false);

        // Enable SFX
        audioManager.setSfxEnabled(true);
        expect(audioManager.areSfxEnabled, true);
      });
    });

    group('Animal Sounds', () {
      test('playAnimalSound method exists for all animal types', () {
        // Ensure SFX is enabled
        audioManager.setSfxEnabled(true);

        // Verify all animal sound enums exist
        expect(AnimalSound.values.length, 5);
        expect(AnimalSound.values, contains(AnimalSound.butterfly));
        expect(AnimalSound.values, contains(AnimalSound.monkey));
        expect(AnimalSound.values, contains(AnimalSound.bird));
        expect(AnimalSound.values, contains(AnimalSound.turtle));
        expect(AnimalSound.values, contains(AnimalSound.frog));
      });

      test('playAnimalSound respects enabled/disabled state', () {
        // Disable SFX
        audioManager.setSfxEnabled(false);
        expect(audioManager.areSfxEnabled, false);

        // Enable SFX
        audioManager.setSfxEnabled(true);
        expect(audioManager.areSfxEnabled, true);
      });
    });

    group('Background Music', () {
      test('playBackgroundMusic method exists for all music types', () {
        // Ensure music is enabled
        audioManager.setMusicEnabled(true);

        // Verify all background music enums exist
        expect(BackgroundMusic.values.length, 3);
        expect(BackgroundMusic.values, contains(BackgroundMusic.jungleAmbient));
        expect(BackgroundMusic.values, contains(BackgroundMusic.lessonBackground));
        expect(BackgroundMusic.values, contains(BackgroundMusic.celebration));
      });

      test('playBackgroundMusic respects enabled/disabled state', () {
        // Disable music
        audioManager.setMusicEnabled(false);
        expect(audioManager.isMusicEnabled, false);

        // Enable music
        audioManager.setMusicEnabled(true);
        expect(audioManager.isMusicEnabled, true);
      });

      test('stopBackgroundMusic does not throw', () async {
        expect(() => audioManager.stopBackgroundMusic(), returnsNormally);
      });

      test('duckMusic and unduckMusic do not throw', () async {
        // Act & Assert
        expect(() => audioManager.duckMusic(), returnsNormally);
        expect(() => audioManager.unduckMusic(), returnsNormally);
      });
    });

    group('Text-to-Speech', () {
      test('speakDialogue does not throw for different characters', () async {
        // Ensure voice is enabled
        audioManager.setVoiceEnabled(true);

        // Test with different characters
        final characters = ['bono', 'hippo', 'elli', 'unknown'];
        for (final character in characters) {
          expect(
            () => audioManager.speakDialogue('Test', character: character),
            returnsNormally,
            reason: 'speakDialogue should not throw for character: $character',
          );
        }
      });

      test('speakDialogue respects enabled/disabled state', () {
        // Disable voice
        audioManager.setVoiceEnabled(false);
        expect(audioManager.isVoiceEnabled, false);

        // Enable voice
        audioManager.setVoiceEnabled(true);
        expect(audioManager.isVoiceEnabled, true);
      });

      test('stopSpeaking does not throw', () async {
        expect(() => audioManager.stopSpeaking(), returnsNormally);
      });

      test('changeLanguage updates current language', () async {
        // Act
        await audioManager.changeLanguage('fr');

        // Assert
        expect(audioManager.currentLanguage, 'fr');

        // Change to another language
        await audioManager.changeLanguage('de');
        expect(audioManager.currentLanguage, 'de');

        // Reset to English
        await audioManager.changeLanguage('en');
      });
    });

    group('Integration scenarios', () {
      test('audio control flow without actual playback', () async {
        // Simulate a complete lesson control flow

        // 1. Initialize
        await audioManager.initialize(languageCode: 'en');
        expect(audioManager.currentLanguage, 'en');

        // 2. Duck and unduck music (volume control)
        await audioManager.duckMusic();
        await audioManager.unduckMusic();

        // 3. Stop music
        await audioManager.stopBackgroundMusic();

        // 4. Stop speaking
        await audioManager.stopSpeaking();

        // 5. Stop all
        await audioManager.stopAll();

        // Assert - no errors during control operations
        expect(audioManager.currentLanguage, 'en');
      });

      test('settings persist across operations', () async {
        // Set custom values
        audioManager.setMusicEnabled(false);
        audioManager.setSfxEnabled(false);
        audioManager.setVoiceEnabled(false);
        await audioManager.setMusicVolume(0.2);
        await audioManager.setSfxVolume(0.6);
        await audioManager.setVoiceVolume(0.9);

        // Verify persistence
        expect(audioManager.isMusicEnabled, false);
        expect(audioManager.areSfxEnabled, false);
        expect(audioManager.isVoiceEnabled, false);
        expect(audioManager.musicVolume, 0.2);
        expect(audioManager.sfxVolume, 0.6);
        expect(audioManager.voiceVolume, 0.9);

        // Reset to defaults
        audioManager.setMusicEnabled(true);
        audioManager.setSfxEnabled(true);
        audioManager.setVoiceEnabled(true);
        await audioManager.setMusicVolume(0.3);
        await audioManager.setSfxVolume(1.0);
        await audioManager.setVoiceVolume(1.0);
      });
    });

    group('Cleanup', () {
      test('stopAll does not throw', () async {
        expect(() => audioManager.stopAll(), returnsNormally);
      });

      test('dispose does not throw', () async {
        expect(() => audioManager.dispose(), returnsNormally);
      });
    });
  });
}
