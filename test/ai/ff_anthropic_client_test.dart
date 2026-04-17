import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/x'));
    registerFallbackValue(Options());
  });

  group('FFAnthropicClient', () {
    test('throws when API key is missing', () async {
      final FFAnthropicClient client = FFAnthropicClient(
        const FFAiConfig(provider: FFAiProvider.anthropic, apiKey: ''),
      );
      expect(
        () => client.diagnose(
          snapshot: FFSnapshot.empty(),
          systemPrompt: 'sys',
          userPrompt: 'usr',
        ),
        throwsA(isA<FFAiException>()),
      );
    });

    test('parses a valid Messages API response', () async {
      final _MockDio dio = _MockDio();
      when(() => dio.post<Map<String, dynamic>>(
            any<String>(),
            data: any<Object?>(named: 'data'),
            options: any<Options>(named: 'options'),
          )).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/v1/messages'),
          statusCode: 200,
          data: <String, dynamic>{
            'model': 'claude-sonnet-4-5',
            'stop_reason': 'end_turn',
            'usage': <String, dynamic>{
              'input_tokens': 123,
              'output_tokens': 45,
            },
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'text',
                'text': 'Looks like a missing await in authProvider.refresh.',
              },
            ],
          },
        ),
      );

      final FFAnthropicClient client = FFAnthropicClient(
        const FFAiConfig(provider: FFAiProvider.anthropic, apiKey: 'sk-test'),
        dio: dio,
      );
      final FFAiResponse resp = await client.diagnose(
        snapshot: FFSnapshot.empty(problem: 'Login loop'),
        systemPrompt: 'sys',
        userPrompt: 'usr',
      );
      expect(resp.provider, 'anthropic');
      expect(resp.model, 'claude-sonnet-4-5');
      expect(resp.text, contains('missing await'));
      expect(resp.promptTokens, 123);
      expect(resp.completionTokens, 45);
      expect(resp.finishReason, 'end_turn');
    });

    test('wraps DioException as FFAiException', () async {
      final _MockDio dio = _MockDio();
      when(() => dio.post<Map<String, dynamic>>(
            any<String>(),
            data: any<Object?>(named: 'data'),
            options: any<Options>(named: 'options'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/v1/messages'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/v1/messages'),
            statusCode: 401,
            data: <String, Object?>{'error': 'invalid_api_key'},
          ),
          message: 'auth failed',
          type: DioExceptionType.badResponse,
        ),
      );

      final FFAnthropicClient client = FFAnthropicClient(
        const FFAiConfig(provider: FFAiProvider.anthropic, apiKey: 'sk-x'),
        dio: dio,
      );

      expectLater(
        client.diagnose(
          snapshot: FFSnapshot.empty(),
          systemPrompt: 'sys',
          userPrompt: 'usr',
        ),
        throwsA(
          isA<FFAiException>()
              .having((FFAiException e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });
}
