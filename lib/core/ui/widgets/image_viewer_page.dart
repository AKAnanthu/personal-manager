import 'dart:io';

import 'package:flutter/material.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';

/// Full-screen, zoomable preview of a locally stored image.
class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({required this.file, required this.title, super.key});

  final File file;
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const AppBackButton(), title: Text(title)),
    body: InteractiveViewer(
      maxScale: 5,
      child: Center(
        child: Image.file(
          file,
          semanticLabel: title,
          errorBuilder: (context, _, _) =>
              const Icon(Icons.broken_image_outlined),
        ),
      ),
    ),
  );
}
