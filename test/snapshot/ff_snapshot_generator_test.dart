import 'package:flutter_test/flutter_test.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

void main() {
  group('FFSnapshotGenerator — safety', () {
    test('returns empty snapshot when SDK is not initialised', () async {
      final FFSnapshot s = await FFSnapshotGenerator.generate(problem: 'oops');
      expect(s.problem, 'oops');
      expect(s.flutterForgeVersion, FFConstants.packageVersion);
      expect(s.app['name'], 'Unknown');
    });

    test('FFSnapshot.empty serialises to valid JSON', () {
      final FFSnapshot s = FFSnapshot.empty(problem: 'p');
      final Map<String, Object?> json = s.toJson();
      expect(json['flutterforge_version'], FFConstants.packageVersion);
      expect(json['problem'], 'p');
      expect(json['api_logs'], isA<Map<String, Object?>>());
    });
  });
}
