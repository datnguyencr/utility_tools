import 'dart:io';
// Example:
// dart run convert_to_avif.dart "D:\pics" "D:\pics_avif" --convert
// dart run avif_converter.dart "D:\work\projects\web\cv-builder-web\templates" "D:\work\projects\web\cv-builder-web\templates_avif" --convert

void main(List<String> args) {
  if (args.length < 2) {
    print('Usage: dart run script.dart <inputDir> <outputDir> [--convert]');
    return;
  }

  final inputDir = args[0];
  final outputDir = args[1];
  final doConvert = args.contains('--convert');

  convertImagesToAvif(
    inputDir,
    outputDir,
    quality: 50,
    dryRun: !doConvert,
  );

  if (!doConvert) {
    print('\nDry run only. Re-run with --convert to execute.');
  }
}

/// Converts all images in [inputDir] to AVIF using ImageMagick.
/// Output files are written to [outputDir].
///
/// Requires ImageMagick (`magick`) to be available in PATH.
void convertImagesToAvif(
    String inputDir,
    String outputDir, {
      int quality = 60,
      bool dryRun = true,
    }) {
  final inDir = Directory(inputDir);
  if (!inDir.existsSync()) {
    print('Input directory does not exist: $inputDir');
    return;
  }

  final outDir = Directory(outputDir);
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  const allowedExt = {'jpg', 'jpeg', 'png', 'webp'};

  final files = inDir.listSync().whereType<File>();

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final lower = name.toLowerCase();

    final dot = lower.lastIndexOf('.');
    if (dot == -1) continue;

    final ext = lower.substring(dot + 1);
    if (!allowedExt.contains(ext)) continue;

    final base = name.substring(0, dot);
    final outputPath = '${outDir.path}${Platform.pathSeparator}$base.avif';

    final cmd = [
      'magick',
      file.path,
      '-quality',
      quality.toString(),
      outputPath,
    ];

    if (dryRun) {
      print('[dryRun] ${cmd.join(' ')}');
      continue;
    }

    try {
      final result = Process.runSync(
        cmd.first,
        cmd.sublist(1),
        runInShell: true,
      );

      if (result.exitCode == 0) {
        print('Converted: $name → $base.avif');
      } else {
        print('Failed: $name');
        print(result.stderr);
      }
    } catch (e) {
      print('Error converting $name: $e');
    }
  }
}
