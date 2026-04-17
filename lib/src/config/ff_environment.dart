import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Thin wrapper over `flutter_dotenv` that is safe to call even when the
/// app did not configure an env file.
class FFEnvironment {
  FFEnvironment._();

  /// True once [load] completed successfully.
  static bool _loaded = false;

  /// Whether an env file has been loaded.
  static bool get isLoaded => _loaded;

  /// Loads [fileName] via `flutter_dotenv`.
  ///
  /// Failures are swallowed so a missing file never prevents [FlutterForgeAI]
  /// from starting; the consumer can check [isLoaded].
  static Future<void> load(String? fileName) async {
    if (fileName == null || fileName.isEmpty) return;
    try {
      await dotenv.load(fileName: fileName);
      _loaded = true;
    } catch (_) {
      _loaded = false;
    }
  }

  /// Reads a variable from the loaded env, or [defaultValue] if missing.
  static String get(String key, {String defaultValue = ''}) {
    if (!_loaded) return defaultValue;
    try {
      return dotenv.get(key, fallback: defaultValue);
    } catch (_) {
      return defaultValue;
    }
  }

  /// True if [key] exists in the env.
  static bool has(String key) => _loaded && dotenv.env.containsKey(key);

  /// Snapshot of every loaded env variable. Empty if nothing loaded.
  static Map<String, String> get all => _loaded
      ? Map<String, String>.unmodifiable(dotenv.env)
      : const <String, String>{};
}
