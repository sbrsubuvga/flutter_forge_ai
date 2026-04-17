/// Detection + rewriting of `lib/main.dart` for `flutterforge init --auto-wire`.
///
/// Deliberately conservative — we only touch the file when we recognise one
/// of a small set of known template shapes. Anything else returns
/// [WiringShape.unknown] and the caller prints the manual snippet instead.
class MainDartWiring {
  MainDartWiring._();

  /// Classifies [source] into a known or unknown shape.
  static WiringShape classify(String source) {
    // Already wired — leave it alone.
    if (source.contains('FlutterForgeAI.init') ||
        source.contains('FFDevWrapper')) {
      return WiringShape.alreadyWired;
    }

    final bool hasMyApp = RegExp(r'class\s+MyApp\b').hasMatch(source);
    final bool hasCounterHomePage =
        RegExp(r'class\s+MyHomePage\b').hasMatch(source) &&
            RegExp(r'int\s+_counter').hasMatch(source);
    final bool hasRunAppMyApp = RegExp(
      r'runApp\s*\(\s*const\s+MyApp\s*\(\s*\)\s*\)',
    ).hasMatch(source);

    if (hasMyApp && hasCounterHomePage && hasRunAppMyApp) {
      return WiringShape.counterTemplate;
    }
    if (hasMyApp && hasRunAppMyApp) {
      return WiringShape.minimalMyApp;
    }
    return WiringShape.unknown;
  }

  /// Returns the rewritten source for a known [shape], or throws
  /// [StateError] if the shape is not patchable.
  ///
  /// Strategy: drop the file's imports, its `main()` function, and its
  /// `MyApp` class (which is boilerplate in the targeted templates).
  /// Replace them with a canonical FlutterForge-wired version. Every other
  /// class in the file (e.g. the counter template's `MyHomePage`) is
  /// preserved verbatim.
  static String wire(String source, {required String appName}) {
    final WiringShape shape = classify(source);
    if (shape == WiringShape.alreadyWired) return source;
    if (shape == WiringShape.unknown) {
      throw StateError(
        'Unsupported main.dart shape — skip --auto-wire and paste the '
        'snippet from `flutterforge init` manually.',
      );
    }

    final String preserved = _stripImportsMainAndMyApp(source);
    final String homeExpr = preserved.contains('class MyHomePage')
        ? 'const MyHomePage(title: \'${_escape(appName)}\')'
        : 'const Scaffold(body: Center(child: Text(\'${_escape(appName)}\')))';

    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterForgeAI.init(
    config: const FFConfig(appName: '${_escape(appName)}'),
  );
  runApp(
    ProviderScope(
      observers: <ProviderObserver>[FFStateObserver()],
      child: const MyApp(),
    ),
  );
}

/// Rewritten by `flutterforge init --auto-wire` — `FFDevWrapper` is
/// injected through `MaterialApp.builder` so the devtools overlay sees the
/// app's Navigator and MediaQuery.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${_escape(appName)}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        useMaterial3: true,
      ),
      builder: (BuildContext context, Widget? child) =>
          FFDevWrapper(child: child ?? const SizedBox.shrink()),
      home: $homeExpr,
    );
  }
}

$preserved
''';
  }

  /// Strips imports, the `main()` function, and the `MyApp` class.
  static String _stripImportsMainAndMyApp(String source) {
    final String noImports = _stripImports(source);
    final String noMain = _stripMain(noImports);
    final String noMyApp = _stripClass(noMain, 'MyApp');
    return noMyApp.trim();
  }

  static String _stripImports(String source) {
    return source
        .split('\n')
        .where(
            (String line) => !RegExp(r'''^\s*import\s+['"]''').hasMatch(line))
        .join('\n');
  }

  static String _stripMain(String source) {
    // Arrow form.
    final RegExp arrow = RegExp(
      r'''(?:Future<void>\s+)?void\s+main\s*\([^)]*\)\s*(?:async\s*)?=>\s*[^;]+;''',
      multiLine: true,
    );
    final String afterArrow = source.replaceAll(arrow, '');
    if (afterArrow != source) return afterArrow;

    final Match? header = RegExp(
      r'(?:Future<void>\s+)?void\s+main\s*\([^)]*\)\s*(?:async\s*)?\{',
    ).firstMatch(source);
    if (header == null) return source;
    final int endIndex = _matchClosingBrace(source, header.end - 1);
    if (endIndex < 0) return source;
    return source.substring(0, header.start) + source.substring(endIndex + 1);
  }

  static String _stripClass(String source, String className) {
    final Match? header = RegExp(
      'class\\s+$className\\b[^{]*\\{',
    ).firstMatch(source);
    if (header == null) return source;
    final int endIndex = _matchClosingBrace(source, header.end - 1);
    if (endIndex < 0) return source;
    return source.substring(0, header.start) + source.substring(endIndex + 1);
  }

  static int _matchClosingBrace(String source, int openIndex) {
    int depth = 0;
    for (int i = openIndex; i < source.length; i++) {
      final String ch = source[i];
      if (ch == '{') depth++;
      if (ch == '}') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }

  static String _escape(String value) =>
      value.replaceAll("\\", r"\\").replaceAll("'", r"\'");
}

/// Result of shape detection.
enum WiringShape {
  /// Default `flutter create` counter template.
  counterTemplate,

  /// `MyApp` + `runApp(const MyApp())` but no counter boilerplate.
  minimalMyApp,

  /// File already imports or calls FlutterForge APIs.
  alreadyWired,

  /// Anything else — we refuse to touch it automatically.
  unknown,
}
