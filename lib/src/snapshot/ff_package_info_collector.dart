import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Normalised package description used in snapshots.
@immutable
class FFPackageInfo {
  /// Creates a package info object.
  const FFPackageInfo({
    required this.name,
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  /// Human-readable app name (from pubspec / platform manifest).
  final String name;

  /// Semantic version string.
  final String version;

  /// Build number.
  final String buildNumber;

  /// Bundle / application ID (`com.example.app`).
  final String packageName;

  /// JSON form for snapshots.
  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'version': version,
        'build_number': buildNumber,
        'package_name': packageName,
      };
}

/// Collects package info via `package_info_plus`.
class FFPackageInfoCollector {
  FFPackageInfoCollector._();

  /// Collects package info. Returns sensible defaults on failure.
  static Future<FFPackageInfo> collect(
      {String fallbackName = 'Unknown'}) async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      return FFPackageInfo(
        name: info.appName.isEmpty ? fallbackName : info.appName,
        version: info.version,
        buildNumber: info.buildNumber,
        packageName: info.packageName,
      );
    } catch (_) {
      return FFPackageInfo(
        name: fallbackName,
        version: '0.0.0',
        buildNumber: '0',
        packageName: 'unknown',
      );
    }
  }
}
