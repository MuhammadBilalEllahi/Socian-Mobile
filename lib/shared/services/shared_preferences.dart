import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static final AppPrefs _instance = AppPrefs._internal();

  factory AppPrefs() => _instance;

  AppPrefs._internal();

  static SharedPreferences? _prefs;

  /// Call this once in main() before using the instance
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Getter
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /// Setter
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  /// Remove a key
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  /// Clear all prefs (use with caution)
  Future<void> clear() async {
    await _prefs?.clear();
  }
}
