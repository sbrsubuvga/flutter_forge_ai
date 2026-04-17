import 'package:dio/dio.dart';

import '../core/logger/ff_logger.dart';
import '../snapshot/ff_snapshot_model.dart';
import 'ff_ai_config.dart';
import 'ff_ai_provider.dart';
import 'ff_ai_response.dart';
import 'ff_anthropic_client.dart';
import 'ff_openai_client.dart';

/// Abstract LLM client. Implementations are provider-specific; pick one via
/// [FFAiClient.forConfig].
abstract class FFAiClient {
  /// Creates a client for [config]'s provider. Each call constructs a new
  /// [Dio] instance so a test can inject a custom one via subclassing.
  factory FFAiClient.forConfig(FFAiConfig config, {Dio? dio}) {
    switch (config.provider) {
      case FFAiProvider.anthropic:
        return FFAnthropicClient(config, dio: dio);
      case FFAiProvider.openai:
        return FFOpenAiClient(config, dio: dio);
    }
  }

  /// Sends [prompt] to the underlying provider and returns the assistant text.
  ///
  /// Always throws [FFAiException] on any non-success path (wrong key,
  /// network error, rate-limit, etc.) so callers only need one catch block.
  Future<FFAiResponse> diagnose({
    required FFSnapshot snapshot,
    required String systemPrompt,
    required String userPrompt,
  });
}

/// Shared helpers for provider implementations. Not exported.
mixin FFAiClientBase implements FFAiClient {
  /// The active config for this client.
  FFAiConfig get config;

  /// Dio instance used for HTTP. A fresh one per client keeps interceptors
  /// isolated — these calls are skipped by the FlutterForge API inspector
  /// because they do not flow through `FFApiClient.instance.dio`.
  Dio get dio;

  /// Logs at info level — kept terse so real traffic isn't buried.
  void logDiagnose(String provider, String model) {
    FFLogger.info('Diagnose with $provider ($model)', tag: 'ai');
  }

  /// Builds a developer-friendly error from a Dio failure.
  FFAiException errorFromDio(DioException e) {
    final int? status = e.response?.statusCode;
    final Object? body = e.response?.data;
    final String label = status == null ? e.type.name : 'HTTP $status';
    return FFAiException(
      '$label: ${e.message ?? 'request failed'}',
      statusCode: status,
      providerBody: body,
    );
  }
}
