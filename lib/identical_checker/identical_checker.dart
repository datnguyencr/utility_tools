import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class IdenticalChecker {
  Map<String, List<String>> duplicateGroups = {};

  Future<void> checkFiles(String folderPath, List<String> extensions) async {
    duplicateGroups.clear();

    final dir = Directory(folderPath);

    if (!await dir.exists()) {
      if (kDebugMode) {
        print('Directory does not exist: $folderPath');
      }
      return;
    }

    final allFiles = await _listFilesRecursively(dir, extensions);

    final Map<String, List<String>> hashMap = {};

    for (final file in allFiles) {
      final hash = await _getFileHash(file);
      if (hash == null) {
        continue;
      }

      if (!hashMap.containsKey(hash)) {
        hashMap[hash] = [];
      }
      hashMap[hash]!.add(file.path);
    }

    // Keep only groups with duplicates
    duplicateGroups = {
      for (var entry in hashMap.entries)
        if (entry.value.length > 1) entry.key: entry.value
    };
  }

  Future<List<File>> _listFilesRecursively(Directory dir, List<String> extensions) async {
    final List<File> files = [];

    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase().replaceAll('.', '');
        if (extensions.contains(ext)) {
          files.add(entity);
        }
      }
    }
    return files;
  }

  Future<String?> _getFileHash(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final digest = md5.convert(bytes); // MD5 hash for file content
      return digest.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error hashing file ${file.path}: $e');
      }
      return null;
    }
  }
}
