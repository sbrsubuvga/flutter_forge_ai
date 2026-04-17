/// Package-wide constants used by FlutterForge AI.
///
/// Centralising magic strings here keeps the rest of the package
/// free of hard-coded literals and makes i18n/theming tweaks easy.
library;

/// Constants shared across the package.
class FFConstants {
  FFConstants._();

  /// Current package version. Kept in sync with `pubspec.yaml`.
  static const String packageVersion = '0.1.1';

  /// Human-readable package name used in logs and snapshots.
  static const String packageName = 'FlutterForge AI';

  /// Default database filename if the developer does not configure one.
  static const String defaultDbName = 'flutterforge.db';

  /// Default ring-buffer size for API calls.
  static const int defaultMaxApiCalls = 200;

  /// Default ring-buffer size for logs.
  static const int defaultMaxLogs = 500;

  /// Default ring-buffer size for state changes.
  static const int defaultMaxStateChanges = 300;

  /// Default mask used when sensitive values are redacted.
  static const String redactionMask = '***';

  /// Default port for the sqflite dev workbench.
  static const int defaultWorkbenchPort = 8080;

  /// Default shake-detection threshold in m/s^2.
  static const double defaultShakeThreshold = 15.0;

  /// Default request timeout.
  static const Duration defaultApiTimeout = Duration(seconds: 30);

  /// Default lowercase header names treated as sensitive.
  static const Set<String> defaultSensitiveHeaders = <String>{
    'authorization',
    'x-api-key',
    'cookie',
    'set-cookie',
    'token',
    'x-auth-token',
    'proxy-authorization',
  };

  /// Default lowercase body keys treated as sensitive.
  static const Set<String> defaultSensitiveBodyKeys = <String>{
    'password',
    'pass',
    'token',
    'secret',
    'ssn',
    'credit_card',
    'cc',
    'cvv',
    'api_key',
    'apikey',
    'access_token',
    'refresh_token',
  };

  /// URL query-parameter names that should be masked when shown.
  static const Set<String> sensitiveQueryParams = <String>{
    'token',
    'key',
    'secret',
    'password',
    'api_key',
  };

  /// Maximum length for truncated provider values in the state store.
  static const int defaultMaxStateValueLength = 500;

  /// ASCII banner printed once at `init()` time.
  static const String banner = r'''
╔══════════════════════════════════════════════════════════════╗
║  ███████╗███████╗     █████╗ ██╗                             ║
║  ██╔════╝██╔════╝    ██╔══██╗██║                             ║
║  █████╗  █████╗      ███████║██║                             ║
║  ██╔══╝  ██╔══╝      ██╔══██║██║                             ║
║  ██║     ██║         ██║  ██║██║                             ║
║  ╚═╝     ╚═╝         ╚═╝  ╚═╝╚═╝                             ║
║  FlutterForge AI — observable apps AI can actually debug.    ║
╚══════════════════════════════════════════════════════════════╝
''';
}
