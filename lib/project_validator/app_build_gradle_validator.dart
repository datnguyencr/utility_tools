// ignore_for_file: avoid_print
import 'dart:io';

class AppBuildGradleValidator {
  final String buildGradlePath = 'android/app/build.gradle.kts';
  final Map<String, String> requiredAndroid;
  final Map<String, String> requiredCompileOptions;
  final Map<String, String> requiredKotlinOptions;
  final Map<String, String> requiredDefaultConfig;
  final Map<String, String> requiredFlutter;

  AppBuildGradleValidator({
    this.requiredAndroid = const {
      'compileSdk': 'flutter.compileSdkVersion',
      'ndkVersion': 'flutter.ndkVersion',
    },
    this.requiredCompileOptions = const {
      'sourceCompatibility': 'JavaVersion.VERSION_11',
      'targetCompatibility': 'JavaVersion.VERSION_11',
    },
    this.requiredKotlinOptions = const {'jvmTarget': 'JavaVersion.VERSION_11.toString()'},
    this.requiredDefaultConfig = const {
      'minSdk': 'flutter.minSdkVersion',
      'targetSdk': 'flutter.targetSdkVersion',
      'versionCode': 'flutter.versionCode',
      'versionName': 'flutter.versionName',
    },
    this.requiredFlutter = const {'source': '"../.."'},
  });

  void validate() {
    final file = File(buildGradlePath);

    if (!file.existsSync()) {
      print('❌ build.gradle.kts not found at $buildGradlePath');
      return;
    }

    final lines = file.readAsStringSync().split('\n');
    final updatedLines = <String>[];
    bool insideSigning = false;
    bool insideBuildTypes = false;

    String currentBlock = '';
    String? applicationIdValue;
    String? namespaceValue;

    for (var line in lines) {
      final trimmed = line.trim();

      // Detect blocks
      if (trimmed.startsWith('signingConfigs')) {
        insideSigning = true;
      }
      if (trimmed.startsWith('buildTypes')) {
        insideBuildTypes = true;
      }

      // Preserve signingConfigs and buildTypes completely
      if (insideSigning || insideBuildTypes) {
        updatedLines.add(line);
        if (trimmed == '}') {
          if (insideSigning) {
            insideSigning = false;
          }
          if (insideBuildTypes) {
            insideBuildTypes = false;
          }
        }
        continue;
      }

      // Detect current block
      if (trimmed.startsWith('plugins {')) {
        currentBlock = 'plugins';
      }
      if (trimmed.startsWith('android {')) {
        currentBlock = 'android';
      }
      if (trimmed.startsWith('defaultConfig {')) {
        currentBlock = 'defaultConfig';
      }
      if (trimmed.startsWith('compileOptions {')) {
        currentBlock = 'compileOptions';
      }
      if (trimmed.startsWith('kotlinOptions {')) {
        currentBlock = 'kotlinOptions';
      }
      if (trimmed.startsWith('flutter {')) {
        currentBlock = 'flutter';
      }

      // Capture applicationId in defaultConfig
      if (currentBlock == 'defaultConfig' && trimmed.startsWith('applicationId =')) {
        applicationIdValue = trimmed.split('=').last.trim().replaceAll('"', '');
      }

      // Capture namespace in android
      if (currentBlock == 'android' && trimmed.startsWith('namespace =')) {
        namespaceValue = trimmed.split('=').last.trim().replaceAll('"', '');
        if (applicationIdValue != null && namespaceValue != applicationIdValue) {
          print('⚠️ namespace mismatch: $namespaceValue != applicationId $applicationIdValue');
        }
      }

      // Update other required values
      Map<String, String>? checkMap;
      if (currentBlock == 'android') {
        checkMap = requiredAndroid;
      }
      if (currentBlock == 'defaultConfig') {
        checkMap = requiredDefaultConfig;
      }
      if (currentBlock == 'compileOptions') {
        checkMap = requiredCompileOptions;
      }
      if (currentBlock == 'kotlinOptions') {
        checkMap = requiredKotlinOptions;
      }
      if (currentBlock == 'flutter') {
        checkMap = requiredFlutter;
      }

      if (checkMap != null) {
        for (var entry in checkMap.entries) {
          final key = entry.key;
          final requiredValue = entry.value;
          if (trimmed.startsWith('$key =')) {
            final actualValue = trimmed.split('=').last.trim();
            if (actualValue != requiredValue) {
              print('🔧 Updating $key: $actualValue → $requiredValue');
              line = line.replaceAll(actualValue, requiredValue);
            }
          }
        }
      }

      updatedLines.add(line);
    }

    file.writeAsStringSync(updatedLines.join('\n'));
    print('✅ build.gradle.kts validated and updated');
  }
}
