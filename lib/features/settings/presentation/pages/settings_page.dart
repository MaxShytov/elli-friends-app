import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/seed_service.dart';
import '../../../../core/services/api_key_service.dart';
import '../../../../core/services/azure_tts_service.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../l10n/app_localizations.dart';

/// Settings page for app configuration
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          // Language Section
          Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: AppColors.primary,
                        size: AppDimensions.iconMedium,
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      Text(
                        l10n.languageSettings,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...SupportedLanguages.supportedLocales.map((locale) {
                  final isSelected =
                      locale.languageCode == currentLocale.languageCode;
                  return ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                    title: Text(
                      SupportedLanguages.getLanguageName(locale.languageCode),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () async {
                      // Change locale using the global LocaleService
                      await LocaleService().setLocale(locale);

                      if (context.mounted) {
                        final newL10n = AppLocalizations.of(context)!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              newL10n.languageChanged(SupportedLanguages.getLanguageName(locale.languageCode)),
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Audio Settings (placeholder for future)
          Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volume_up,
                        color: AppColors.primary,
                        size: AppDimensions.iconMedium,
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      const Text(
                        'Audio Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.mic,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.testVoice),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/tts-test');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Editor Section (temporary: always visible for testing)
          // TODO: restore secret triple tap activation later
          Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_note,
                        color: Colors.purple,
                        size: AppDimensions.iconMedium,
                      ),
                      const SizedBox(width: AppDimensions.paddingMedium),
                      const Text(
                        'Lesson Editor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.edit_document,
                    color: Colors.purple,
                  ),
                  title: const Text('Edit Lessons'),
                  subtitle: const Text('Edit lesson scenarios and dialogues'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/editor'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.key,
                    color: Colors.purple,
                  ),
                  title: const Text('Claude API Key'),
                  subtitle: const Text('Required for auto-translation'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showApiKeyDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.record_voice_over,
                    color: Colors.blue,
                  ),
                  title: const Text('Azure TTS Key'),
                  subtitle: const Text('For high-quality voice generation'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showAzureKeyDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Developer Settings (only in debug mode)
          if (kDebugMode) ...[
            Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Row(
                      children: [
                        Icon(
                          Icons.developer_mode,
                          color: Colors.orange,
                          size: AppDimensions.iconMedium,
                        ),
                        const SizedBox(width: AppDimensions.paddingMedium),
                        Text(
                          l10n.developerSettings,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.refresh,
                      color: Colors.orange,
                    ),
                    title: Text(l10n.resetLessonData),
                    subtitle: const Text('Reseed from JSON assets'),
                    trailing: const Icon(Icons.warning_amber, color: Colors.orange),
                    onTap: () => _showResetConfirmDialog(context, l10n),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
          ],

          // App Info
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                children: [
                  Icon(
                    Icons.pets,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  const Text(
                    'Elli & Friends',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 8),
            Text(l10n.resetLessonData),
          ],
        ),
        content: Text(l10n.resetLessonDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _resetData(context, l10n);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData(BuildContext context, AppLocalizations l10n) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final seedService = SeedService(AppDatabase.instance);
      await seedService.resetAndReseed();

      if (context.mounted) {
        // Hide loading indicator
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.resetSuccess),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Hide loading indicator
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.incorrect,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showApiKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => const _ApiKeyDialog(),
    );
  }

  void _showAzureKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => const _AzureKeyDialog(),
    );
  }
}

/// Dialog for entering Claude API key
class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog();

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  final _controller = TextEditingController();
  bool _isLoading = true;
  bool _obscureText = true;
  bool _hasExistingKey = false;

  @override
  void initState() {
    super.initState();
    _loadExistingKey();
  }

  Future<void> _loadExistingKey() async {
    final service = await ApiKeyService.getInstance();
    final existingKey = service.getClaudeApiKey();
    if (existingKey != null && existingKey.isNotEmpty) {
      _controller.text = existingKey;
      _hasExistingKey = true;
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final service = await ApiKeyService.getInstance();
    await service.setClaudeApiKey(_controller.text.trim());

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.text.trim().isEmpty
                ? 'API key cleared'
                : 'API key saved',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.key, color: Colors.purple),
          SizedBox(width: 8),
          Text('Claude API Key'),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your Claude API key to enable auto-translation feature.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get your key at console.anthropic.com',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: 'sk-ant-...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.vpn_key),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                    ),
                  ),
                ),
                if (_hasExistingKey) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Key is currently set',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_hasExistingKey)
          TextButton(
            onPressed: () {
              _controller.clear();
              _saveKey();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ElevatedButton(
          onPressed: _saveKey,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Dialog for entering Azure TTS API key
class _AzureKeyDialog extends StatefulWidget {
  const _AzureKeyDialog();

  @override
  State<_AzureKeyDialog> createState() => _AzureKeyDialogState();
}

class _AzureKeyDialogState extends State<_AzureKeyDialog> {
  final _keyController = TextEditingController();
  bool _isLoading = true;
  bool _obscureText = true;
  bool _hasExistingKey = false;
  String _selectedRegion = 'eastus';

  static const _regions = [
    'eastus',
    'westus',
    'westus2',
    'westeurope',
    'northeurope',
    'southeastasia',
    'eastasia',
    'australiaeast',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingKey();
  }

  Future<void> _loadExistingKey() async {
    final service = await ApiKeyService.getInstance();
    final existingKey = service.getAzureApiKey();
    final region = service.getAzureRegion();

    if (existingKey != null && existingKey.isNotEmpty) {
      _keyController.text = existingKey;
      _hasExistingKey = true;
    }
    _selectedRegion = region;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final service = await ApiKeyService.getInstance();
    await service.setAzureApiKey(_keyController.text.trim());
    await service.setAzureRegion(_selectedRegion);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _keyController.text.trim().isEmpty
                ? 'Azure TTS key cleared'
                : 'Azure TTS key saved',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    if (_keyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an API key first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Test Azure TTS service connection
      final service = _createTestService();
      final success = await service.testConnection();
      service.dispose();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Connection successful!' : 'Connection failed',
            ),
            backgroundColor: success ? AppColors.success : AppColors.incorrect,
          ),
        );
      }
    } catch (e) {
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
        setState(() => _isLoading = false);
      }
    }
  }

  AzureTtsService _createTestService() {
    return AzureTtsService(
      subscriptionKey: _keyController.text.trim(),
      region: _selectedRegion,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.record_voice_over, color: Colors.blue),
          SizedBox(width: 8),
          Text('Azure TTS Key'),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your Azure Speech Services key for high-quality TTS.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get your key at portal.azure.com',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _keyController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Subscription Key',
                      hintText: 'Enter your Azure key',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.vpn_key),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscureText = !_obscureText);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    decoration: const InputDecoration(
                      labelText: 'Region',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    items: _regions.map((region) {
                      return DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRegion = value);
                      }
                    },
                  ),
                  if (_hasExistingKey) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Key is currently set',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_hasExistingKey)
          TextButton(
            onPressed: () {
              _keyController.clear();
              _saveKey();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        TextButton(
          onPressed: _testConnection,
          child: const Text('Test'),
        ),
        ElevatedButton(
          onPressed: _saveKey,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
