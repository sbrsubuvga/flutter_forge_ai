import 'dart:convert';
import 'dart:io';

import 'package:flutterforge_ai_cli/flutterforge_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmp;
  late File snapFile;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('flutterforge_snap_');
    snapFile = File(p.join(tmp.path, 'snap.json'))
      ..writeAsStringSync(jsonEncode(<String, Object?>{
        'flutterforge_version': '0.1.1',
        'problem': 'Login loop',
        'app': <String, Object?>{'name': 'Demo', 'version': '1.0.0'},
        'device': <String, Object?>{'platform': 'android'},
        'api_logs': <String, Object?>{'total_count': 3, 'failed_count': 1},
        'logs': <String, Object?>{
          'total_count': 12,
          'error_count': 1,
          'warning_count': 2,
        },
      }));
  });

  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  test('view pretty-prints JSON', () async {
    expect(
      await FlutterForgeRunner()
          .run(<String>['snapshot', 'view', snapFile.path]),
      0,
    );
  });

  test('summary returns 0', () async {
    expect(
      await FlutterForgeRunner()
          .run(<String>['snapshot', 'summary', snapFile.path]),
      0,
    );
  });

  test('prompt returns 0', () async {
    expect(
      await FlutterForgeRunner().run(
        <String>['snapshot', 'prompt', snapFile.path, '--problem', 'x'],
      ),
      0,
    );
  });

  test('missing file returns non-zero', () async {
    expect(
      await FlutterForgeRunner()
          .run(<String>['snapshot', 'view', p.join(tmp.path, 'nope.json')]),
      isNonZero,
    );
  });

  test('invalid JSON returns non-zero', () async {
    final File bad = File(p.join(tmp.path, 'bad.json'))
      ..writeAsStringSync('{not json');
    expect(
      await FlutterForgeRunner()
          .run(<String>['snapshot', 'view', bad.path]),
      isNonZero,
    );
  });
}
