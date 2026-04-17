import 'package:flutterforge_ai_cli/src/main_dart_wiring.dart';
import 'package:test/test.dart';

const String counterTemplate = r"""
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

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(child: Text('Count: $_counter')),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}
""";

const String minimalMyApp = r"""
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: SizedBox());
}
""";

const String alreadyWired = r"""
import 'package:flutterforge_ai/flutterforge_ai.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await FlutterForgeAI.init();
  runApp(const MyApp());
}
""";

const String nonStandard = r"""
import 'package:flutter/material.dart';
import 'package:some_router/some_router.dart';

Future<void> main() async {
  final router = SomeRouter();
  await router.bootstrap();
  runApp(router.buildApp());
}
""";

void main() {
  group('MainDartWiring.classify', () {
    test('detects counter template', () {
      expect(
        MainDartWiring.classify(counterTemplate),
        WiringShape.counterTemplate,
      );
    });

    test('detects minimal MyApp', () {
      expect(
        MainDartWiring.classify(minimalMyApp),
        WiringShape.minimalMyApp,
      );
    });

    test('detects already-wired files', () {
      expect(
        MainDartWiring.classify(alreadyWired),
        WiringShape.alreadyWired,
      );
    });

    test('rejects non-standard shapes', () {
      expect(
        MainDartWiring.classify(nonStandard),
        WiringShape.unknown,
      );
    });
  });

  group('MainDartWiring.wire (counter template)', () {
    late String wired;
    setUp(() {
      wired = MainDartWiring.wire(counterTemplate, appName: 'My App');
    });

    test('imports flutterforge_ai', () {
      expect(wired,
          contains("import 'package:flutterforge_ai/flutterforge_ai.dart';"));
    });

    test('imports flutter_riverpod', () {
      expect(
        wired,
        contains("import 'package:flutter_riverpod/flutter_riverpod.dart';"),
      );
    });

    test('calls FlutterForgeAI.init with app name', () {
      expect(wired, contains('FlutterForgeAI.init'));
      expect(wired, contains("FFConfig(appName: 'My App')"));
    });

    test('registers FFStateObserver on ProviderScope', () {
      expect(wired, contains('ProviderScope'));
      expect(wired, contains('FFStateObserver()'));
    });

    test('wraps MaterialApp.builder with FFDevWrapper', () {
      expect(wired, contains('FFDevWrapper(child: child'));
    });

    test('drops the template MyApp class but keeps MyHomePage', () {
      // MyApp is rewritten to the FlutterForge-wired version, so the old
      // "Flutter Demo" title disappears.
      expect(wired, isNot(contains("'Flutter Demo Home Page'")));
      // MyHomePage stateful widget is preserved.
      expect(wired, contains('class MyHomePage extends StatefulWidget'));
      expect(wired, contains('int _counter = 0;'));
    });
  });

  test('wire refuses unknown shapes', () {
    expect(
      () => MainDartWiring.wire(nonStandard, appName: 'X'),
      throwsA(isA<StateError>()),
    );
  });

  test('wire is a no-op on already-wired files', () {
    expect(
      MainDartWiring.wire(alreadyWired, appName: 'X'),
      equals(alreadyWired),
    );
  });
}
