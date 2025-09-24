import 'dart:io';

import 'package:crypto/crypto.dart';

import '../base/tool.dart';

class IdenticalChecker extends Tool {
  @override
  String name() => "Check Duplicate Files";

  @override
  String description() => "Scan a folder and find identical files by hash.";

  Future<void> checkFiles(String folderPath, List<String> extensions) async {
    final folder = Directory(folderPath);

    if (!folder.existsSync()) {
      print('Folder does not exist: $folderPath');
      return;
    }

    // Step 1: Group files by size
    final Map<int, List<File>> sizeMap = {};

    // Catch errors from restricted folders
    await for (final entity
        in folder.list(recursive: true, followLinks: false).handleError((e) {
      print('Skipping: $e');
    }, test: (e) => e is FileSystemException)) {
      if (entity is File) {
        final ext = entity.path.split('.').last.toLowerCase();
        if (!extensions.contains(ext)) continue; // skip non-image files

        try {
          final size = await entity.length();
          sizeMap.putIfAbsent(size, () => []).add(entity);
        } catch (e) {
          print('Error reading file size ${entity.path}: $e');
        }
      }
    }

    // Step 2: Within each size group, compute hashes
    bool foundDuplicates = false;
    for (final entry in sizeMap.entries) {
      final files = entry.value;
      if (files.length < 2) continue; // no possible duplicates

      final Map<String, List<String>> hashMap = {};

      for (final file in files) {
        try {
          final bytes = await file.readAsBytes();
          final hash = sha256.convert(bytes).toString();
          hashMap.putIfAbsent(hash, () => []).add(file.path);
        } catch (e) {
          print('Error hashing file ${file.path}: $e');
        }
      }

      // Step 3: Print duplicates
      hashMap.forEach((hash, paths) {
        if (paths.length > 1) {
          foundDuplicates = true;
          print('Duplicate images:');
          for (final p in paths) {
            print('   $p');
          }
          print('---------------------');
        }
      });
    }

    if (!foundDuplicates) {
      print('No identical files found.');
    }
  }
}

void main() async {
  var tool = IdenticalChecker();
  // Folder to scan
  const folderPath = r'D:\pics';
  final extensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  tool.checkFiles(folderPath, extensions);
}
