import 'package:dio/dio.dart';

import '../snapshot/ff_snapshot_model.dart';
import 'ff_ai_client.dart';
import 'ff_ai_config.dart';
import 'ff_ai_response.dart';

/// Anthropic Claude client (Messages API).
///
/// Endpoint: `POST {baseUrl}/v1/messages`
class FFAnthropicClient with FFAiClientBase {
  /// Creates a client. Tests inject a mock [dio].
  FFAnthropicClient(this._config, {Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: _config.effectiveBaseUrl));

  final FFAiConfig _config;
  final Dio _dio;

  @override
  FFAiConfig get config => _config;

  @override
  Dio get dio => _dio;

  @override
  Future<FFAiResponse> diagnose({
    required FFSnapshot snapshot,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    if (!_config.isConfigured) {
      throw FFAiException(
          'Anthropic API key missing — open AI settings first.');
    }
    logDiagnose('anthropic', _config.effectiveModel);

    try {
      final Response<Map<String, dynamic>> resp =
          await _dio.post<Map<String, dynamic>>(
        '/v1/messages',
        options: Options(
          headers: <String, String>{
            'x-api-key': _config.apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
        ),
        data: <String, Object?>{
          'model': _config.effectiveModel,
          'max_tokens': _config.maxTokens,
          'temperature': _config.temperature,
          'system': systemPrompt,
          'messages': <Map<String, Object?>>[
            <String, Object?>{
              'role': 'user',
              'content': userPrompt,
            },
          ],
        },
      );

      final Map<String, dynamic> body = resp.data ?? <String, dynamic>{};
      final List<dynamic> contents =
          (body['content'] as List<dynamic>?) ?? <dynamic>[];
      final String text = contents
          .whereType<Map<String, dynamic>>()
          .where((Map<String, dynamic> c) => c['type'] == 'text')
          .map((Map<String, dynamic> c) => c['text']?.toString() ?? '')
          .join('\n')
          .trim();

      final Map<String, dynamic> usage =
          (body['usage'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

      return FFAiResponse(
        text: text.isEmpty ? '(empty response)' : text,
        provider: 'anthropic',
        model: body['model']?.toString() ?? _config.effectiveModel,
        promptTokens: (usage['input_tokens'] as num?)?.toInt(),
        completionTokens: (usage['output_tokens'] as num?)?.toInt(),
        finishReason: body['stop_reason']?.toString(),
      );
    } on DioException catch (e) {
      throw errorFromDio(e);
    }
  }
}
