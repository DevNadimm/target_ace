import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:target_ace/core/config/app_config.dart';

class DeviceInfoHelper {
  DeviceInfoHelper._();

  static Map<String, dynamic> getDeviceInfo() {
    try {
      if (kIsWeb) {
        return {
          'platform': 'web',
          'os': 'web',
          'is_mobile': false,
        };
      }
      return {
        'platform': Platform.operatingSystem,
        'os_version': Platform.operatingSystemVersion,
        'locale': Platform.localeName,
        'numberOfProcessors': Platform.numberOfProcessors,
      };
    } catch (_) {
      return {
        'platform': 'unknown',
      };
    }
  }

  static String getAppVersion() {
    return AppConfig.appVersion;
  }
}