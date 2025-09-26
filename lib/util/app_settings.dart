import '../storage/storage.dart';

class AppSettings {
  static const String keyAppTheme = 'keyAppTheme';
  static const String keyDarkTheme = 'keyDarkTheme';
  static const String keyLogLevel = 'keyLogLevel';
  static const String keyLanguage = 'keyLanguage';

  AppSettings._(); // coverage:ignore-line

  static late Storage _storage;
  static double screenHeight = 0;
  static double screenWidth = 0;
  static bool isTablet = false;
  static String userId = '';
  static String appVersion = '';
  static String appName = '';
  static String buildNumber = '';
  static String packageName = '';

  static bool isDesktopApp = false;

  static Future<bool> init(Storage storage) async {
    try {
      _storage = storage;

      return true;
    } catch (error) {
      return false;
    }
  }

  static double dialogWidth() {
    const cap = 600.0;
    final width = AppSettings.screenWidth;
    return (width < cap) ? width : cap;
  }
}
