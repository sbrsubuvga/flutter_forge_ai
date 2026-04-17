import 'package:flutter/material.dart';

import '../config/ff_config.dart';
import '../core/state/ff_state_store.dart';
import 'screens/api_console_screen.dart';
import 'screens/db_console_screen.dart';
import 'screens/log_viewer_screen.dart';
import 'screens/snapshot_preview_screen.dart';
import 'screens/state_viewer_screen.dart';

/// Four-tab devtools dashboard.
class FFDevDashboard extends StatelessWidget {
  /// Creates the dashboard.
  const FFDevDashboard({
    required this.config,
    required this.stateStore,
    super.key,
  });

  /// Active SDK config (for theming).
  final FFConfig config;

  /// State store to render in the "State" tab.
  final FFStateStore stateStore;

  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    final ThemeData themed = base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: config.primaryColor,
        brightness: base.brightness,
      ),
    );
    return Theme(
      data: themed,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('FlutterForge DevTools'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: <Tab>[
                Tab(icon: Icon(Icons.storage), text: 'Database'),
                Tab(icon: Icon(Icons.cloud_outlined), text: 'API'),
                Tab(icon: Icon(Icons.memory), text: 'State'),
                Tab(icon: Icon(Icons.notes), text: 'Logs'),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              const DbConsoleScreen(),
              const ApiConsoleScreen(),
              StateViewerScreen(store: stateStore),
              const LogViewerScreen(),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Text('🤖', style: TextStyle(fontSize: 20)),
            label: const Text('AI Snapshot'),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const SnapshotPreviewScreen(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
