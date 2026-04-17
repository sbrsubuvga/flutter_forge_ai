import 'package:shared_preferences/shared_preferences.dart';

import '../core/logger/ff_logger.dart';
import 'ff_ai_config.dart';
import 'ff_ai_provider.dart';

/// Persists the user's AI provider config via `SharedPreferences`.
///
/// Keys live under the `flutterforge.ai.*` namespace. The API key is stored
/// AS-IS — `SharedPreferences` is not a secure keystore. Users who need
/// hardened storage can swap this out (see the `SettingsSource` extension
/// point reserved at the bottom of this file).
class FFAiSettingsStore {
  /// Creates a store wrapping an existing prefs instance. Most callers use
  /// [FFAiSettingsStore.load] instead.
  FFAiSettingsStore(this._prefs);

  /// Loads the `SharedPreferences` singleton and wraps it.
  static Future<FFAiSettingsStore> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return FFAiSettingsStore(prefs);
  }

  final SharedPreferences _prefs;

  static const String _kProvider = 'flutterforge.ai.provider';
  static const String _kApiKey = 'flutterforge.ai.api_key';
  static const String _kModel = 'flutterforge.ai.model';
  static const String _kBaseUrl = 'flutterforge.ai.base_url';
  static const String _kMaxTokens = 'flutterforge.ai.max_tokens';
  static const String _kTemperature = 'flutterforge.ai.temperature';

  /// Reads the current config. Returns an unconfigured default if nothing
  /// is stored yet.
  FFAiConfig read() {
    final String providerName =
        _prefs.getString(_kProvider) ?? FFAiProvider.anthropic.name;
    final FFAiProvider provider = FFAiProvider.values.firstWhere(
      (FFAiProvider p) => p.name == providerName,
      orElse: () => FFAiProvider.anthropic,
    );
    return FFAiConfig(
      provider: provider,
      apiKey: _prefs.getString(_kApiKey) ?? '',
      model: _prefs.getString(_kModel) ?? '',
      baseUrl: _prefs.getString(_kBaseUrl) ?? '',
      maxTokens: _prefs.getInt(_kMaxTokens) ?? 1024,
      temperature: _prefs.getDouble(_kTemperature) ?? 0.2,
    );
  }

  /// Persists [config]. Never logs the API key.
  Future<void> write(FFAiConfig config) async {
    await _prefs.setString(_kProvider, config.provider.name);
    await _prefs.setString(_kApiKey, config.apiKey);
    await _prefs.setString(_kModel, config.model);
    await _prefs.setString(_kBaseUrl, config.baseUrl);
    await _prefs.setInt(_kMaxTokens, config.maxTokens);
    await _prefs.setDouble(_kTemperature, config.temperature);
    FFLogger.info(
      'AI config saved (${config.provider.name} / ${config.effectiveModel})',
      tag: 'ai',
    );
  }

  /// Wipes everything. Used by "Clear AI settings" in the UI.
  Future<void> clear() async {
    for (final String key in <String>[
      _kProvider,
      _kApiKey,
      _kModel,
      _kBaseUrl,
      _kMaxTokens,
      _kTemperature,
    ]) {
      await _prefs.remove(key);
    }
    FFLogger.info('AI config cleared', tag: 'ai');
  }
}
