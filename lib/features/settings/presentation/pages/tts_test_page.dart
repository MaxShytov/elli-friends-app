import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/services/audio_manager.dart';
import '../../../../core/services/api_key_service.dart';
import '../../../../core/services/azure_tts_service.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../core/constants/app_colors.dart';

class TtsTestPage extends StatefulWidget {
  const TtsTestPage({super.key});

  @override
  State<TtsTestPage> createState() => _TtsTestPageState();
}

class _TtsTestPageState extends State<TtsTestPage> with SingleTickerProviderStateMixin {
  final AudioManager _audioManager = AudioManager();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late TabController _tabController;

  // Azure TTS
  AzureTtsService? _azureTtsService;
  bool _hasAzureKey = false;
  bool _isLoadingAzure = true;
  String? _azureError;

  // Characters
  final _characters = ['orson', 'merv', 'elli', 'bono', 'hippo'];
  String _selectedCharacter = 'orson';
  String _selectedLanguage = 'en';
  bool _isGenerating = false;
  bool _isPlaying = false;

  // Generated audio cache: key = "character_language", value = (path, size)
  final Map<String, (String path, int size)> _generatedAudio = {};

  // Test phrases per language
  final _testPhrases = {
    'en': "Hello! I'm here to help you learn counting!",
    'ru': 'Привет! Я здесь, чтобы помочь тебе учиться считать!',
    'fr': 'Bonjour! Je suis là pour t\'aider à apprendre à compter!',
    'de': 'Hallo! Ich bin hier, um dir beim Zählen zu helfen!',
    'it': 'Ciao! Sono qui per aiutarti a imparare a contare!',
    'my': 'မင်္ဂလာပါ! ရေတွက်နည်းကို သင်ယူဖို့ ကူညီပေးပါမယ်။',
    'am': 'ሰላም! መቁጠር እንድትማር ልረዳህ እዚህ ነኝ!',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAzureService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _azureTtsService?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAzureService() async {
    setState(() {
      _isLoadingAzure = true;
      _azureError = null;
    });

    try {
      final apiKeyService = await ApiKeyService.getInstance();
      _hasAzureKey = apiKeyService.hasAzureApiKey();

      if (_hasAzureKey) {
        _azureTtsService = AzureTtsService(
          subscriptionKey: apiKeyService.getAzureApiKey()!,
          region: apiKeyService.getAzureRegion(),
        );
      }
    } catch (e) {
      _azureError = e.toString();
    }

    setState(() => _isLoadingAzure = false);
  }

  String get _currentKey => '${_selectedCharacter}_$_selectedLanguage';

  (String path, int size)? get _currentAudio => _generatedAudio[_currentKey];

  Future<void> _generateAudio() async {
    if (_azureTtsService == null) return;

    setState(() {
      _isGenerating = true;
      _azureError = null;
    });

    try {
      final text = _testPhrases[_selectedLanguage] ?? 'Hello!';

      final audioData = await _azureTtsService!.generateAudio(
        text: text,
        languageCode: _selectedLanguage,
        character: _selectedCharacter,
      );

      if (audioData.isNotEmpty) {
        // Save to temp file
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/tts_test_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await tempFile.writeAsBytes(audioData);

        _generatedAudio[_currentKey] = (tempFile.path, audioData.length);
        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Generated ${(audioData.length / 1024).toStringAsFixed(1)} KB audio for ${_getCharacterDisplayName(_selectedCharacter)}',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _azureError = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.incorrect,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _playGeneratedAudio() async {
    final audio = _currentAudio;
    if (audio == null) return;

    final file = File(audio.$1);
    if (!await file.exists()) {
      _generatedAudio.remove(_currentKey);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio file not found. Please generate again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isPlaying = true);
    await _audioPlayer.play(DeviceFileSource(audio.$1));

    // Listen for completion
    _audioPlayer.onPlayerComplete.first.then((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  Future<void> _stopPlaying() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  void _clearCurrentAudio() {
    final audio = _currentAudio;
    if (audio != null) {
      File(audio.$1).delete().ignore();
      _generatedAudio.remove(_currentKey);
    }
  }

  Future<void> _testSystemTts(String languageCode) async {
    final text = _testPhrases[languageCode] ?? 'Test';
    await _audioManager.changeLanguage(languageCode);
    await _audioManager.speakDialogue(text, character: _selectedCharacter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.cloud), text: 'Azure TTS'),
            Tab(icon: Icon(Icons.phone_android), text: 'System TTS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAzureTtsTab(),
          _buildSystemTtsTab(),
        ],
      ),
    );
  }

  Widget _buildAzureTtsTab() {
    if (_isLoadingAzure) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasAzureKey) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.key_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Azure TTS Key Not Set',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Go to Settings → Azure TTS Key to add your key',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.settings),
                label: const Text('Go to Settings'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            color: Colors.green.shade50,
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Azure TTS Connected'),
              subtitle: Text('Region: ${_azureTtsService?.region ?? "unknown"}'),
            ),
          ),
          const SizedBox(height: 24),

          // Character selection
          const Text(
            'Select Character',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _characters.map((char) {
              final isSelected = char == _selectedCharacter;
              return ChoiceChip(
                label: Text(_getCharacterDisplayName(char)),
                selected: isSelected,
                selectedColor: AppColors.primary.withValues(alpha: 0.3),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCharacter = char);
                  }
                },
                avatar: CircleAvatar(
                  backgroundColor: isSelected ? AppColors.primary : Colors.grey,
                  child: Text(
                    _getCharacterEmoji(char),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Language selection
          const Text(
            'Select Language',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _testPhrases.keys.map((lang) {
              final isSelected = lang == _selectedLanguage;
              return ChoiceChip(
                label: Text(SupportedLanguages.getLanguageName(lang)),
                selected: isSelected,
                selectedColor: Colors.blue.withValues(alpha: 0.3),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedLanguage = lang);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Preview text
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_quote, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Test Phrase',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _testPhrases[_selectedLanguage] ?? '',
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Voice info
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voice Configuration',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Voice: ${AzureTtsConfig.getVoice(_selectedCharacter, _selectedLanguage)}',
                  ),
                  Text(
                    'Locale: ${AzureTtsConfig.getAzureLocale(_selectedLanguage)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Generated audio info
          if (_currentAudio != null) ...[
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.audio_file, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Audio Generated',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(_currentAudio!.$2 / 1024).toStringAsFixed(1)} KB',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _clearCurrentAudio();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close, color: Colors.grey),
                      tooltip: 'Clear',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Generate and Play buttons
          Row(
            children: [
              // Generate button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateAudio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.record_voice_over),
                    label: Text(_isGenerating ? 'Generating...' : 'Generate'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Play/Stop button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _currentAudio == null
                        ? null
                        : (_isPlaying ? _stopPlaying : _playGeneratedAudio),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Stop' : 'Play'),
                  ),
                ),
              ),
            ],
          ),

          if (_azureError != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _azureError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemTtsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'System Text-to-Speech',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Test system TTS for each language (fallback when Azure is unavailable)',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Character selection for system TTS
        const Text(
          'Select Character Voice',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _characters.map((char) {
            final isSelected = char == _selectedCharacter;
            return ChoiceChip(
              label: Text(_getCharacterDisplayName(char)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCharacter = char);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Language test cards
        ..._testPhrases.entries.map((entry) {
          final langCode = entry.key;
          final phrase = entry.value;
          final langName = SupportedLanguages.getLanguageName(langCode);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  langCode.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(langName),
              subtitle: Text(
                phrase,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: ElevatedButton(
                onPressed: () => _testSystemTts(langCode),
                child: const Text('Test'),
              ),
            ),
          );
        }),

        const SizedBox(height: 24),
        Card(
          color: Colors.blue.shade50,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'About System TTS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'System TTS uses voices installed on your device. '
                  'Quality varies by platform and installed language packs.\n\n'
                  'For best quality, use Azure TTS which provides '
                  'neural voices optimized for each character.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getCharacterDisplayName(String char) {
    const names = {
      'orson': 'Orson (Lion)',
      'merv': 'Merv (Wizard)',
      'elli': 'Elli (Elephant)',
      'bono': 'Bono (Baby)',
      'hippo': 'Hippo',
    };
    return names[char] ?? char;
  }

  String _getCharacterEmoji(String char) {
    const emojis = {
      'orson': '🦁',
      'merv': '🧙',
      'elli': '🐘',
      'bono': '🐣',
      'hippo': '🦛',
    };
    return emojis[char] ?? '🎭';
  }
}
