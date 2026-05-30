import 'package:shared_preferences/shared_preferences.dart';

class SaveService {
  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  static Future<void> setInt(String key, int value) async =>
      (await _prefs).setInt(key, value);

  static Future<void> setBool(String key, bool value) async =>
      (await _prefs).setBool(key, value);

  static Future<void> setString(String key, String value) async =>
      (await _prefs).setString(key, value);

  static Future<int> getInt(String key, int def) async =>
      (await _prefs).getInt(key) ?? def;

  static Future<bool> getBool(String key, bool def) async =>
      (await _prefs).getBool(key) ?? def;

  static Future<String> getString(String key, String def) async =>
      (await _prefs).getString(key) ?? def;

  static Future<void> clear() async => (await _prefs).clear();
}
