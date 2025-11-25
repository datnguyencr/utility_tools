import 'dart:convert';
import 'dart:io';

class EasyLocalizationHelper {
  final List<String> languages;
  final String folderPath;
  final dynamic jsonContent;
  final String defaultLocale;

  EasyLocalizationHelper({
    this.languages = const ['en', 'de', 'fr', 'ja', 'es', 'pt', 'ko', 'zh', 'vi', 'ru'],
    this.folderPath = 'assets/translations',
    this.jsonContent = const {'app_name': 'New App'},
    this.defaultLocale = 'en',
  });

  void init() {
    initAssetFolders();
    validateJson();
    compareJsonKeysAll();
  }

  void initAssetFolders() {
    final folder = Directory(folderPath);
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    languages.forEach(createLocaleFolder);
  }

  void compareJsonKeysAll() {
    for (final locale in languages) {
      if (locale == defaultLocale) {
        continue;
      }
      compareJsonKeys(locale);
    }
  }

  void _validateJsonFor(String? locale) {
    print('$locale.json:');
    try {
      final file = File('$folderPath/$locale.json');
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      print('✅ Valid JSON format');
    } catch (error) {
      print('❌ Invalid JSON format');
    }
  }

  void validateJson({String? target}) {
    if (target == null) {
      for (final locale in languages) {
        _validateJsonFor(locale);
      }
    } else {
      _validateJsonFor(target);
    }
  }

  void compareJsonKeys(String locale) {
    final defaultFile = File('$folderPath/$defaultLocale.json');
    final targetFile = File('$folderPath/$locale.json');
    print('$locale.json:');
    if (!defaultFile.existsSync()) {
      print('$defaultLocale.json does not exist.');
      return;
    }
    if (!targetFile.existsSync()) {
      print('$locale.json does not exist.');
      return;
    }
    var defaultJson = <String, dynamic>{};
    var targetJson = <String, dynamic>{};
    try {
      defaultJson = jsonDecode(defaultFile.readAsStringSync()) as Map<String, dynamic>;
      targetJson = jsonDecode(targetFile.readAsStringSync()) as Map<String, dynamic>;
    } catch (error) {
      print('❌ Invalid JSON format');
    }

    final enKeys = defaultJson.keys.toSet();
    final deKeys = targetJson.keys.toSet();

    final missingKeys = enKeys.difference(deKeys);
    final extraKeys = deKeys.difference(enKeys);

    if (missingKeys.isEmpty && extraKeys.isEmpty) {
      print('✅ All keys match!');
    } else {
      if (missingKeys.isNotEmpty) {
        print('❌ Keys missing: ${missingKeys.join(', ')}');
      }
      if (extraKeys.isNotEmpty) {
        print('❌ Extra keys: ${extraKeys.join(', ')}');
      }
    }
  }

  void createLocaleFolder(String locale) {
    final filePath = '$folderPath/$locale.json';
    final file = File(filePath);
    if (!file.existsSync()) {
      file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jsonContent));
      print('$filePath added');
    }
  }
}
