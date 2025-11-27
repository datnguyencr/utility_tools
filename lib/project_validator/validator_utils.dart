// ignore_for_file: avoid_print
import 'dart:io';

class ValidatorUtils {
  ValidatorUtils._();

  /// Returns true if target file matches template exactly, false otherwise
  static bool checkLineByLine({required String targetPath, required String templatePath}) {
    final targetFile = File(targetPath);
    final templateFile = File(templatePath);

    if (!targetFile.existsSync()) {
      print('❌ Target file missing: $targetPath');
      return false;
    }
    if (!templateFile.existsSync()) {
      print('❌ Template file missing: $templatePath');
      return false;
    }

    final targetContent = targetFile.readAsStringSync().trim();
    final templateContent = templateFile.readAsStringSync().trim();

    if (targetContent == templateContent) {
      print('✅ $targetPath matches the $templatePath exactly');
      return true;
    } else {
      print('❌ $targetPath does NOT match the $templatePath');
      print('--- Diff Preview ---');

      final targetLines = targetContent.split('\n');
      final templateLines = templateContent.split('\n');
      final maxLines = targetLines.length > templateLines.length
          ? targetLines.length
          : templateLines.length;

      for (var i = 0; i < maxLines; i++) {
        final wLine = i < targetLines.length ? targetLines[i] : '<missing>';
        final tLine = i < templateLines.length ? templateLines[i] : '<missing>';
        if (wLine.trim() != tLine.trim()) {
          print('Line ${i + 1} mismatch:');
          print('❌ $wLine');
          print('✅ $tLine');
        }
      }
      return false;
    }
  }

  static void ensureFileExists({
    required String templatePath,
    required String targetPath,
  }) {
    final targetFile = File(targetPath);
    final targetDir = targetFile.parent;

    // create dir if missing
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    if (!targetFile.existsSync()) {
      final templateFile = File(templatePath);

      if (templateFile.existsSync()) {
        targetFile.writeAsStringSync(templateFile.readAsStringSync());
        print('✅ File copied from $templatePath to $targetPath');
      } else {
        print('❌ Template file missing: $templatePath');
      }
    } else {
      print('✅ File already exists at $targetPath');
    }
  }

}
