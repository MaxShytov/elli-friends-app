import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing API keys
class ApiKeyService {
  static const _claudeApiKeyKey = 'claude_api_key';
  static const _azureApiKeyKey = 'azure_tts_api_key';
  static const _azureRegionKey = 'azure_tts_region';

  static ApiKeyService? _instance;
  final SharedPreferences _prefs;

  ApiKeyService._(this._prefs);

  /// Get singleton instance
  static Future<ApiKeyService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = ApiKeyService._(prefs);
    }
    return _instance!;
  }

  // ==================== CLAUDE API ====================

  /// Get Claude API key
  String? getClaudeApiKey() {
    return _prefs.getString(_claudeApiKeyKey);
  }

  /// Save Claude API key
  Future<bool> setClaudeApiKey(String apiKey) async {
    if (apiKey.isEmpty) {
      return _prefs.remove(_claudeApiKeyKey);
    }
    return _prefs.setString(_claudeApiKeyKey, apiKey);
  }

  /// Check if Claude API key is set
  bool hasClaudeApiKey() {
    final key = getClaudeApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Clear Claude API key
  Future<bool> clearClaudeApiKey() async {
    return _prefs.remove(_claudeApiKeyKey);
  }

  // ==================== AZURE TTS ====================

  /// Get Azure TTS API key
  String? getAzureApiKey() {
    return _prefs.getString(_azureApiKeyKey);
  }

  /// Save Azure TTS API key
  Future<bool> setAzureApiKey(String apiKey) async {
    if (apiKey.isEmpty) {
      return _prefs.remove(_azureApiKeyKey);
    }
    return _prefs.setString(_azureApiKeyKey, apiKey);
  }

  /// Check if Azure TTS API key is set
  bool hasAzureApiKey() {
    final key = getAzureApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Clear Azure TTS API key
  Future<bool> clearAzureApiKey() async {
    return _prefs.remove(_azureApiKeyKey);
  }

  /// Get Azure TTS region (default: eastus)
  String getAzureRegion() {
    return _prefs.getString(_azureRegionKey) ?? 'eastus';
  }

  /// Save Azure TTS region
  Future<bool> setAzureRegion(String region) async {
    if (region.isEmpty) {
      return _prefs.remove(_azureRegionKey);
    }
    return _prefs.setString(_azureRegionKey, region);
  }

  // ==================== UTILITY ====================

  /// Clear all API keys
  Future<void> clearAllKeys() async {
    await _prefs.remove(_claudeApiKeyKey);
    await _prefs.remove(_azureApiKeyKey);
    await _prefs.remove(_azureRegionKey);
  }
}
