import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../base/tool.dart';

class IdenticalChecker extends Tool {
  @override
  String name() => 'Check Duplicate Files';

  @override
  String description() => 'Scan a folder and find identical files by hash.';

  Future<void> checkFiles(String folderPath, List<String> extensions) async {
    final folder = Directory(folderPath);

    if (!folder.existsSync()) {
      if (kDebugMode) {
        print('Folder does not exist: $folderPath');
      }
      return;
    }

    // Step 1: Group files by size
    final Map<int, List<File>> sizeMap = {};

    // Catch errors from restricted folders
    await for (final entity in folder.list(recursive: true, followLinks: false).handleError((e) {
      if (kDebugMode) {
        print('Skipping: $e');
      }
    }, test: (e) => e is FileSystemException)) {
      if (entity is File) {
        final ext = entity.path.split('.').last.toLowerCase();
        if (!extensions.contains(ext)) {
          continue; // skip non-image files
        }

        try {
          final size = await entity.length();
          sizeMap.putIfAbsent(size, () => []).add(entity);
        } catch (e) {
          if (kDebugMode) {
            print('Error reading file size ${entity.path}: $e');
          }
        }
      }
    }

    // Step 2: Within each size group, compute hashes
    bool foundDuplicates = false;
    for (final entry in sizeMap.entries) {
      final files = entry.value;
      if (files.length < 2) {
        continue; // no possible duplicates
      }

      final Map<String, List<String>> hashMap = {};

      for (final file in files) {
        try {
          final bytes = await file.readAsBytes();
          final hash = sha256.convert(bytes).toString();
          hashMap.putIfAbsent(hash, () => []).add(file.path);
        } catch (e) {
          if (kDebugMode) {
            print('Error hashing file ${file.path}: $e');
          }
        }
      }

      // Step 3: Print duplicates
      hashMap.forEach((hash, paths) {
        if (paths.length > 1) {
          foundDuplicates = true;
          if (kDebugMode) {
            print('Duplicate images:');
          }
          for (final p in paths) {
            if (kDebugMode) {
              print('   $p');
            }
          }
          if (kDebugMode) {
            print('---------------------');
          }
        }
      });
    }

    if (!foundDuplicates) {
      if (kDebugMode) {
        print('No identical files found.');
      }
    }
  }
}

void main() async {
  final tool = IdenticalChecker();
  // Folder to scan
  const folderPath = r'D:\pics';
  final extensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  await tool.checkFiles(folderPath, extensions);
}
