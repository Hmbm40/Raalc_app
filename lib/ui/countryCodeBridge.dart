// lib/native/ios_native_country_picker.dart
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class NativeCountryPicker {
  static const MethodChannel _channel = MethodChannel('native_country_picker');

  /// Presents the native iOS country picker.
  /// [countries] is a list of maps: { "name": "...", "code": "AE", "dialCode": "+971" }
  /// Returns a map with the same shape or null if cancelled / non-iOS.
  static Future<Map<String, String>?> present(
    List<Map<String, String>> countries, {
    String? initialDialCode,
  }) async {
    if (!Platform.isIOS) return null;
    final res = await _channel.invokeMethod<dynamic>('present', {
      'countries': countries,
      'initialDialCode': initialDialCode,
    });
    if (res == null) return null;
    final map = Map<String, dynamic>.from(res as Map);
    return map.map((k, v) => MapEntry(k, v?.toString() ?? ''));
  }
}
