import 'package:dio/dio.dart';

import '../snapshot/ff_snapshot_model.dart';
import 'ff_ai_client.dart';
import 'ff_ai_config.dart';
import 'ff_ai_response.dart';

/// OpenAI (and OpenAI-compatible) client using the Chat Completions API.
///
/// Endpoint: `POST {baseUrl}/v1/chat/completions`
class FFOpenAiClient with FFAiClientBase {
  /// Creates a client. Tests inject a mock [dio].
  FFOpenAiClient(this._config, {Dio? dio})
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
      throw FFAiException('OpenAI API key missing — open AI settings first.');
    }
    logDiagnose('openai', _config.effectiveModel);

    try {
      final Response<Map<String, dynamic>> resp =
          await _dio.post<Map<String, dynamic>>(
        '/v1/chat/completions',
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer ${_config.apiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: <String, Object?>{
          'model': _config.effectiveModel,
          'max_tokens': _config.maxTokens,
          'temperature': _config.temperature,
          'messages': <Map<String, Object?>>[
            <String, Object?>{'role': 'system', 'content': systemPrompt},
            <String, Object?>{'role': 'user', 'content': userPrompt},
          ],
        },
      );

      final Map<String, dynamic> body = resp.data ?? <String, dynamic>{};
      final List<dynamic> choices =
          (body['choices'] as List<dynamic>?) ?? <dynamic>[];
      final Map<String, dynamic> firstChoice = choices.isEmpty
          ? const <String, dynamic>{}
          : (choices.first as Map<String, dynamic>);
      final Map<String, dynamic> message =
          (firstChoice['message'] as Map<String, dynamic>?) ??
              const <String, dynamic>{};
      final String text = (message['content']?.toString() ?? '').trim();

      final Map<String, dynamic> usage =
          (body['usage'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

      return FFAiResponse(
        text: text.isEmpty ? '(empty response)' : text,
        provider: 'openai',
        model: body['model']?.toString() ?? _config.effectiveModel,
        promptTokens: (usage['prompt_tokens'] as num?)?.toInt(),
        completionTokens: (usage['completion_tokens'] as num?)?.toInt(),
        finishReason: firstChoice['finish_reason']?.toString(),
      );
    } on DioException catch (e) {
      throw errorFromDio(e);
    }
  }
}
