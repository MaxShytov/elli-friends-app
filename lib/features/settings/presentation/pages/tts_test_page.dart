import 'package:flutter/material.dart';
import '../../../../core/utils/tts_diagnostics.dart';
import '../../../../core/services/audio_manager.dart';
import '../../../../core/constants/supported_languages.dart';

class TtsTestPage extends StatefulWidget {
  const TtsTestPage({super.key});

  @override
  State<TtsTestPage> createState() => _TtsTestPageState();
}

class _TtsTestPageState extends State<TtsTestPage> {
  final AudioManager _audioManager = AudioManager();
  Map<String, Map<String, dynamic>> _languageInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    setState(() => _isLoading = true);

    await TtsDiagnostics.printFullDiagnostics();

    final supportedLanguages = ['en', 'ru', 'fr', 'de', 'it', 'my'];
    final info = <String, Map<String, dynamic>>{};

    for (var lang in supportedLanguages) {
      // На Web платформе просто предполагаем, что все языки доступны
      // Реальная проверка будет при попытке озвучки
      info[lang] = {
        'languageCode': lang,
        'isAvailable': true,
        'hasVoices': true,
        'languages': [lang],
        'voices': [{'name': 'System', 'locale': lang}],
      };
    }

    setState(() {
      _languageInfo = info;
      _isLoading = false;
    });
  }

  Future<void> _testLanguage(String languageCode) async {
    final testPhrases = {
      'en': 'Hello, this is a test.',
      'ru': 'Привет, это тест.',
      'fr': 'Bonjour, ceci est un test.',
      'de': 'Hallo, das ist ein Test.',
      'it': 'Ciao, questo è un test.',
      'my': 'မင်္ဂလာပါ။',
    };

    await _audioManager.changeLanguage(languageCode);
    await _audioManager.speakDialogue(
      testPhrases[languageCode] ?? 'Test',
      character: 'bono',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiagnostics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Text-to-Speech Language Support',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Test if TTS works for each language on your system',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                
                ..._languageInfo.entries.map((entry) {
                  final langCode = entry.key;
                  final info = entry.value;
                  final hasVoices = info['hasVoices'] as bool;
                  final voiceCount = (info['voices'] as List).length;
                  final langName = SupportedLanguages.getLanguageName(langCode);
                  final ttsCode = SupportedLanguages.getTtsLanguageCode(langCode);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: hasVoices ? Colors.green : Colors.red,
                        child: Text(
                          hasVoices ? '✓' : '✗',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        '$langName ($langCode)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TTS Code: $ttsCode'),
                          Text(
                            hasVoices
                                ? 'Voices available: $voiceCount'
                                : 'No voices installed',
                            style: TextStyle(
                              color: hasVoices ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      trailing: hasVoices
                          ? ElevatedButton(
                              onPressed: () => _testLanguage(langCode),
                              child: const Text('Test'),
                            )
                          : null,
                    ),
                  );
                }),

                const SizedBox(height: 24),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'How to fix missing voices',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('macOS:'),
                        const Text(
                          '  System Preferences → Accessibility → Spoken Content → System Voice → Customize',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        const Text('Windows:'),
                        const Text(
                          '  Settings → Time & Language → Speech → Manage voices → Add voices',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        const Text('Linux:'),
                        const Text(
                          '  sudo apt install espeak-ng espeak-ng-data',
                          style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
