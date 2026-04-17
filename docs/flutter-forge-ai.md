You are an expert Flutter package architect. Generate a complete, production-grade, pub.dev-ready open-source Flutter package called "flutterforge_ai" that will be published to pub.dev with a target quality score of 150+/160 points.

═══════════════════════════════════════════════════════════════════════════
PROJECT IDENTITY
═══════════════════════════════════════════════════════════════════════════

Package name: flutterforge_ai
Version: 0.1.0
Tagline: "AI-Ready Flutter Template — Build observable apps that AI can debug with full context"
Repository: https://github.com/<username>/flutterforge_ai
License: MIT
SDK: Dart >=3.3.0 <4.0.0, Flutter >=3.19.0
Supported platforms: Android, iOS, macOS, Windows, Linux, Web
Topics (pub.dev): debugging, devtools, ai, inspector, logger

═══════════════════════════════════════════════════════════════════════════
CORE PHILOSOPHY
═══════════════════════════════════════════════════════════════════════════

FlutterForge AI transforms Flutter apps into "observable systems" where AI can 
debug with full context instead of guessing from code alone. The unique selling 
point is the AI Debug Snapshot Generator — one tap captures the entire app state 
(DB + API + State + Logs + Device info) as structured JSON that a developer 
pastes to ChatGPT/Claude/Cursor for instant accurate fixes.

Old paradigm: print() → guess → retry (hours of debugging)
New paradigm: Tap button → paste to AI → get fix (30 seconds)

═══════════════════════════════════════════════════════════════════════════
COMPLETE FOLDER STRUCTURE
═══════════════════════════════════════════════════════════════════════════

flutterforge_ai/
├── lib/
│   ├── flutterforge_ai.dart                    # Public barrel export file
│   └── src/
│       ├── flutterforge_core.dart              # FlutterForgeAI singleton/init
│       ├── config/
│       │   ├── ff_config.dart                  # FFConfig class (all options)
│       │   └── ff_environment.dart             # Env loader wrapper
│       │
│       ├── core/
│       │   ├── db/
│       │   │   ├── ff_db_helper.dart           # Sqflite singleton wrapper
│       │   │   ├── ff_db_debug_enabler.dart    # sqflite_dev workbench setup
│       │   │   ├── ff_db_schema_reader.dart    # Read tables/columns/row counts
│       │   │   └── ff_db_query_runner.dart     # Execute raw SQL safely
│       │   ├── network/
│       │   │   ├── ff_api_client.dart          # Dio singleton + config
│       │   │   ├── ff_api_interceptor.dart     # Auto-capture interceptor
│       │   │   ├── ff_api_store.dart           # Ring buffer for API calls
│       │   │   ├── ff_api_call_model.dart      # APICall data model
│       │   │   └── ff_curl_exporter.dart       # Convert request → cURL string
│       │   ├── logger/
│       │   │   ├── ff_logger.dart              # Static logger facade
│       │   │   ├── ff_log_store.dart           # Ring buffer for logs
│       │   │   ├── ff_log_model.dart           # LogEntry data model
│       │   │   └── ff_log_level.dart           # Enum: verbose/debug/info/warning/error/fatal
│       │   └── state/
│       │       ├── ff_state_observer.dart      # Riverpod 3.0 ProviderObserver
│       │       ├── ff_state_store.dart         # Ring buffer for state changes
│       │       └── ff_state_change_model.dart  # StateChange data model
│       │
│       ├── devtools/
│       │   ├── ff_dev_wrapper.dart             # Wraps user's app, injects overlay
│       │   ├── ff_dev_dashboard.dart           # Main 4-tab dashboard
│       │   ├── ff_shake_detector.dart          # Shake to open (sensors_plus)
│       │   ├── ff_keyboard_shortcut.dart       # Alt+F12 on desktop
│       │   ├── screens/
│       │   │   ├── db_console_screen.dart      # Tables list + data viewer + query runner
│       │   │   ├── api_console_screen.dart     # Alice-style API inspector
│       │   │   ├── api_call_detail_screen.dart # Full request/response + cURL
│       │   │   ├── state_viewer_screen.dart    # Provider list + change history
│       │   │   ├── log_viewer_screen.dart      # Talker-style log list
│       │   │   └── snapshot_preview_screen.dart# Preview JSON before copy
│       │   └── widgets/
│       │       ├── ff_floating_button.dart     # Bottom-left devtools button
│       │       ├── ff_ai_debug_button.dart     # Bottom-right AI button (FAB)
│       │       ├── ff_bubble_overlay.dart      # Draggable bubble (like Alice)
│       │       ├── ff_json_viewer.dart         # Pretty JSON tree widget
│       │       ├── ff_search_bar.dart          # Reusable filter/search
│       │       ├── ff_status_code_chip.dart    # Color-coded HTTP badge
│       │       ├── ff_log_level_chip.dart      # Color-coded log level badge
│       │       └── ff_empty_state.dart         # Empty states
│       │
│       ├── snapshot/
│       │   ├── ff_snapshot_generator.dart      # Main generator class
│       │   ├── ff_snapshot_model.dart          # Snapshot data model
│       │   ├── ff_device_info_collector.dart   # Uses device_info_plus
│       │   ├── ff_package_info_collector.dart  # Uses package_info_plus
│       │   └── ff_prompt_formatter.dart        # Formats snapshot → AI prompt
│       │
│       └── utils/
│           ├── ff_constants.dart               # Package-wide constants
│           ├── ff_sensitive_data_masker.dart   # Mask auth tokens, cards, etc.
│           ├── ff_ring_buffer.dart             # Generic fixed-size buffer
│           ├── ff_clipboard_helper.dart        # Safe clipboard operations
│           ├── ff_platform_checker.dart        # Platform utilities
│           └── ff_pretty_printer.dart          # Pretty-print JSON/XML
│
├── example/                                    # Runnable demo app
│   ├── lib/
│   │   ├── main.dart                           # Full working example
│   │   └── features/
│   │       └── users_demo.dart                 # Shows package in action
│   ├── pubspec.yaml
│   ├── .env.example
│   └── README.md
│
├── test/                                       # Unit tests (80%+ coverage)
│   ├── core/
│   │   ├── db/
│   │   │   ├── ff_db_helper_test.dart
│   │   │   └── ff_db_schema_reader_test.dart
│   │   ├── network/
│   │   │   ├── ff_api_interceptor_test.dart
│   │   │   ├── ff_api_store_test.dart
│   │   │   └── ff_curl_exporter_test.dart
│   │   ├── logger/
│   │   │   ├── ff_logger_test.dart
│   │   │   └── ff_log_store_test.dart
│   │   └── state/
│   │       ├── ff_state_observer_test.dart
│   │       └── ff_state_store_test.dart
│   ├── snapshot/
│   │   ├── ff_snapshot_generator_test.dart
│   │   └── ff_prompt_formatter_test.dart
│   ├── utils/
│   │   ├── ff_ring_buffer_test.dart
│   │   └── ff_sensitive_data_masker_test.dart
│   └── flutterforge_ai_test.dart               # Integration test
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                              # Tests on every PR
│   │   ├── publish.yml                         # Auto-publish on tag
│   │   └── dartdoc.yml                         # Auto-generate docs
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── CONTRIBUTING.md
│   ├── CODE_OF_CONDUCT.md
│   └── FUNDING.yml
│
├── doc/
│   ├── images/                                 # Screenshots + GIFs
│   └── architecture.md                         # Deep dive
│
├── pubspec.yaml
├── README.md                                   # Marketing-grade
├── CHANGELOG.md
├── LICENSE                                     # MIT
├── analysis_options.yaml                       # Strict lints
├── .gitignore
├── .pubignore                                  # Exclude from pub publish
└── .metadata

═══════════════════════════════════════════════════════════════════════════
PUBSPEC.YAML (EXACT CONTENTS)
═══════════════════════════════════════════════════════════════════════════

name: flutterforge_ai
description: AI-Ready Flutter template with built-in DB console, API inspector, state viewer, log viewer, and AI debug snapshots. Build observable apps that AI can debug with full context.
version: 0.1.0
homepage: https://github.com/<username>/flutterforge_ai
repository: https://github.com/<username>/flutterforge_ai
issue_tracker: https://github.com/<username>/flutterforge_ai/issues
documentation: https://pub.dev/documentation/flutterforge_ai/latest/

topics:
  - debugging
  - devtools
  - ai
  - inspector
  - logger

environment:
  sdk: ">=3.3.0 <4.0.0"
  flutter: ">=3.19.0"

dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.3
  path: ^1.9.0
  dio: ^5.7.0
  flutter_riverpod: ^2.5.1
  logger: ^2.4.0
  flutter_dotenv: ^5.1.0
  pretty_dio_logger: ^1.4.0
  sensors_plus: ^6.0.1
  device_info_plus: ^10.1.2
  package_info_plus: ^8.0.2
  shared_preferences: ^2.3.2
  share_plus: ^10.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  sqflite_dev: ^0.1.0
  flutter_lints: ^4.0.0
  mocktail: ^1.0.4
  build_runner: ^2.4.11

flutter:
  assets:
    - assets/

═══════════════════════════════════════════════════════════════════════════
PUBLIC API DESIGN (THE MAGIC — 3 LINES TO GET EVERYTHING)
═══════════════════════════════════════════════════════════════════════════

// main.dart — what the developer writes
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterforge_ai/flutterforge_ai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ONE LINE SETUP
  await FlutterForgeAI.init(
    config: FFConfig(
      appName: 'My App',
      dbName: 'my_app.db',
      baseUrl: 'https://api.example.com',
      enableDevTools: true,           // auto-disabled in release
      enableDbWorkbench: true,        // starts localhost:8080 in debug
      dbWorkbenchPort: 8080,
      enableAiDebugButton: true,
      enableShakeToOpen: true,
      maxApiCallsStored: 200,
      maxLogsStored: 500,
      maxStateChangesStored: 300,
      sensitiveHeaders: {'authorization', 'x-api-key', 'cookie'},
      envFile: '.env',
    ),
  );
  
  runApp(
    ProviderScope(
      observers: [FFStateObserver()],    // auto-tracks Riverpod state
      child: FFDevWrapper(                // wraps app with overlay
        child: MyApp(),
      ),
    ),
  );
}

// Using the API client (auto-logged to API Inspector)
final dio = FFApiClient.instance.dio;
await dio.get('/users');

// Using the logger (auto-shown in Log Viewer)
FFLogger.info('User logged in');
FFLogger.error('Failed to load data', error: e, stackTrace: st);

// Using the DB (auto-visible in DB Console)
final db = FFDbHelper.instance.database;
await db.insert('users', {...});

// Generate AI snapshot manually
final snapshot = await FFSnapshotGenerator.generate(
  problem: 'User data not saving',
);
await FFSnapshotGenerator.copyToClipboard(snapshot);

═══════════════════════════════════════════════════════════════════════════
FEATURE SPECIFICATIONS (DEEPLY DETAILED)
═══════════════════════════════════════════════════════════════════════════

【 FEATURE 1: FFConfig — Developer Configuration 】

Class: FFConfig (immutable, copyWith pattern)

Fields:
- String appName (required)
- String dbName (default: 'flutterforge.db')
- int dbVersion (default: 1)
- String? baseUrl
- String? envFile
- bool enableDevTools (default: true)
- bool enableDbWorkbench (default: true)
- int dbWorkbenchPort (default: 8080)
- bool enableAiDebugButton (default: true)
- bool enableShakeToOpen (default: true)
- double shakeThreshold (default: 15.0)
- bool enableKeyboardShortcut (default: true) // Alt+F12 desktop
- int maxApiCallsStored (default: 200)
- int maxLogsStored (default: 500)
- int maxStateChangesStored (default: 300)
- Set<String> sensitiveHeaders (default: {auth, api-key, cookie, token})
- Set<String> sensitiveBodyKeys (default: {password, token, secret, ssn, credit_card})
- Duration apiTimeout (default: 30s)
- bool enablePrettyDioLogger (default: true)
- bool persistSnapshots (default: false)
- LogLevel minLogLevel (default: verbose)
- Color primaryColor (default: indigo)
- ThemeMode devToolsTheme (default: system)
- List<Interceptor> additionalInterceptors (default: [])
- FFConfig.defaults() factory constructor
- FFConfig.production() factory (minimal features)

【 FEATURE 2: FlutterForgeAI — Main Entry Point 】

Static class with:
- static Future<void> init({FFConfig? config})
- static FFConfig get config
- static bool get isInitialized
- static bool get showDevTools (returns !kReleaseMode && config.enableDevTools)
- static Future<void> reset() (for testing)

init() must:
1. Guard against double-init (idempotent)
2. Load .env if configured
3. Initialize FFLogger first
4. Initialize FFDbHelper
5. Enable sqflite_dev workbench if debug + enabled
6. Initialize FFApiClient with interceptor chain
7. Set up FlutterError.onError → FFLogger.error
8. Set up PlatformDispatcher.onError → FFLogger.error
9. Log success banner with ASCII art

【 FEATURE 3: Database Layer (FFDbHelper) 】

Features:
- Singleton with lazy init
- Opens DB at getDatabasesPath() + dbName
- Supports onCreate, onUpgrade, onDowngrade callbacks
- Auto-enables sqflite_dev workbench in debug mode using:
  db.enableWorkbench(
    webDebug: !kReleaseMode,
    webDebugPort: config.dbWorkbenchPort,
    webDebugName: config.appName,
  );
- Exposes clean API: insert, update, delete, query, rawQuery, batch, transaction
- Schema reader: getAllTables(), getColumns(table), getRowCount(table)
- Query runner: runRawQuery() with timeout & error capture
- Every DB operation auto-logs to FFLogger (debug level)
- Supports multiple databases via registerDatabase(name, db)

【 FEATURE 4: Network Layer (FFApiClient) 】

Features inspired by Alice + pretty_dio_logger + talker_dio_logger_plus:
- Dio singleton wrapper
- Default BaseOptions from config
- Auto-added interceptors in order:
  1. FFApiInterceptor (captures to FFApiStore)
  2. PrettyDioLogger (pretty console logs if enabled)
  3. User's additional interceptors
- FFApiInterceptor captures: method, URL, headers, body, queryParameters, 
  extra, timestamp, response status, response headers, response body, 
  duration (computed), error details, stack trace
- Auto-masks sensitive headers (replaces value with "***")
- Auto-masks sensitive body keys (recursive in JSON)
- FFApiStore: ring buffer, max size from config
- Methods on FFApiStore: getAll(), getByStatusCode(), search(query), 
  getFailedCalls(), clear(), getLatest()
- Stream<APICall> for real-time UI updates
- APICall.toCurl() — exports as cURL command (like talker_dio_logger_plus)
- APICall.toJson() — for snapshot

【 FEATURE 5: Logger (FFLogger) 】

Features inspired by Talker:
- Static facade with levels: verbose, debug, info, warning, error, fatal
- Methods: FFLogger.info(msg), .debug(msg), .warning(msg), .error(msg, error, stackTrace)
- Auto-timestamps every entry
- Auto-captures stackTrace for errors
- FFLogStore: ring buffer, max size from config
- Methods on FFLogStore: getAll(), getByLevel(), search(), getErrors(), clear()
- Stream<LogEntry> for real-time UI updates
- Pretty console output using logger package
- Color-coded in UI:
  - verbose: grey
  - debug: blue
  - info: green
  - warning: orange
  - error: red
  - fatal: dark red
- Captures FlutterError.onError globally
- Captures PlatformDispatcher.onError globally

【 FEATURE 6: State Observer (FFStateObserver) 】

Must use Riverpod 3.0 API:
- Extends ProviderObserver
- Overrides didAddProvider, didUpdateProvider, didDisposeProvider, 
  providerDidFail (new in 3.0)
- Uses ProviderObserverContext parameter
- Captures: provider name, previous value, new value, mutation info, timestamp
- Feeds into FFStateStore (ring buffer)
- Filters: only track user providers (exclude framework internals) via 
  packagePrefixes config
- Truncates large values (maxValueLength: 500 chars) with "...truncated"
- Stream<StateChange> for UI

【 FEATURE 7: DevTools Dashboard 】

FFDevDashboard widget:
- StatefulWidget with TabController
- 4 tabs: "Database", "API", "State", "Logs"
- Each tab uses real-time Stream listeners
- AppBar with: back button, search icon, clear icon, share icon
- Bottom sheet: "Generate AI Snapshot" button (prominent)
- Supports light/dark theme from config

Database Console Screen:
- Lists all tables with row counts
- Tap table → shows data grid with pagination (50 rows/page)
- Edit cell inline (update), delete row, add row
- "Run Query" button → SQL editor → results table
- "Export" → JSON/CSV
- Schema viewer: columns, types, constraints

API Console Screen:
- List of API calls (newest first)
- Each row: method chip, URL (truncated), status chip, duration
- Color-coded: 2xx green, 3xx blue, 4xx orange, 5xx red, error black
- Search bar: filter by URL, status, method
- Filter chips: All, Success, Failed, Pending
- Tap row → API Call Detail Screen:
  - Request tab: URL, method, headers, query params, body (pretty JSON)
  - Response tab: status, headers, body (pretty JSON)
  - Timing tab: start, end, duration
  - Actions: Copy cURL, Copy URL, Copy Response, Share
- Statistics panel: total calls, success rate, avg duration, failed count

State Viewer Screen:
- List of providers with current values
- Each row: provider name, type, current value (truncated), last updated
- Tap → change history timeline
- Filter by provider name
- Graph view (optional): dependency visualization

Log Viewer Screen:
- List of logs (newest first)
- Each row: timestamp, level chip, message (truncated)
- Filter chips: All, Verbose, Debug, Info, Warning, Error, Fatal
- Search bar
- Tap → log detail with full stackTrace
- Actions: Copy log, Clear all, Share

【 FEATURE 8: Access Mechanisms 】

FFDevWrapper widget:
- Shows 2 floating buttons in debug mode only:
  - Bottom-left: Purple FAB → opens dashboard
  - Bottom-right: Green FAB with 🤖 icon → AI debug
- Buttons are draggable (like Alice bubble)
- Shake to open (uses sensors_plus accelerometer)
- Keyboard shortcut Alt+F12 on desktop platforms
- Long-press triggers: 2-finger press 1 second (mobile)
- All triggers lead to FFDevDashboard

【 FEATURE 9: AI Debug Snapshot Generator (UNIQUE SELLING POINT) 】

FFSnapshotGenerator.generate({String? problem}) returns FFSnapshot:

Output JSON structure:
{
  "flutterforge_version": "0.1.0",
  "generated_at": "2026-04-16T10:30:45.123Z",
  "problem": "User describes here or null",
  "app": {
    "name": "My App",
    "version": "1.2.3",
    "build_number": "45",
    "package_name": "com.example.myapp",
    "debug_mode": true
  },
  "device": {
    "platform": "android",
    "os_version": "14",
    "model": "Pixel 7",
    "manufacturer": "Google",
    "is_physical": true,
    "locale": "en_US",
    "screen_size": "1080x2400"
  },
  "database": {
    "name": "my_app.db",
    "version": 1,
    "tables": [
      {
        "name": "users",
        "columns": [
          {"name": "id", "type": "INTEGER", "primaryKey": true},
          {"name": "email", "type": "TEXT", "nullable": false}
        ],
        "row_count": 42,
        "sample_rows": [...first 10 rows...]
      }
    ]
  },
  "api_logs": {
    "total_count": 15,
    "failed_count": 2,
    "recent_calls": [
      {
        "timestamp": "...",
        "method": "POST",
        "url": "https://api.example.com/users",
        "status_code": 401,
        "duration_ms": 342,
        "request_headers": {...masked...},
        "request_body": {...masked...},
        "response_body": {...},
        "error": "Unauthorized"
      }
    ]
  },
  "app_state": {
    "active_providers": [
      {
        "name": "authProvider",
        "type": "StateNotifierProvider",
        "current_value": "AuthState(token: null, user: null)",
        "last_updated": "..."
      }
    ],
    "recent_changes": [
      {
        "provider": "authProvider",
        "previous": "AuthState(token: 'abc')",
        "new": "AuthState(token: null)",
        "timestamp": "..."
      }
    ]
  },
  "logs": {
    "total_count": 127,
    "error_count": 3,
    "warning_count": 5,
    "recent_entries": [
      {
        "timestamp": "...",
        "level": "error",
        "message": "Failed to refresh token",
        "error": "DioException [401]",
        "stack_trace": "..."
      }
    ]
  }
}

FFPromptFormatter.format(snapshot) returns:

"""
I'm debugging a Flutter app. Here's the complete app context captured by 
FlutterForge AI. Please analyze and suggest a fix.

PROBLEM: {problem}

APP CONTEXT:
```json
{formatted_snapshot}
```

Please:
1. Identify the root cause
2. Suggest specific code fixes
3. Point to the exact provider/API/DB query that's failing
"""

Actions:
- FFSnapshotGenerator.copyToClipboard() → clipboard
- FFSnapshotGenerator.saveToFile() → JSON file
- FFSnapshotGenerator.share() → share_plus system share sheet
- Show snackbar: "✅ Snapshot copied! Paste to your AI assistant."

【 FEATURE 10: Safety & Privacy 】

- ALL devtools gated by: if (!kReleaseMode && config.enableDevTools)
- Sensitive data masking applied everywhere:
  - Headers: Authorization, X-API-Key, Cookie, Token → "***"
  - Body keys: password, token, secret, ssn, credit_card → "***"
  - URLs: query params named token/key/secret → "***"
- Configurable via config.sensitiveHeaders and config.sensitiveBodyKeys
- Never log in release builds
- DB web console disabled in release
- AI button hidden in release
- Snapshot generator disabled in release
- Shake detector disabled in release
- Unit tests verify all these safeguards

═══════════════════════════════════════════════════════════════════════════
CODE QUALITY REQUIREMENTS
═══════════════════════════════════════════════════════════════════════════

1. Every public class/method/field has /// dartdoc comments
2. Every public API has @immutable or @sealed where appropriate
3. All code null-safe, no dynamic unless justified
4. Zero warnings from `flutter analyze`
5. Uses flutter_lints with additional strict rules in analysis_options.yaml:
   - prefer_const_constructors
   - prefer_const_literals_to_create_immutables
   - avoid_print
   - public_member_api_docs
   - lines_longer_than_80_chars (off — allow 100)
6. 80%+ test coverage (unit + widget tests)
7. All async code properly awaited, no unawaited futures
8. Error handling with try/catch on all async boundaries
9. Stream subscriptions properly disposed
10. No hard-coded strings (use constants in ff_constants.dart)

═══════════════════════════════════════════════════════════════════════════
README.MD (MARKETING-GRADE)
═══════════════════════════════════════════════════════════════════════════

Must include:
- Catchy title with emoji and tagline
- Shield badges: pub version, likes, points, popularity, license, coverage
- Short value prop (1-2 sentences)
- Animated GIF showing AI Debug Button in action (placeholder link)
- "Why FlutterForge AI?" — compares old vs new debugging paradigm
- Features list with emojis (10-12 items)
- Screenshots grid (DB Console, API Inspector, State Viewer, Log Viewer, AI Snapshot)
- Installation section with pub add command
- Quick Start (3-line setup example)
- Full configuration example
- Usage examples for each feature
- Architecture diagram (ASCII or image)
- AI Debug Workflow section with example prompt
- FAQ (10 questions)
- Roadmap (future features)
- Contributing guide link
- License

═══════════════════════════════════════════════════════════════════════════
CHANGELOG.MD
═══════════════════════════════════════════════════════════════════════════

## 0.1.0 - Initial Release
### Added
- 🌐 Database web console via sqflite_dev integration
- 📡 In-app API Inspector with cURL export
- 🧠 Riverpod state viewer with change history
- 📝 Log viewer with level filtering
- 🤖 AI Debug Snapshot generator (one-click context capture)
- 🎯 Shake-to-open, Alt+F12 shortcut, floating buttons
- 🛡️ Automatic sensitive data masking
- 🔒 Release-mode safety (all devtools auto-disabled)
- 📱 Support for Android, iOS, macOS, Windows, Linux, Web

═══════════════════════════════════════════════════════════════════════════
EXAMPLE APP (MUST BE FULLY WORKING)
═══════════════════════════════════════════════════════════════════════════

example/lib/main.dart must:
- Demonstrate FlutterForgeAI.init() with full config
- Show a Users screen with CRUD operations
- Make real API calls to jsonplaceholder.typicode.com
- Use Riverpod StateNotifierProvider for state
- Have intentional "Trigger Error" button to demo error capture
- Have "Generate Snapshot" button to demo AI workflow
- Include comments explaining each feature

example/pubspec.yaml must reference local package via path: ../

═══════════════════════════════════════════════════════════════════════════
CI/CD (.github/workflows/)
═══════════════════════════════════════════════════════════════════════════

ci.yml:
- Triggers: push + PR on main
- Jobs: setup flutter, flutter pub get, flutter analyze, 
  flutter test --coverage, upload to codecov
- Matrix: Flutter stable + beta

publish.yml:
- Triggers: push tags matching v*.*.*
- Uses dart-lang/setup-dart/.github/workflows/publish.yml@v1
- Requires pub.dev OIDC configured

═══════════════════════════════════════════════════════════════════════════
TESTS (80%+ COVERAGE)
═══════════════════════════════════════════════════════════════════════════

For every public class, test:
- Happy path
- Error cases
- Edge cases (empty input, max size, null)
- State transitions
- Safety (release mode behavior)

Use mocktail for mocking Dio, Database, etc.
Widget tests for FFDevDashboard, FFAiDebugButton, screens.
Integration test in flutterforge_ai_test.dart that inits package end-to-end.

═══════════════════════════════════════════════════════════════════════════
FINAL OUTPUT REQUIREMENTS
═══════════════════════════════════════════════════════════════════════════

Generate EVERY file listed above with COMPLETE, PRODUCTION-READY code. 
NO placeholders. NO TODOs. NO "implement here" comments. 
Every file must be fully functional and immediately usable.

The package must:
✅ Pass `flutter pub publish --dry-run` with ZERO warnings
✅ Score 150+/160 on pub.dev
✅ Work on first `flutter run` in example/ with zero modifications
✅ Be immediately publishable to pub.dev
✅ Be accompanied by a marketing-grade README.md that functions as a 
   landing page for the package

Deliver the complete package in a structured format that I can directly 
commit to a GitHub repository and publish to pub.dev.