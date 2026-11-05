import 'package:flutter/material.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';

/// Tall "PDF" / "JPG" / "XLSX" tile, coloured by file type.
class FileTypeBadge extends StatelessWidget {
  const FileTypeBadge(this.type, {super.key, this.width = 44});

  final SupportedFileType type;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final colors = switch (type) {
      SupportedFileType.pdf => p.pdfFile,
      SupportedFileType.jpeg || SupportedFileType.png => p.imageFile,
      SupportedFileType.xls || SupportedFileType.xlsx => p.sheetFile,
      SupportedFileType.doc || SupportedFileType.docx => p.task,
    };
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: width * 1.18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          type == SupportedFileType.jpeg ? 'JPG' : type.label,
          maxLines: 1,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: colors.foreground, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
