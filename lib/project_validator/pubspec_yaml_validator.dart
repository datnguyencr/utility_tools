// ignore_for_file: avoid_print
import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class PubspecYamlValidator {
  final Map<String, String> requiredDeps;
  final Map<String, String> requiredDevDeps;

  PubspecYamlValidator({
    this.requiredDeps = const {
      'intl': '^0.20.2',
      'uuid': '^4.5.2',
      'package_info_plus': '^9.0.0',
      'equatable': '^2.0.7',
      'collection': '^1.19.1',
      'url_launcher': '^6.3.2',
      'shared_preferences': '^2.5.3',
      'json_annotation': '^4.9.0',
      'in_app_purchase': '^3.2.3',
      'fluttertoast': '^9.0.0',
      'device_info_plus': '^12.2.0',
      'logger': '^2.6.1',
      'firebase_core': '^4.2.1',
      'firebase_crashlytics': '^5.0.5',
      'firebase_auth': '^6.1.2',
      'google_mobile_ads': '^6.0.0',
      'share_plus': '^12.0.1',
      'retrofit': '^4.9.1',
      'dio': '^5.9.0',
      'dio_smart_retry': '^7.0.1',
      'bloc_concurrency': '^0.3.0',
      'path_provider': '^2.1.5',
      'crypto': '^3.0.7',
      'bloc': '^9.0.1',
      'flutter_bloc': '^9.1.1',
      'copy_with_extension': '^10.0.1',
      'in_app_purchase_android': '^0.4.0+8',
      'permission_handler': '^12.0.1',
      'image': '^4.5.4',
      'path': '^1.9.1',
      'stream_transform': '^2.1.1',
      'easy_localization': '^3.0.8',
    },
    this.requiredDevDeps = const {
      'build_runner': '^2.4.9',
      'json_serializable': '^6.11.3',
      'yaml': '^3.1.3',
    },
  });

  void validate() {
    const pubspecPath = 'pubspec.yaml';
    final file = File(pubspecPath);
    if (!file.existsSync()) {
      print('❌ pubspec.yaml not found');
      return;
    }

    final content = file.readAsStringSync();
    late YamlMap doc;
    try {
      doc = loadYaml(content) as YamlMap;
    } catch (e) {
      print('❌ Invalid YAML: $e');
      return;
    }

    final editor = YamlEditor(content);

    // --- Enforce Dart SDK version ---
    const enforcedSdk = '^3.9.0';
    final environment = doc['environment'] as YamlMap?;
    if (environment == null) {
      print('➕ Adding environment section with sdk: $enforcedSdk');
      editor.update(['environment'], {'sdk': enforcedSdk});
    } else {
      final currentSdk = environment['sdk']?.toString();
      if (currentSdk != enforcedSdk) {
        print('🔧 Updating Dart SDK from $currentSdk to $enforcedSdk');
        editor.update(['environment', 'sdk'], enforcedSdk);
      } else {
        print('✅ Dart SDK version is correct: $currentSdk');
      }
    }

    // --- Ensure dependencies ---
    final deps = Map<String, dynamic>.from(doc['dependencies'] as YamlMap? ?? {});
    final devDeps = Map<String, dynamic>.from(doc['dev_dependencies'] as YamlMap? ?? {});

    int compareVersions(String current, String required) {
      // Remove any ^ or + parts for simple numeric comparison
      String clean(String v) => v.replaceAll(RegExp(r'[^\d.]'), '');
      final cParts = clean(current).split('.').map(int.parse).toList();
      final rParts = clean(required).split('.').map(int.parse).toList();
      for (int i = 0; i < rParts.length; i++) {
        final c = i < cParts.length ? cParts[i] : 0;
        final r = rParts[i];
        if (c < r) {
          return -1;
        }
        if (c > r) {
          return 1;
        }
      }
      return 0;
    }

    for (var entry in requiredDeps.entries) {
      if (deps.containsKey(entry.key)) {
        final currentVersion = deps[entry.key].toString();
        if (compareVersions(currentVersion, entry.value) < 0) {
          print('🔧 Updating ${entry.key} from $currentVersion to ${entry.value}');
          editor.update(['dependencies', entry.key], entry.value);
        } else {
          print('✅ ${entry.key} : $currentVersion');
        }
      }
    }

    for (var entry in requiredDevDeps.entries) {
      if (devDeps.containsKey(entry.key)) {
        final currentVersion = devDeps[entry.key].toString();
        if (compareVersions(currentVersion, entry.value) < 0) {
          print('🔧 Updating ${entry.key} from $currentVersion to ${entry.value}');
          editor.update(['dev_dependencies', entry.key], entry.value);
        } else {
          print('✅ ${entry.key} : $currentVersion');
        }
      }
    }

    file.writeAsStringSync(editor.toString());
    print('✅ pubspec.yaml updated successfully');
  }
}
