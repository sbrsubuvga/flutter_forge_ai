import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../utils/ff_platform_checker.dart';

/// Normalised device description used in AI snapshots.
@immutable
class FFDeviceInfo {
  /// Creates a device descriptor.
  const FFDeviceInfo({
    required this.platform,
    this.osVersion,
    this.model,
    this.manufacturer,
    this.isPhysical,
    this.locale,
    this.screenSize,
    this.extra = const <String, Object?>{},
  });

  /// Platform name (`android`, `ios`, `macos`, ...).
  final String platform;

  /// OS version string.
  final String? osVersion;

  /// Device model (Pixel 7, iPhone 15, ...).
  final String? model;

  /// Device manufacturer.
  final String? manufacturer;

  /// True if the device is physical (false = simulator / emulator).
  final bool? isPhysical;

  /// BCP-47 locale.
  final String? locale;

  /// Screen size, e.g. `1080x2400`.
  final String? screenSize;

  /// Any extra fields provided by `device_info_plus`.
  final Map<String, Object?> extra;

  /// JSON form for snapshots.
  Map<String, Object?> toJson() => <String, Object?>{
        'platform': platform,
        'os_version': osVersion,
        'model': model,
        'manufacturer': manufacturer,
        'is_physical': isPhysical,
        'locale': locale,
        'screen_size': screenSize,
        if (extra.isNotEmpty) 'extra': extra,
      };
}

/// Collects device info via `device_info_plus`, degrading gracefully on
/// unsupported platforms.
class FFDeviceInfoCollector {
  FFDeviceInfoCollector._();

  /// Collects device info. Never throws.
  static Future<FFDeviceInfo> collect() async {
    final String platform = FFPlatformChecker.name;
    try {
      final DeviceInfoPlugin plugin = DeviceInfoPlugin();

      if (FFPlatformChecker.isAndroid) {
        final AndroidDeviceInfo info = await plugin.androidInfo;
        return FFDeviceInfo(
          platform: platform,
          osVersion: info.version.release,
          model: info.model,
          manufacturer: info.manufacturer,
          isPhysical: info.isPhysicalDevice,
          extra: <String, Object?>{
            'sdk_int': info.version.sdkInt,
            'device': info.device,
            'brand': info.brand,
          },
        );
      }
      if (FFPlatformChecker.isIOS) {
        final IosDeviceInfo info = await plugin.iosInfo;
        return FFDeviceInfo(
          platform: platform,
          osVersion: info.systemVersion,
          model: info.utsname.machine,
          manufacturer: 'Apple',
          isPhysical: info.isPhysicalDevice,
          extra: <String, Object?>{
            'system_name': info.systemName,
            'name': info.name,
          },
        );
      }
      if (FFPlatformChecker.isMacOS) {
        final MacOsDeviceInfo info = await plugin.macOsInfo;
        return FFDeviceInfo(
          platform: platform,
          osVersion: info.osRelease,
          model: info.model,
          manufacturer: 'Apple',
          isPhysical: true,
          extra: <String, Object?>{
            'computer_name': info.computerName,
            'arch': info.arch,
          },
        );
      }
      if (FFPlatformChecker.isWindows) {
        final WindowsDeviceInfo info = await plugin.windowsInfo;
        return FFDeviceInfo(
          platform: platform,
          osVersion:
              '${info.majorVersion}.${info.minorVersion}.${info.buildNumber}',
          model: info.productName,
          manufacturer: 'Microsoft',
          isPhysical: true,
          extra: <String, Object?>{
            'computer_name': info.computerName,
          },
        );
      }
      if (FFPlatformChecker.isLinux) {
        final LinuxDeviceInfo info = await plugin.linuxInfo;
        return FFDeviceInfo(
          platform: platform,
          osVersion: info.version,
          model: info.prettyName,
          manufacturer: info.name,
          isPhysical: true,
        );
      }
      if (FFPlatformChecker.isWeb) {
        final WebBrowserInfo info = await plugin.webBrowserInfo;
        return FFDeviceInfo(
          platform: platform,
          osVersion: info.appVersion,
          model: info.browserName.name,
          manufacturer: info.vendor,
          isPhysical: false,
          extra: <String, Object?>{
            'user_agent': info.userAgent,
            'platform': info.platform,
          },
        );
      }
    } catch (_) {
      // Fall through to minimal info.
    }
    return FFDeviceInfo(platform: platform);
  }
}
