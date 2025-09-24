import 'dart:io';

final class ProcessUtils {
  ProcessUtils._();

  static void runProcess(String path) async {
    await Process.start(path, []);
  }

  static void openChrome(
      {String chromePath =
          r'C:\Program Files\Google\Chrome\Application\chrome.exe',
      required List<String> urls}) async {
    await Process.start(chromePath, urls);
  }
}
