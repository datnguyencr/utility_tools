import 'dart:convert';
import 'dart:io';

class TranslationsManager {
  final List<String> languages;
  final String folderPath;
  final dynamic jsonContent;
  final String defaultLocale;

  TranslationsManager({
    this.languages = const ['en', 'de', 'fr', 'ja', 'es', 'pt', 'ko', 'zh', 'vi', 'ru'],
    this.folderPath = 'assets/translations',
    this.jsonContent = const {'app_name': 'New App'},
    this.defaultLocale = 'en',
  });

  void initFolder() {
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

  void compareJsonKeys(String locale) {
    final defaultFile = File('$folderPath/$defaultLocale.json');
    final targetFile = File('$folderPath/$locale.json');

    if (!defaultFile.existsSync() || !targetFile.existsSync()) {
      print('One or both files do not exist.');
      return;
    }
    try {
      print('$locale.json:');

      final defaultJson = jsonDecode(defaultFile.readAsStringSync()) as Map<String, dynamic>;
      final targetJson = jsonDecode(targetFile.readAsStringSync()) as Map<String, dynamic>;

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
    } catch (error) {
      print('❌ Invalid JSON format');
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
