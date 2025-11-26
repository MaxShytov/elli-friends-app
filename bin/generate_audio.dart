#!/usr/bin/env dart
// bin/generate_audio.dart
//
// CLI tool for pre-generating audio files for lessons using Azure TTS.
//
// Usage:
//   dart run bin/generate_audio.dart --lesson counting --languages en,ru
//   dart run bin/generate_audio.dart --all --languages en
//   dart run bin/generate_audio.dart --help
//
// Environment variables:
//   AZURE_TTS_KEY    - Azure Speech Services subscription key (required)
//   AZURE_TTS_REGION - Azure region (default: eastus)

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

// ═══════════════════════════════════════════════════════════════
// CONFIGURATION
// ═══════════════════════════════════════════════════════════════

const String defaultRegion = 'eastus';
const String outputDir = 'assets/audio/lessons';
const String lessonsDir = 'assets/data/lessons';
const String charactersFile = 'assets/data/characters.json';

// Azure voice mapping (from azure_tts_reference.dart)
const Map<String, Map<String, String>> characterVoices = {
  'orson': {
    'en': 'en-US-GuyNeural',
    'ru': 'ru-RU-DmitryNeural',
    'fr': 'fr-FR-HenriNeural',
    'de': 'de-DE-ConradNeural',
    'it': 'it-IT-DiegoNeural',
    'my': 'my-MM-ThihaNeural',
    'am': 'am-ET-AmehaNeural',
  },
  'merv': {
    'en': 'en-US-ChristopherNeural',
    'ru': 'ru-RU-DmitryNeural',
    'fr': 'fr-FR-AlainNeural',
    'de': 'de-DE-KillianNeural',
    'it': 'it-IT-GiuseppeNeural',
    'my': 'my-MM-ThihaNeural',
    'am': 'am-ET-AmehaNeural',
  },
  'elli': {
    'en': 'en-US-JennyNeural',
    'ru': 'ru-RU-SvetlanaNeural',
    'fr': 'fr-FR-DeniseNeural',
    'de': 'de-DE-KatjaNeural',
    'it': 'it-IT-ElsaNeural',
    'my': 'my-MM-NilarNeural',
    'am': 'am-ET-MekdesNeural',
  },
  'bono': {
    'en': 'en-US-AnaNeural',
    'ru': 'ru-RU-DariyaNeural',
    'fr': 'fr-FR-EloiseNeural',
    'de': 'de-DE-GiselaNeural',
    'it': 'it-IT-PierinaNeural',
    'my': 'my-MM-NilarNeural',
    'am': 'am-ET-MekdesNeural',
  },
  'hippo': {
    'en': 'en-US-AriaNeural',
    'ru': 'ru-RU-SvetlanaNeural',
    'fr': 'fr-FR-DeniseNeural',
    'de': 'de-DE-KatjaNeural',
    'it': 'it-IT-IsabellaNeural',
    'my': 'my-MM-NilarNeural',
    'am': 'am-ET-MekdesNeural',
  },
};

// Azure locale mapping
const Map<String, String> localeMapping = {
  'en': 'en-US',
  'ru': 'ru-RU',
  'fr': 'fr-FR',
  'de': 'de-DE',
  'it': 'it-IT',
  'my': 'my-MM',
  'am': 'am-ET',
};

// ═══════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('lesson', abbr: 'l', help: 'Lesson ID to generate audio for')
    ..addFlag('all', abbr: 'a', help: 'Generate audio for all lessons')
    ..addOption('languages',
        abbr: 'L',
        help: 'Comma-separated language codes (default: en)',
        defaultsTo: 'en')
    ..addOption('output',
        abbr: 'o', help: 'Output directory', defaultsTo: outputDir)
    ..addFlag('force',
        abbr: 'f', help: 'Force regenerate even if file exists')
    ..addFlag('dry-run',
        abbr: 'd', help: 'Show what would be generated without generating')
    ..addFlag('verbose', abbr: 'v', help: 'Verbose output')
    ..addFlag('help', abbr: 'h', help: 'Show help');

  ArgResults args;
  try {
    args = parser.parse(arguments);
  } catch (e) {
    print('Error: $e');
    print('Usage: dart run bin/generate_audio.dart [options]');
    print(parser.usage);
    exit(1);
  }

  if (args['help'] as bool) {
    print('Audio Generator for Elli Friends App');
    print('');
    print('Generates TTS audio files for lessons using Azure Speech Services.');
    print('');
    print('Usage: dart run bin/generate_audio.dart [options]');
    print('');
    print('Options:');
    print(parser.usage);
    print('');
    print('Environment variables:');
    print('  AZURE_TTS_KEY    - Azure Speech Services subscription key (required)');
    print('  AZURE_TTS_REGION - Azure region (default: eastus)');
    print('');
    print('Examples:');
    print('  # Generate English audio for counting lesson');
    print('  dart run bin/generate_audio.dart --lesson counting --languages en');
    print('');
    print('  # Generate English and Russian for all lessons');
    print('  dart run bin/generate_audio.dart --all --languages en,ru');
    print('');
    print('  # Dry run to see what would be generated');
    print('  dart run bin/generate_audio.dart --all --dry-run');
    exit(0);
  }

  // Check for Azure credentials
  final azureKey = Platform.environment['AZURE_TTS_KEY'];
  final azureRegion =
      Platform.environment['AZURE_TTS_REGION'] ?? defaultRegion;

  if (azureKey == null || azureKey.isEmpty) {
    print('Error: AZURE_TTS_KEY environment variable is required');
    print('');
    print('Set it with:');
    print('  export AZURE_TTS_KEY="your-subscription-key"');
    exit(1);
  }

  final lessonId = args['lesson'] as String?;
  final all = args['all'] as bool;
  final languagesStr = args['languages'] as String;
  final outputPath = args['output'] as String;
  final force = args['force'] as bool;
  final dryRun = args['dry-run'] as bool;
  final verbose = args['verbose'] as bool;

  if (lessonId == null && !all) {
    print('Error: Either --lesson or --all is required');
    print('Usage: dart run bin/generate_audio.dart [options]');
    print(parser.usage);
    exit(1);
  }

  final languages =
      languagesStr.split(',').map((s) => s.trim()).toList();

  print('Audio Generator');
  print('===============');
  print('Azure Region: $azureRegion');
  print('Languages: ${languages.join(", ")}');
  print('Output: $outputPath');
  if (force) print('Force: enabled');
  if (dryRun) print('Dry run: enabled');
  print('');

  final generator = AudioGenerator(
    azureKey: azureKey,
    azureRegion: azureRegion,
    outputDir: outputPath,
    verbose: verbose,
  );

  try {
    if (all) {
      await generator.generateAllLessons(
        languages: languages,
        force: force,
        dryRun: dryRun,
      );
    } else {
      await generator.generateLesson(
        lessonId: lessonId!,
        languages: languages,
        force: force,
        dryRun: dryRun,
      );
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

// ═══════════════════════════════════════════════════════════════
// AUDIO GENERATOR
// ═══════════════════════════════════════════════════════════════

class AudioGenerator {
  final String azureKey;
  final String azureRegion;
  final String outputDir;
  final bool verbose;
  final http.Client _httpClient;

  int _generated = 0;
  int _skipped = 0;
  int _failed = 0;

  AudioGenerator({
    required this.azureKey,
    required this.azureRegion,
    required this.outputDir,
    this.verbose = false,
  }) : _httpClient = http.Client();

  String get _endpoint =>
      'https://$azureRegion.tts.speech.microsoft.com/cognitiveservices/v1';

  /// Generate audio for all lessons
  Future<void> generateAllLessons({
    required List<String> languages,
    bool force = false,
    bool dryRun = false,
  }) async {
    final lessonsDirectory = Directory(lessonsDir);
    if (!await lessonsDirectory.exists()) {
      throw Exception('Lessons directory not found: $lessonsDir');
    }

    final lessonFiles = await lessonsDirectory
        .list()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    print('Found ${lessonFiles.length} lessons');
    print('');

    for (final file in lessonFiles) {
      final lessonId =
          p.basenameWithoutExtension(file.path).replaceFirst('lesson_', '');
      await generateLesson(
        lessonId: lessonId,
        languages: languages,
        force: force,
        dryRun: dryRun,
      );
    }

    _printSummary();
  }

  /// Generate audio for a single lesson
  Future<void> generateLesson({
    required String lessonId,
    required List<String> languages,
    bool force = false,
    bool dryRun = false,
  }) async {
    print('Processing lesson: $lessonId');
    print('-' * 40);

    // Load lesson JSON
    final lessonFile = File(p.join(lessonsDir, 'lesson_$lessonId.json'));
    if (!await lessonFile.exists()) {
      print('  Warning: Lesson file not found: ${lessonFile.path}');
      return;
    }

    final lessonJson = jsonDecode(await lessonFile.readAsString());
    final scenes = lessonJson['scenes'] as List<dynamic>;

    for (final language in languages) {
      print('  Language: $language');

      for (int i = 0; i < scenes.length; i++) {
        final scene = scenes[i] as Map<String, dynamic>;
        final dialogue = scene['dialogue'] as Map<String, dynamic>?;
        final character = scene['character'] as String?;
        final tone = scene['tone'] as String?;

        if (dialogue == null || character == null) {
          if (verbose) print('    Scene $i: no dialogue, skipping');
          continue;
        }

        final text = dialogue[language] as String?;
        if (text == null || text.isEmpty) {
          if (verbose) print('    Scene $i: no text for $language, skipping');
          continue;
        }

        final outputPath = _getOutputPath(lessonId, i, language);

        // Check if file exists
        if (!force && await File(outputPath).exists()) {
          if (verbose) print('    Scene $i: already exists, skipping');
          _skipped++;
          continue;
        }

        if (dryRun) {
          print('    Scene $i: would generate ($character): "${_truncate(text, 30)}"');
          continue;
        }

        // Generate audio
        try {
          if (verbose) {
            print('    Scene $i: generating ($character): "${_truncate(text, 30)}"');
          }

          final audioData = await _generateAudio(
            text: text,
            character: character,
            language: language,
            tone: tone,
          );

          // Save file
          await _saveAudio(outputPath, audioData);

          if (verbose) {
            print('    Scene $i: saved (${_formatBytes(audioData.length)})');
          }

          _generated++;
        } catch (e) {
          print('    Scene $i: ERROR - $e');
          _failed++;
        }

        // Rate limiting - Azure has limits
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    print('');
  }

  /// Generate audio using Azure TTS
  Future<List<int>> _generateAudio({
    required String text,
    required String character,
    required String language,
    String? tone,
  }) async {
    final voice = _getVoice(character, language);
    final locale = localeMapping[language] ?? 'en-US';

    // Build SSML
    final ssml = _buildSsml(
      text: text,
      voice: voice,
      locale: locale,
      tone: tone,
    );

    final response = await _httpClient.post(
      Uri.parse(_endpoint),
      headers: {
        'Ocp-Apim-Subscription-Key': azureKey,
        'Content-Type': 'application/ssml+xml',
        'X-Microsoft-OutputFormat': 'audio-16khz-128kbitrate-mono-mp3',
        'User-Agent': 'ElliFriendsApp-AudioGenerator',
      },
      body: ssml,
    );

    if (response.statusCode != 200) {
      throw Exception('Azure TTS error: ${response.statusCode} - ${response.body}');
    }

    return response.bodyBytes;
  }

  /// Build SSML for Azure TTS
  String _buildSsml({
    required String text,
    required String voice,
    required String locale,
    String? tone,
  }) {
    final escapedText = _escapeXml(text);

    // Map tone to Azure style (if supported)
    String? style;
    if (tone != null && _voiceSupportsStyles(voice)) {
      style = _mapToneToStyle(tone);
    }

    String content;
    if (style != null) {
      content = '''
    <mstts:express-as style="$style">
      <prosody rate="-5%" pitch="0%">$escapedText</prosody>
    </mstts:express-as>''';
    } else {
      content = '''
    <prosody rate="-5%" pitch="0%">$escapedText</prosody>''';
    }

    return '''<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="$locale">
  <voice name="$voice">$content
  </voice>
</speak>''';
  }

  /// Get voice for character and language
  String _getVoice(String character, String language) {
    final voices = characterVoices[character.toLowerCase()];
    if (voices != null && voices.containsKey(language)) {
      return voices[language]!;
    }
    // Default fallback
    return characterVoices['bono']![language] ??
        characterVoices['bono']!['en']!;
  }

  /// Check if voice supports styles
  bool _voiceSupportsStyles(String voice) {
    const voicesWithStyles = [
      'en-US-JennyNeural',
      'en-US-GuyNeural',
      'en-US-AriaNeural',
      'en-US-AnaNeural',
    ];
    return voicesWithStyles.contains(voice);
  }

  /// Map tone to Azure style
  String? _mapToneToStyle(String tone) {
    const mapping = {
      'excited': 'excited',
      'cheerful': 'cheerful',
      'happy': 'cheerful',
      'sad': 'sad',
      'angry': 'angry',
      'friendly': 'friendly',
      'calm': 'friendly',
      'questioning': 'friendly',
      'neutral': null,
    };
    return mapping[tone.toLowerCase()];
  }

  /// Save audio to file
  Future<void> _saveAudio(String path, List<int> data) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data);
  }

  /// Get output file path
  String _getOutputPath(String lessonId, int sceneIndex, String language) {
    return p.join(outputDir, lessonId, language, 'scene_$sceneIndex.mp3');
  }

  /// Escape XML special characters
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Truncate string for display
  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Format bytes for display
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Print summary
  void _printSummary() {
    print('Summary');
    print('=======');
    print('Generated: $_generated');
    print('Skipped: $_skipped');
    print('Failed: $_failed');
    print('Total: ${_generated + _skipped + _failed}');
  }

  void dispose() {
    _httpClient.close();
  }
}
