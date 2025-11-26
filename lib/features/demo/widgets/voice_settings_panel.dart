import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/character_repository.dart';
import '../../../core/services/api_key_service.dart';
import '../../../core/services/azure_tts_reference.dart';
import '../../../core/services/azure_tts_service.dart';
import '../../lessons/domain/entities/character_voice_profile.dart';

/// Panel for configuring character voice settings
///
/// Allows administrators to:
/// - Select language
/// - Choose Azure TTS voice (filtered by language)
/// - Set role (if voice supports it)
/// - Set default style (if voice supports it)
/// - Adjust pitch, rate, and style degree
/// - Test voice with sample text
/// - Save profile to database
class VoiceSettingsPanel extends StatefulWidget {
  final String characterId;
  final String characterEmoji;
  final String characterName;
  final VoidCallback? onProfileSaved;

  const VoiceSettingsPanel({
    super.key,
    required this.characterId,
    required this.characterEmoji,
    required this.characterName,
    this.onProfileSaved,
  });

  @override
  State<VoiceSettingsPanel> createState() => _VoiceSettingsPanelState();
}

class _VoiceSettingsPanelState extends State<VoiceSettingsPanel> {
  late CharacterRepository _characterRepo;
  late AudioPlayer _audioPlayer;

  // Current settings
  String _selectedLanguage = 'en';

  // UI state
  bool _isLoading = true;
  bool _isTesting = false;
  bool _isSaving = false;
  bool _isResetting = false;
  String? _error;

  // Form state
  String? _selectedVoiceName;
  String? _selectedRole;
  String? _selectedStyle;
  int _pitchValue = 0;
  double _rateValue = 1.0;
  double _styleDegreeValue = 1.0;

  @override
  void initState() {
    super.initState();
    _characterRepo = CharacterRepository(AppDatabase.instance);
    _audioPlayer = AudioPlayer();
    _loadProfile();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VoiceSettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.characterId != widget.characterId) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _characterRepo.getVoiceProfile(
        widget.characterId,
        _selectedLanguage,
      );

      if (profile != null) {
        _applyProfileToForm(profile);
      } else {
        // Create default profile
        final character = await _characterRepo.getCharacter(widget.characterId);
        final defaultProfile = CharacterVoiceProfile.defaultFor(
          characterId: widget.characterId,
          languageCode: _selectedLanguage,
          isChild: character?.isChild ?? false,
          isMale: character?.isMale ?? false,
        );
        _applyProfileToForm(defaultProfile);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyProfileToForm(CharacterVoiceProfile profile) {
    _selectedVoiceName = profile.voiceName;
    _selectedRole = profile.role;
    _selectedStyle = profile.defaultStyle;
    _pitchValue = AzureTtsReference.parsePitch(profile.basePitch);
    _rateValue = profile.baseRate;
    _styleDegreeValue = profile.defaultStyleDegree;
  }

  CharacterVoiceProfile _buildProfileFromForm() {
    return CharacterVoiceProfile(
      characterId: widget.characterId,
      languageCode: _selectedLanguage,
      voiceName: _selectedVoiceName ?? 'en-US-JennyNeural',
      role: _selectedRole,
      basePitch: AzureTtsReference.formatPitch(_pitchValue),
      baseRate: _rateValue,
      defaultStyle: _selectedStyle,
      defaultStyleDegree: _styleDegreeValue,
    );
  }

  Future<void> _onLanguageChanged(String? language) async {
    if (language == null || language == _selectedLanguage) return;

    setState(() {
      _selectedLanguage = language;
    });

    await _loadProfile();
  }

  void _onVoiceChanged(String? voiceName) {
    if (voiceName == null) return;

    final voiceInfo = AzureTtsReference.getVoiceInfo(voiceName);

    setState(() {
      _selectedVoiceName = voiceName;

      // Reset role and style if new voice doesn't support them
      if (voiceInfo?.supportsRole != true) {
        _selectedRole = null;
      }
      if (voiceInfo?.hasStyles != true) {
        _selectedStyle = null;
      } else if (_selectedStyle != null &&
                 !voiceInfo!.styles.contains(_selectedStyle)) {
        // Reset to first available style if current is not supported
        _selectedStyle = voiceInfo.styles.isNotEmpty ? voiceInfo.styles.first : null;
      }
    });
  }

  Future<void> _testVoice() async {
    setState(() {
      _isTesting = true;
      _error = null;
    });

    try {
      // Get Azure TTS credentials from ApiKeyService
      final apiKeyService = await ApiKeyService.getInstance();
      final subscriptionKey = apiKeyService.getAzureApiKey();
      final region = apiKeyService.getAzureRegion();

      if (subscriptionKey == null || subscriptionKey.isEmpty) {
        throw Exception('Azure TTS key not configured. Go to Settings to add your API key.');
      }

      final ttsService = AzureTtsService(
        subscriptionKey: subscriptionKey,
        region: region,
      );

      final profile = _buildProfileFromForm();
      final testPhrase = _getTestPhrase(_selectedLanguage);

      final audioData = await ttsService.generateAudioWithProfile(
        text: testPhrase,
        profile: profile,
      );

      // Save to temp file and play (BytesSource not supported on iOS/macOS)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/voice_test.mp3');
      await tempFile.writeAsBytes(audioData);
      await _audioPlayer.play(DeviceFileSource(tempFile.path));

      ttsService.dispose();
    } catch (e) {
      setState(() {
        _error = 'Voice test failed: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  String _getTestPhrase(String languageCode) {
    const phrases = {
      'en': 'Hello! I am {name}. Nice to meet you!',
      'ru': 'Привет! Я {name}. Рад познакомиться!',
      'de': 'Hallo! Ich bin {name}. Freut mich!',
      'fr': 'Bonjour! Je suis {name}. Enchanté!',
      'it': 'Ciao! Sono {name}. Piacere di conoscerti!',
      'am': 'ሰላም! እኔ {name} ነኝ። ደስ ብሎኛል!',
      'my': 'မင်္ဂလာပါ! ကျွန်တော် {name} ပါ။',
    };

    final phrase = phrases[languageCode] ?? phrases['en']!;
    return phrase.replaceAll('{name}', widget.characterName);
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final profile = _buildProfileFromForm();
      await _characterRepo.updateVoiceProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Voice profile saved for ${AzureTtsReference.getLanguageDisplayName(_selectedLanguage)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onProfileSaved?.call();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to save: $e';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _isResetting = true;
      _error = null;
    });

    try {
      await _characterRepo.resetVoiceProfileToDefault(
        widget.characterId,
        _selectedLanguage,
      );
      await _loadProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reset to default settings for ${AzureTtsReference.getLanguageDisplayName(_selectedLanguage)}',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Reset failed: $e';
      });
    } finally {
      setState(() {
        _isResetting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final voices = AzureTtsReference.getVoicesForLanguage(_selectedLanguage);
    final selectedVoice = _selectedVoiceName != null
        ? AzureTtsReference.getVoiceInfo(_selectedVoiceName!)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(widget.characterEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  '🔊 Voice Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Error message
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Language selector
            _buildLanguageSelector(),
            const SizedBox(height: 16),

            // Voice selector
            _buildVoiceSelector(voices),
            const SizedBox(height: 16),

            // Role selector (conditional)
            if (selectedVoice?.supportsRole == true) ...[
              _buildRoleSelector(),
              const SizedBox(height: 16),
            ],

            // Style selector (conditional)
            if (selectedVoice?.hasStyles == true) ...[
              _buildStyleSelector(selectedVoice!.styles),
              const SizedBox(height: 16),
            ] else ...[
              _buildNoStylesWarning(),
              const SizedBox(height: 16),
            ],

            // Prosody sliders
            _buildProsodySliders(selectedVoice?.hasStyles == true),
            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final languages = AzureTtsReference.availableLanguages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Language',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: languages.map((lang) {
            final isSelected = _selectedLanguage == lang;
            final flag = AzureTtsReference.getLanguageFlag(lang);

            return ChoiceChip(
              label: Text('$flag ${lang.toUpperCase()}'),
              selected: isSelected,
              onSelected: (_) => _onLanguageChanged(lang),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVoiceSelector(List<AzureVoiceOption> voices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voice',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedVoiceName,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          items: voices.map((voice) {
            final hasStyles = voice.hasStyles;
            final hasRole = voice.supportsRole;

            return DropdownMenuItem(
              value: voice.name,
              child: Row(
                children: [
                  Text(voice.displayName),
                  const SizedBox(width: 8),
                  if (hasStyles)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${voice.styles.length} styles',
                        style: TextStyle(fontSize: 10, color: Colors.green.shade700),
                      ),
                    ),
                  if (hasRole) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'roles',
                        style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: _onVoiceChanged,
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    final roles = AzureTtsReference.supportedRoles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Role',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          value: _selectedRole,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('None (default voice)', style: TextStyle(fontStyle: FontStyle.italic)),
            ),
            ...roles.map((role) => DropdownMenuItem(
              value: role,
              child: Text(AzureTtsReference.roleDisplayNames[role] ?? role),
            )),
          ],
          onChanged: (value) => setState(() => _selectedRole = value),
        ),
      ],
    );
  }

  Widget _buildStyleSelector(List<String> styles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Default Style',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          value: _selectedStyle,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('None', style: TextStyle(fontStyle: FontStyle.italic)),
            ),
            ...styles.map((style) => DropdownMenuItem(
              value: style,
              child: Text(AzureTtsReference.getStyleDisplayName(style)),
            )),
          ],
          onChanged: (value) => setState(() => _selectedStyle = value),
        ),
      ],
    );
  }

  Widget _buildNoStylesWarning() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${AzureTtsReference.getLanguageDisplayName(_selectedLanguage)} voices don\'t support styles',
              style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProsodySliders(bool showStyleDegree) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prosody',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 12),

        // Pitch slider
        _buildSliderRow(
          label: 'Pitch',
          value: _pitchValue.toDouble(),
          min: AzureTtsReference.pitchMin.toDouble(),
          max: AzureTtsReference.pitchMax.toDouble(),
          divisions: 100,
          displayValue: AzureTtsReference.formatPitch(_pitchValue),
          onChanged: (value) => setState(() => _pitchValue = value.round()),
        ),
        const SizedBox(height: 8),

        // Rate slider
        _buildSliderRow(
          label: 'Rate',
          value: _rateValue,
          min: AzureTtsReference.rateMin,
          max: AzureTtsReference.rateMax,
          divisions: 30,
          displayValue: '${_rateValue.toStringAsFixed(2)}x',
          onChanged: (value) => setState(() => _rateValue = value),
        ),

        // Style degree slider (only if styles are supported)
        if (showStyleDegree && _selectedStyle != null) ...[
          const SizedBox(height: 8),
          _buildSliderRow(
            label: 'Style Intensity',
            value: _styleDegreeValue,
            min: AzureTtsReference.styleDegreeMin,
            max: AzureTtsReference.styleDegreeMax,
            divisions: 40,
            displayValue: _styleDegreeValue.toStringAsFixed(2),
            onChanged: (value) => setState(() => _styleDegreeValue = value),
          ),
        ],
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(
            displayValue,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isAnyLoading = _isTesting || _isSaving || _isResetting;

    return Row(
      children: [
        // Reset button
        IconButton(
          onPressed: isAnyLoading ? null : _resetToDefault,
          icon: _isResetting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.restore),
          tooltip: 'Reset to Default',
        ),
        const SizedBox(width: 8),
        // Test button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isAnyLoading ? null : _testVoice,
            icon: _isTesting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_isTesting ? 'Testing...' : 'Test Voice'),
          ),
        ),
        const SizedBox(width: 12),
        // Save button
        Expanded(
          child: FilledButton.icon(
            onPressed: isAnyLoading ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save'),
          ),
        ),
      ],
    );
  }
}
