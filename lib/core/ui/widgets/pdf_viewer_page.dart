import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';

/// Full-screen in-app preview of a locally stored PDF (rendered on the
/// device; nothing leaves it).
class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({required this.file, required this.title, super.key});

  final File file;
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const AppBackButton(), title: Text(title)),
    body: PdfViewer.file(file.path),
  );
}
