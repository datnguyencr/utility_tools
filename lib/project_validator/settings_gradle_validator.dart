// ignore_for_file: avoid_print
import 'dart:io';

class SettingsGradleValidator {
  final String settingsPath = 'android/settings.gradle.kts';
  final Map<String, String> requiredPlugins;

  SettingsGradleValidator({
    this.requiredPlugins = const {
      'dev.flutter.flutter-plugin-loader': '1.0.0',
      'com.android.application': '8.12.2',
      'org.jetbrains.kotlin.android': '2.1.0',
    },
  });

  void validate() {
    final file = File(settingsPath);

    if (!file.existsSync()) {
      print('❌ settings.gradle.kts not found at $settingsPath');
      return;
    }

    final content = file.readAsStringSync();
    final lines = content.split('\n');

    print('🔍 Checking plugin versions in settings.gradle.kts...');

    final pluginRegex = RegExp(r'id\("([^"]+)"\)\s+version\s+"([^"]+)"');

    bool updated = false;
    final newLines = <String>[];

    for (var line in lines) {
      var updatedLine = line;
      final m = pluginRegex.firstMatch(line);

      if (m != null) {
        final pluginId = m.group(1)!;
        final foundVersion = m.group(2)!;

        final requiredVersion = requiredPlugins[pluginId];

        if (requiredVersion != null) {
          final cmp = compareVersions(foundVersion, requiredVersion);

          if (cmp < 0) {
            print('⚠️ $pluginId outdated:');
            print('Found: $foundVersion, Required: $requiredVersion');

            updated = true;

            updatedLine = line.replaceFirst(
              'version "$foundVersion"',
              'version "$requiredVersion"',
            );
          } else {
            print('✅ $pluginId OK (Found: $foundVersion ≥ Required: $requiredVersion)');
          }
        }
      }

      newLines.add(updatedLine);
    }

    if (updated) {
      print('🔧 Updating settings.gradle.kts...');
      file.writeAsStringSync(newLines.join('\n'));
      print('✅ Plugin versions updated.');
    } else {
      print('✨ No updates needed.');
    }
  }

  // ---- Version comparison (same logic as your other validator) ----
  int compareVersions(String a, String b) {
    final pa = a.split('.').map(int.parse).toList();
    final pb = b.split('.').map(int.parse).toList();

    final len = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < len; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va != vb) {
        return va.compareTo(vb);
      }
    }
    return 0;
  }
}
