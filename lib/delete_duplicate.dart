import 'dart:io';

/// Deletes resized variants like `name-108x108.ext` for the given extensions,
/// but only when the original `name.ext` exists.
///
/// [extensions] must be lowercase, without dots (e.g. ["jpg","png","webp"])
void removeResizedVariants(
  String dirPath,
  List<String> extensions, {
  bool dryRun = true,
}) {
  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    print('Directory does not exist: $dirPath');
    return;
  }

  final files = dir.listSync().whereType<File>();

  // Normalize extensions
  final allowedExt = extensions.map((e) => e.toLowerCase()).toSet();

  // Regex for resized variants: "<base>-<w>x<h>.<ext>"
  final resizedRegex = RegExp(r'^(.*)-(\d+)x(\d+)\.(\w+)$');

  // Preload filenames
  final existingLower = <String>{};
  for (final f in files) {
    existingLower.add(f.uri.pathSegments.last.toLowerCase());
  }

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final lower = name.toLowerCase();

    final match = resizedRegex.firstMatch(lower);
    if (match == null) continue;

    final basePart = match.group(1)!;
    final ext = match.group(4)!;

    if (!allowedExt.contains(ext)) continue;

    final originalName = '$basePart.$ext';

    if (existingLower.contains(originalName)) {
      if (dryRun) {
        print('[dryRun] Would delete: $name (original exists: $originalName)');
      } else {
        try {
          file.deleteSync();
          print('Deleted: $name');
        } catch (e) {
          print('Error deleting $name: $e');
        }
      }
    } else {
      print('Skipping $name — original missing: $originalName');
    }
  }
}
//dart run delete_duplicate.dart 'D:\pics' --delete
void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run script.dart <directory> [--delete]');
    return;
  }

  final dir = args[0];
  final deleteFlag = args.contains('--delete');

  removeResizedVariants(
    dir,
    ['jpg', 'jpeg', 'png', 'webp'],
    dryRun: !deleteFlag,
  );

  if (!deleteFlag) {
    print('\nRun again with --delete to actually delete files.');
  }
}
