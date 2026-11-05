import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// File types the app accepts (PRD §7.1).
enum SupportedFileType {
  pdf('application/pdf', ['.pdf']),
  jpeg('image/jpeg', ['.jpg', '.jpeg']),
  png('image/png', ['.png']),
  doc('application/msword', ['.doc']),
  docx(
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    ['.docx'],
  ),
  xls('application/vnd.ms-excel', ['.xls']),
  xlsx('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', [
    '.xlsx',
  ]);

  SupportedFileType(this.mimeType, this.extensions);

  final String mimeType;
  final List<String> extensions;

  bool get isImage => this == jpeg || this == png;

  /// Previewed inside the app; the rest open in an external app.
  bool get hasInAppPreview => isImage || this == pdf;

  String get label => name.toUpperCase();
}

sealed class FileCheck {
  const FileCheck();
}

final class FileAccepted extends FileCheck {
  const FileAccepted(this.type, this.sizeBytes);

  final SupportedFileType type;
  final int sizeBytes;
}

final class FileUnsupported extends FileCheck {
  const FileUnsupported();
}

final class FileTooLarge extends FileCheck {
  const FileTooLarge(this.maxBytes);

  final int maxBytes;
}

/// Validates by extension **and** content signature, so a renamed file
/// can't slip through.
abstract final class FileTypeValidator {
  static const int maxBytes = 25 * 1024 * 1024;

  static Future<FileCheck> check(File file, {String? originalName}) async {
    final ext = p.extension(originalName ?? file.path).toLowerCase();
    final byExt = SupportedFileType.values
        .where((t) => t.extensions.contains(ext))
        .firstOrNull;
    if (byExt == null) return const FileUnsupported();

    final size = await file.length();
    if (size > maxBytes) return const FileTooLarge(maxBytes);

    final raf = await file.open();
    final Uint8List head;
    try {
      head = await raf.read(8);
    } finally {
      await raf.close();
    }
    return matchesSignature(byExt, head)
        ? FileAccepted(byExt, size)
        : const FileUnsupported();
  }

  static bool matchesSignature(SupportedFileType type, List<int> head) {
    bool starts(List<int> sig) =>
        head.length >= sig.length &&
        Iterable<int>.generate(sig.length).every((i) => head[i] == sig[i]);
    return switch (type) {
      SupportedFileType.pdf => starts(const [0x25, 0x50, 0x44, 0x46]),
      SupportedFileType.jpeg => starts(const [0xFF, 0xD8, 0xFF]),
      SupportedFileType.png => starts(const [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
      ]),
      // Legacy Office: OLE2 compound file.
      SupportedFileType.doc || SupportedFileType.xls => starts(const [
        0xD0,
        0xCF,
        0x11,
        0xE0,
        0xA1,
        0xB1,
        0x1A,
        0xE1,
      ]),
      // OOXML: ZIP container.
      SupportedFileType.docx ||
      SupportedFileType.xlsx => starts(const [0x50, 0x4B, 0x03, 0x04]),
    };
  }
}
