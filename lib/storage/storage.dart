// coverage:ignore-file
abstract class Storage {
  Future<bool> setInt(String key, int value);

  int? getInt(String key);

  Future<bool> setBool(String key, bool value);

  bool? getBool(String key);

  Future<bool> setString(String key, String value);

  String? getString(String key);
}
