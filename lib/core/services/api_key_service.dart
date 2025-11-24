import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing API keys
class ApiKeyService {
  static const _claudeApiKeyKey = 'claude_api_key';

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
}
