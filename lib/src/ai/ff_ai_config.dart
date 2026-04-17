import 'package:flutter/foundation.dart';

import 'ff_ai_provider.dart';

/// Immutable AI client configuration.
///
/// The API key is **never** included in [toJson] — keys are stored separately
/// by [FFAiSettingsStore] and must stay out of AI snapshots.
@immutable
class FFAiConfig {
  /// Creates a config.
  const FFAiConfig({
    required this.provider,
    required this.apiKey,
    String? model,
    String? baseUrl,
    this.maxTokens = 1024,
    this.temperature = 0.2,
  })  : model = model ?? '',
        baseUrl = baseUrl ?? '';

  /// Active provider.
  final FFAiProvider provider;

  /// BYO API key — never logged, never serialised into snapshots.
  final String apiKey;

  /// Model id. Falls back to `provider.defaultModel` if empty.
  final String model;

  /// Base URL. Falls back to `provider.defaultBaseUrl` if empty.
  final String baseUrl;

  /// Upper bound on response tokens.
  final int maxTokens;

  /// Sampling temperature (0.0–1.0).
  final double temperature;

  /// Resolved model (explicit value or provider default).
  String get effectiveModel => model.isEmpty ? provider.defaultModel : model;

  /// Resolved base URL (explicit value or provider default).
  String get effectiveBaseUrl =>
      baseUrl.isEmpty ? provider.defaultBaseUrl : baseUrl;

  /// Whether the config has a usable API key.
  bool get isConfigured => apiKey.trim().isNotEmpty;

  /// Returns a copy with the given fields replaced.
  FFAiConfig copyWith({
    FFAiProvider? provider,
    String? apiKey,
    String? model,
    String? baseUrl,
    int? maxTokens,
    double? temperature,
  }) =>
      FFAiConfig(
        provider: provider ?? this.provider,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        baseUrl: baseUrl ?? this.baseUrl,
        maxTokens: maxTokens ?? this.maxTokens,
        temperature: temperature ?? this.temperature,
      );

  /// JSON form WITHOUT the API key — safe to persist or surface in the UI.
  Map<String, Object?> toJsonSansKey() => <String, Object?>{
        'provider': provider.name,
        'model': model,
        'base_url': baseUrl,
        'max_tokens': maxTokens,
        'temperature': temperature,
      };
}
