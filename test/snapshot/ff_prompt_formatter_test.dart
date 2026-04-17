import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

void main() {
  group('FFPromptFormatter', () {
    final FFSnapshot s = FFSnapshot.empty(problem: 'Login loop');

    test('format includes problem and JSON', () {
      final String out = FFPromptFormatter.format(s);
      expect(out, contains('PROBLEM: Login loop'));
      expect(out, contains('```json'));
      expect(out, contains('"flutterforge_version"'));
    });

    test('format handles missing problem', () {
      final FFSnapshot noProblem = FFSnapshot.empty();
      final String out = FFPromptFormatter.format(noProblem);
      expect(out, contains('PROBLEM: (not specified'));
    });

    test('summary is short and mentions stats', () {
      final String out = FFPromptFormatter.summary(s);
      expect(out, contains('Flutter app summary'));
      expect(out.length, lessThan(600));
    });
  });
}
