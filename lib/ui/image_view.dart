import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class ImageView extends StatelessWidget {
  final String filePath;
  final double width;
  final double height;
  final BoxFit fit;

  const ImageView({
    super.key,
    required this.filePath,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final extension = path.extension(filePath).toLowerCase();

    if (extension == '.webp') {
      return _loadWebP(filePath);
    }

    return Image.file(
      File(filePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.broken_image,
          size: 30,
        );
      },
    );
  }

  Widget _loadWebP(String filePath) {
    return Image.file(
      File(filePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.broken_image,
          size: 30,
        );
      },
    );
  }
}
