import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

void main() {
  group('FFCurlExporter.fromParts', () {
    final FFCurlExporter exporter = FFCurlExporter(FFSensitiveDataMasker());

    test('produces GET with headers', () {
      final String curl = exporter.fromParts(
        method: 'GET',
        url: 'https://ex.com/users',
        headers: <String, Object?>{'Accept': 'application/json'},
      );
      expect(curl, contains("curl -X 'GET'"));
      expect(curl, contains("'https://ex.com/users'"));
      expect(curl, contains("'Accept: application/json'"));
    });

    test('embeds JSON body', () {
      final String curl = exporter.fromParts(
        method: 'POST',
        url: 'https://ex.com/u',
        headers: <String, Object?>{'Content-Type': 'application/json'},
        body: <String, Object?>{'name': 'a'},
      );
      expect(curl, contains("-X 'POST'"));
      expect(curl, contains('"name":"a"'));
    });

    test('escapes single quotes in values', () {
      final String curl = exporter.fromParts(
        method: 'POST',
        url: "https://ex.com/it's",
        headers: const <String, Object?>{},
      );
      // cURL single-quote escape: '\''
      expect(curl, contains(r"it'\''s"));
    });
  });
}
