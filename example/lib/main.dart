import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

import 'features/users_demo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // One-line SDK setup. Everything is disabled automatically in release mode.
  await FlutterForgeAI.init(
    config: const FFConfig(
      appName: 'FlutterForge Example',
      dbName: 'flutterforge_example.db',
      baseUrl: 'https://jsonplaceholder.typicode.com',
      enableDevTools: true,
      enableDbWorkbench: true,
      enableAiDebugButton: true,
      enableShakeToOpen: true,
      enableKeyboardShortcut: true,
      maxApiCallsStored: 200,
      maxLogsStored: 500,
      maxStateChangesStored: 300,
    ),
  );

  runApp(
    ProviderScope(
      // Tracks every Riverpod provider event into the devtools State Viewer.
      observers: <ProviderObserver>[FFStateObserver()],
      child: const ExampleApp(),
    ),
  );
}

/// Root widget.
class ExampleApp extends StatelessWidget {
  /// Creates the app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterForge Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        useMaterial3: true,
      ),
      // Placing FFDevWrapper here (inside MaterialApp.builder) makes sure
      // the devtools overlay has access to the app's Directionality and
      // Navigator — the root Navigator push/pop works from the FAB.
      builder: (BuildContext context, Widget? child) =>
          FFDevWrapper(child: child ?? const SizedBox.shrink()),
      home: const UsersScreen(),
    );
  }
}
