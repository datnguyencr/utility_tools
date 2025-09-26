import 'package:shared_preferences/shared_preferences.dart';

import 'storage.dart';

class PrefStorage extends Storage {
  late SharedPreferences _prefs;

  PrefStorage({required SharedPreferences prefs}) {
    _prefs = prefs;
  }

  static Future<Storage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefStorage(prefs: prefs);
  }

  @override
  Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  @override
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  @override
  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  @override
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  @override
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }
}
