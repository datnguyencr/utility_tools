// ignore_for_file: avoid_print
import 'dart:io';

class GradleWrapperValidator {
  final Map<String, String> required;

  GradleWrapperValidator({
    this.required = const {
      'distributionBase': 'GRADLE_USER_HOME',
      'distributionPath': 'wrapper/dists',
      'zipStoreBase': 'GRADLE_USER_HOME',
      'zipStorePath': 'wrapper/dists',
      'distributionUrl': 'https://services.gradle.org/distributions/gradle-8.13-all.zip',
    },
  });

  final String gradleWrapperPath = 'android/gradle/wrapper/gradle-wrapper.properties';

  void validate() {
    final file = File(gradleWrapperPath);

    if (!file.existsSync()) {
      print('❌ gradle-wrapper.properties not found at $gradleWrapperPath');
      return;
    }

    final content = file.readAsStringSync();
    final lines = content.split('\n');

    print('🔍 Checking gradle-wrapper.properties...');

    // --- Check all non-version properties ---
    for (final entry in required.entries) {
      final key = entry.key;
      final expected = entry.value;

      if (key == 'distributionUrl') {
        continue; // handled separately
      }

      final line = lines.firstWhere((l) => l.startsWith('$key='), orElse: () => '');

      if (line.isEmpty) {
        print('❌ Missing: $key=$expected');
        continue;
      }

      final actualRaw = line.split('=').skip(1).join('=').trim();
      final actual = normalizeGradleValue(actualRaw);

      if (actual != expected) {
        print('⚠️ Mismatch: $key, Found: $actualRaw, Expected: $expected');
      } else {
        print('✅ $key OK');
      }
    }

    // --- Version check section ---
    final requiredUrl = required['distributionUrl']!;
    final requiredVersion = extractVersion(requiredUrl);

    final distLine = lines.firstWhere((l) => l.startsWith('distributionUrl='), orElse: () => '');

    if (distLine.isEmpty) {
      print('❌ Missing: distributionUrl');
      return;
    }

    final actualUrlRaw = distLine.split('=').skip(1).join('=').trim();
    final actualUrl = normalizeGradleValue(actualUrlRaw);
    final actualVersion = extractVersion(actualUrl);

    final cmp = compareVersions(actualVersion, requiredVersion);

    if (cmp >= 0) {
      print('✅ Gradle version: $actualVersion (>= Required version: $requiredVersion)');
      return;
    } else {
      print('📦 Required version: $requiredVersion');
      print('📦 Found version:    $actualVersion');
    }

    // outdated → update file
    print('🔧 Updating Gradle from $actualVersion → $requiredVersion');

    final newUrl = requiredUrl.replaceAll(':', r'\:'); // re-escape for Gradle

    final newLines = lines
        .map((l) {
          if (l.startsWith('distributionUrl=')) {
            return 'distributionUrl=$newUrl';
          }
          return l;
        })
        .join('\n');

    file.writeAsStringSync(newLines);

    print('✅ Updated distributionUrl to latest required version');
  }

  String normalizeGradleValue(String v) {
    return v.replaceAll(r'\:', ':').trim();
  }

  String extractVersion(String url) {
    final match = RegExp(r'gradle-(.*?)-all\.zip').firstMatch(url);
    return match?.group(1) ?? '';
  }

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
