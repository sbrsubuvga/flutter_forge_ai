import 'dart:io';

import 'package:flutterforge_ai_cli/flutterforge_ai_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmp;
  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('flutterforge_doctor_');
  });
  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  Future<int?> runDoctor() =>
      FlutterForgeRunner().run(<String>['doctor', '--path', tmp.path]);

  test('returns non-zero when pubspec missing', () async {
    expect(await runDoctor(), isNonZero);
  });

  test('returns non-zero when package is not listed', () async {
    File(p.join(tmp.path, 'pubspec.yaml')).writeAsStringSync('''
name: app
environment:
  sdk: ">=3.3.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
''');
    Directory(p.join(tmp.path, 'lib')).createSync();
    File(p.join(tmp.path, 'lib', 'main.dart')).writeAsStringSync('void main() {}');
    expect(await runDoctor(), isNonZero);
  });

  test('returns 0 when fully wired', () async {
    File(p.join(tmp.path, 'pubspec.yaml')).writeAsStringSync('''
name: app
environment:
  sdk: ">=3.3.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  flutterforge_ai: ^0.1.1
''');
    Directory(p.join(tmp.path, 'lib')).createSync();
    File(p.join(tmp.path, 'lib', 'main.dart')).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterForgeAI.init(config: const FFConfig(appName: 'X'));
  runApp(ProviderScope(
    observers: [FFStateObserver()],
    child: MaterialApp(
      builder: (c, w) => FFDevWrapper(child: w!),
      home: const SizedBox(),
    ),
  ));
}
''');
    expect(await runDoctor(), 0);
  });
}
