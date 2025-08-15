import 'package:flutter/foundation.dart';

abstract class AnalyticsBackend {
  Future<void> track(String event, {Map<String, Object?> properties = const {}});
  Future<void> screen(String name, {Map<String, Object?> properties = const {}});
  Future<void> setUser(String userId, {Map<String, Object?> traits = const {}});
}

class ConsoleAnalytics implements AnalyticsBackend {
  @override
  Future<void> track(String event, {Map<String, Object?> properties = const {}}) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ANALYTICS] track: $event  props=$properties');
    }
  }

  @override
  Future<void> screen(String name, {Map<String, Object?> properties = const {}}) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ANALYTICS] screen: $name  props=$properties');
    }
  }

  @override
  Future<void> setUser(String userId, {Map<String, Object?> traits = const {}}) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ANALYTICS] user: $userId  traits=$traits');
    }
  }
}

class Analytics {
  static AnalyticsBackend backend = ConsoleAnalytics();

  static Future<void> track(String event, {Map<String, Object?> properties = const {}}) =>
      backend.track(event, properties: properties);

  static Future<void> screen(String name, {Map<String, Object?> properties = const {}}) =>
      backend.screen(name, properties: properties);

  static Future<void> setUser(String userId, {Map<String, Object?> traits = const {}}) =>
      backend.setUser(userId, traits: traits);
}
