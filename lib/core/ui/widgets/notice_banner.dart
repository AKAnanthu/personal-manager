import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';

enum NoticeTone { info, warning }

/// Inline info/warning banner (e.g. the unencrypted-data warnings).
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    required this.message,
    this.tone = NoticeTone.info,
    super.key,
  });

  final String message;
  final NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final (bg, iconColor, textColor, icon) = switch (tone) {
      NoticeTone.info => (
        palette.infoBanner,
        scheme.primary,
        palette.formLabel,
        LucideIcons.info,
      ),
      NoticeTone.warning => (
        palette.reminder.background,
        palette.reminder.foreground,
        palette.warningText,
        LucideIcons.triangleAlert,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Icon(icon, size: 20, color: iconColor),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: textColor, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
