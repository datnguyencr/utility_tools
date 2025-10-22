import 'translations_manager.dart';

void main() {
  initTranslationsFolder();
}

void initTranslationsFolder() {
  final tool = TranslationsManager();
  tool.initFolder();
}
