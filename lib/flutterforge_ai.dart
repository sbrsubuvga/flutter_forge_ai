/// FlutterForge AI — AI-Ready Flutter template.
///
/// A single-import package exposing DB console, API inspector, state viewer,
/// log viewer, and an AI Debug Snapshot generator.
///
/// ```dart
/// import 'package:flutterforge_ai/flutterforge_ai.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await FlutterForgeAI.init(
///     config: FFConfig(appName: 'My App'),
///   );
///   runApp(
///     ProviderScope(
///       observers: [FFStateObserver()],
///       child: FFDevWrapper(child: MyApp()),
///     ),
///   );
/// }
/// ```
library flutterforge_ai;

// Core entry point.
export 'src/flutterforge_core.dart' show FlutterForgeAI;

// Config.
export 'src/config/ff_config.dart';
export 'src/config/ff_environment.dart';

// Core: Logger.
export 'src/core/logger/ff_log_level.dart';
export 'src/core/logger/ff_log_model.dart';
export 'src/core/logger/ff_log_store.dart';
export 'src/core/logger/ff_logger.dart';

// Core: DB.
export 'src/core/db/ff_db_helper.dart';
export 'src/core/db/ff_db_query_runner.dart';
export 'src/core/db/ff_db_schema_reader.dart';

// Core: Network.
export 'src/core/network/ff_api_call_model.dart';
export 'src/core/network/ff_api_client.dart';
export 'src/core/network/ff_api_interceptor.dart';
export 'src/core/network/ff_api_store.dart';
export 'src/core/network/ff_curl_exporter.dart';

// Core: State.
export 'src/core/state/ff_state_change_model.dart'
    show FFStateChange, FFStateChangeType;
export 'src/core/state/ff_state_observer.dart' show FFStateObserver;
export 'src/core/state/ff_state_store.dart';

// Snapshot.
export 'src/snapshot/ff_device_info_collector.dart'
    show FFDeviceInfo, FFDeviceInfoCollector;
export 'src/snapshot/ff_package_info_collector.dart'
    show FFPackageInfo, FFPackageInfoCollector;
export 'src/snapshot/ff_prompt_formatter.dart';
export 'src/snapshot/ff_snapshot_generator.dart';
export 'src/snapshot/ff_snapshot_model.dart';

// Devtools (widgets).
export 'src/devtools/ff_dev_dashboard.dart';
export 'src/devtools/ff_dev_wrapper.dart';
export 'src/devtools/ff_shake_detector.dart';
export 'src/devtools/ff_keyboard_shortcut.dart';
export 'src/devtools/widgets/ff_ai_debug_button.dart';
export 'src/devtools/widgets/ff_bubble_overlay.dart';
export 'src/devtools/widgets/ff_empty_state.dart';
export 'src/devtools/widgets/ff_floating_button.dart';
export 'src/devtools/widgets/ff_json_viewer.dart';
export 'src/devtools/widgets/ff_log_level_chip.dart';
export 'src/devtools/widgets/ff_search_bar.dart';
export 'src/devtools/widgets/ff_status_code_chip.dart';

// Utils that library consumers may find useful.
export 'src/utils/ff_clipboard_helper.dart';
export 'src/utils/ff_constants.dart';
export 'src/utils/ff_platform_checker.dart';
export 'src/utils/ff_pretty_printer.dart';
export 'src/utils/ff_sensitive_data_masker.dart';
