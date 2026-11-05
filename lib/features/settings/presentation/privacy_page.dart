import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Plain-language explanation of where data lives and what isn't
/// protected (PRD §19).
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final points = [
      (LucideIcons.smartphone, l10n.privacyLocalTitle, l10n.privacyLocalBody),
      (
        LucideIcons.serverOff,
        l10n.privacyNoServerTitle,
        l10n.privacyNoServerBody,
      ),
      (LucideIcons.cloud, l10n.privacyDriveTitle, l10n.privacyDriveBody),
      (
        LucideIcons.lockOpen,
        l10n.privacyEncryptionTitle,
        l10n.privacyEncryptionBody,
      ),
      (LucideIcons.lock, l10n.privacyPasswordTitle, l10n.privacyPasswordBody),
      (LucideIcons.archive, l10n.privacyBackupTitle, l10n.privacyBackupBody),
      (LucideIcons.eyeOff, l10n.privacyScreenTitle, l10n.privacyScreenBody),
      (
        LucideIcons.chartNoAxesColumn,
        l10n.privacyAnalyticsTitle,
        l10n.privacyAnalyticsBody,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.privacyTitle),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          8,
          AppSpacing.gutter,
          32,
        ),
        itemCount: points.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.gap),
        itemBuilder: (context, i) {
          final (icon, title, body) = points[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  IconTile(icon: icon, colors: palette.task),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(title, style: theme.textTheme.titleSmall),
                        Text(body, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
