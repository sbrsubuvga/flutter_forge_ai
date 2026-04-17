import 'dart:io';

import 'package:flutterforge_ai_cli/flutterforge_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const String validFlutterPubspec = '''
name: demo_app
environment:
  sdk: ">=3.3.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
''';

const String counterMain = r"""
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  @override
  Widget build(BuildContext context) => Scaffold(body: Text('$_counter'));
}
""";

void main() {
  late Directory tmp;
  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('flutterforge_autowire_');
    File(p.join(tmp.path, 'pubspec.yaml'))
        .writeAsStringSync(validFlutterPubspec);
    Directory(p.join(tmp.path, 'lib')).createSync();
    File(p.join(tmp.path, 'lib', 'main.dart')).writeAsStringSync(counterMain);
  });
  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  test('--auto-wire rewrites counter template and keeps a backup', () async {
    final int? code = await FlutterForgeRunner().run(<String>[
      'init',
      '--path',
      tmp.path,
      '--auto-wire',
      '--no-run-pub-get',
    ]);
    expect(code, 0);

    final String rewritten =
        File(p.join(tmp.path, 'lib', 'main.dart')).readAsStringSync();
    expect(rewritten, contains('FlutterForgeAI.init'));
    expect(rewritten, contains('FFDevWrapper'));
    expect(rewritten, contains('FFStateObserver'));
    expect(rewritten, contains('class MyHomePage extends StatefulWidget'));

    final File backup = File(p.join(tmp.path, 'lib', 'main.dart.bak'));
    expect(backup.existsSync(), isTrue);
    expect(backup.readAsStringSync(), equals(counterMain));
  });

  test('--auto-wire skips non-standard main.dart', () async {
    File(p.join(tmp.path, 'lib', 'main.dart')).writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:some_router/some_router.dart';

Future<void> main() async {
  final r = SomeRouter();
  await r.bootstrap();
  runApp(r.buildApp());
}
''');
    final int? code = await FlutterForgeRunner().run(<String>[
      'init',
      '--path',
      tmp.path,
      '--auto-wire',
      '--no-run-pub-get',
    ]);
    expect(code, 0);
    // File untouched.
    expect(
      File(p.join(tmp.path, 'lib', 'main.dart')).readAsStringSync(),
      contains('SomeRouter'),
    );
    expect(
      File(p.join(tmp.path, 'lib', 'main.dart.bak')).existsSync(),
      isFalse,
    );
  });

  test('--auto-wire is a no-op on already-wired files', () async {
    const String alreadyWired = '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

Future<void> main() async {
  await FlutterForgeAI.init(config: const FFConfig(appName: 'A'));
  runApp(ProviderScope(
    observers: [FFStateObserver()],
    child: MaterialApp(
      builder: (c, w) => FFDevWrapper(child: w!),
      home: const SizedBox(),
    ),
  ));
}
''';
    File(p.join(tmp.path, 'lib', 'main.dart')).writeAsStringSync(alreadyWired);

    final int? code = await FlutterForgeRunner().run(<String>[
      'init',
      '--path',
      tmp.path,
      '--auto-wire',
      '--no-run-pub-get',
    ]);
    expect(code, 0);
    expect(
      File(p.join(tmp.path, 'lib', 'main.dart')).readAsStringSync(),
      equals(alreadyWired),
    );
  });
}
