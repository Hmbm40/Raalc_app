import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const _hasSeenIntroKey = 'hasSeenIntro';

  static Future<bool> getHasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenIntroKey) ?? false;
  }

  static Future<void> setHasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenIntroKey, true);
  }
}
