import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Plain-language privacy policy: where data lives, how sync behaves and
/// what isn't protected. Open before signing in too.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LegalPage(
      title: l10n.privacyTitle,
      points: [
        (LucideIcons.cloud, l10n.privacyLocalTitle, l10n.privacyLocalBody),
        (
          LucideIcons.serverOff,
          l10n.privacyNoServerTitle,
          l10n.privacyNoServerBody,
        ),
        (LucideIcons.logIn, l10n.privacyDriveTitle, l10n.privacyDriveBody),
        (LucideIcons.refreshCw, l10n.privacySyncTitle, l10n.privacySyncBody),
        (LucideIcons.clock, l10n.privacyClockTitle, l10n.privacyClockBody),
        (
          LucideIcons.lockOpen,
          l10n.privacyEncryptionTitle,
          l10n.privacyEncryptionBody,
        ),
        (
          LucideIcons.fingerprint,
          l10n.privacyPasswordTitle,
          l10n.privacyPasswordBody,
        ),
        (LucideIcons.fileUp, l10n.privacyFilesTitle, l10n.privacyFilesBody),
        (LucideIcons.logOut, l10n.privacyLeavingTitle, l10n.privacyLeavingBody),
        (LucideIcons.archive, l10n.privacyBackupTitle, l10n.privacyBackupBody),
        (LucideIcons.eyeOff, l10n.privacyScreenTitle, l10n.privacyScreenBody),
        (
          LucideIcons.chartNoAxesColumn,
          l10n.privacyAnalyticsTitle,
          l10n.privacyAnalyticsBody,
        ),
      ],
      footer: l10n.legalUpdated,
    );
  }
}

/// Terms of use, in the same plain style.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LegalPage(
      title: l10n.termsTitle,
      points: [
        (LucideIcons.user, l10n.termsUseTitle, l10n.termsUseBody),
        (LucideIcons.logIn, l10n.termsAccountTitle, l10n.termsAccountBody),
        (LucideIcons.refreshCw, l10n.termsSyncTitle, l10n.termsSyncBody),
        (LucideIcons.hardDrive, l10n.termsStorageTitle, l10n.termsStorageBody),
        (
          LucideIcons.flaskConical,
          l10n.termsTestingTitle,
          l10n.termsTestingBody,
        ),
        (LucideIcons.download, l10n.termsLeavingTitle, l10n.termsLeavingBody),
        (LucideIcons.fileText, l10n.termsChangesTitle, l10n.termsChangesBody),
      ],
      footer: l10n.legalUpdated,
    );
  }
}

class LegalPage extends StatelessWidget {
  const LegalPage({
    required this.title,
    required this.points,
    this.footer,
    super.key,
  });

  final String title;
  final List<(IconData, String, String)> points;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          8,
          AppSpacing.gutter,
          32,
        ),
        itemCount: points.length + (footer == null ? 0 : 1),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.gap),
        itemBuilder: (context, i) {
          if (i == points.length) {
            return Text(footer!, style: theme.textTheme.bodySmall);
          }
          final (icon, heading, body) = points[i];
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
                        Text(heading, style: theme.textTheme.titleSmall),
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
