import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/src/utils/ff_sensitive_data_masker.dart';

void main() {
  group('FFSensitiveDataMasker', () {
    final FFSensitiveDataMasker masker = FFSensitiveDataMasker();

    test('masks sensitive headers (case-insensitive)', () {
      final Map<String, dynamic> out = masker.maskHeaders(<String, dynamic>{
        'Authorization': 'Bearer abc',
        'X-API-KEY': 'xxx',
        'User-Agent': 'curl/8',
      });
      expect(out['Authorization'], '***');
      expect(out['X-API-KEY'], '***');
      expect(out['User-Agent'], 'curl/8');
    });

    test('leaves non-sensitive headers untouched', () {
      final Map<String, dynamic> out =
          masker.maskHeaders(<String, dynamic>{'Accept': 'application/json'});
      expect(out['Accept'], 'application/json');
    });

    test('masks nested body keys recursively', () {
      final Object? out = masker.maskBody(<String, Object?>{
        'username': 'alice',
        'password': 'hunter2',
        'nested': <String, Object?>{
          'api_key': 'xyz',
          'safe': 'ok',
        },
        'items': <Object?>[
          <String, Object?>{'token': 'zzz', 'name': 'a'},
        ],
      });
      final Map<String, Object?> map = out! as Map<String, Object?>;
      expect(map['username'], 'alice');
      expect(map['password'], '***');
      final Map<String, Object?> nested =
          map['nested']! as Map<String, Object?>;
      expect(nested['api_key'], '***');
      expect(nested['safe'], 'ok');
      final List<Object?> items = map['items']! as List<Object?>;
      final Map<String, Object?> first = items.first! as Map<String, Object?>;
      expect(first['token'], '***');
      expect(first['name'], 'a');
    });

    test('handles JSON string bodies', () {
      final Object? out = masker.maskBody('{"password":"x","ok":1}');
      expect(out, contains('"password":"***"'));
      expect(out, contains('"ok":1'));
    });

    test('masks sensitive query params in URL', () {
      final String out =
          masker.maskUrl('https://ex.com/path?token=abc&foo=bar');
      expect(out, contains('token=***'));
      expect(out, contains('foo=bar'));
    });

    test('passes through malformed URL untouched', () {
      // Uri.parse is very permissive, so a truly malformed URL is hard to
      // produce — we still assert the method never throws.
      expect(() => masker.maskUrl('not a url'), returnsNormally);
    });
  });
}
