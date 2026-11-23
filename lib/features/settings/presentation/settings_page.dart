import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/app/modules.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/account/presentation/sign_in_page.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';
import 'package:personal_life_manager/features/settings/presentation/settings_cubits.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

abstract final class SettingsRoutes {
  static const root = '/settings';
  static const account = '/settings/account';
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.appVersion,
    required this.driveAccount,
    super.key,
  });

  final String appVersion;

  /// The signed-in Google account.
  final ValueListenable<String?> driveAccount;

  Future<T?> _choose<T>(
    BuildContext context, {
    required String title,
    required List<(T, String)> options,
    required T current,
  }) => showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: RadioGroup<T>(
        groupValue: current,
        onChanged: (v) => Navigator.of(context).pop(v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final (value, label) in options)
              RadioListTile<T>(value: value, title: Text(label)),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SettingsCubit>();
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, s) {
        final last = s.lastBackup;
        String autoLockLabel(AutoLock a) => l10n.autoLockOption(a.name);
        String themeLabel(ThemeMode m) => l10n.themeOption(m.name);
        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(),
            title: Text(l10n.moduleName('settings')),
          ),
          body: s.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    4,
                    AppSpacing.gutter,
                    32,
                  ),
                  children: [
                    SectionLabel(l10n.settingsSecurity),
                    GroupCard(
                      children: [
                        ListTile(
                          leading: const Icon(LucideIcons.timer),
                          title: Text(l10n.autoLockTitle),
                          subtitle: Text(autoLockLabel(s.autoLock)),
                          onTap: () async {
                            final v = await _choose(
                              context,
                              title: l10n.autoLockTitle,
                              current: s.autoLock,
                              options: [
                                for (final a in AutoLock.values)
                                  (a, autoLockLabel(a)),
                              ],
                            );
                            if (v != null) await cubit.setAutoLock(v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l10n.settingsStorage),
                    GroupCard(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: driveAccount,
                          builder: (context, account, _) => ListTile(
                            leading: const Icon(LucideIcons.refreshCw),
                            title: Text(l10n.accountTitle),
                            subtitle: Text(account ?? ''),
                            trailing: const Icon(LucideIcons.chevronRight),
                            onTap: () => context.push(SettingsRoutes.account),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(LucideIcons.cloud),
                          title: Text(l10n.driveFilesTitle),
                          subtitle: Text(l10n.driveFilesSubtitle),
                          trailing: const Icon(LucideIcons.chevronRight),
                          onTap: () => context.push(AppModule.drive.route),
                        ),
                        ListTile(
                          leading: const Icon(LucideIcons.databaseBackup),
                          title: Text(l10n.moduleName('backup')),
                          subtitle: Text(
                            last == null
                                ? l10n.backupNever
                                : l10n.settingsLastBackup(
                                    AppFormats.of(context).shortDate(last.at),
                                  ),
                          ),
                          trailing: const Icon(LucideIcons.chevronRight),
                          onTap: () async {
                            await context.push(AppModule.backup.route);
                            if (context.mounted) unawaited(cubit.load());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l10n.settingsPreferences),
                    GroupCard(
                      children: [
                        ListTile(
                          leading: const Icon(LucideIcons.bell),
                          title: Text(l10n.settingsNotifications),
                          subtitle: Text(
                            !s.notificationsAllowed
                                ? l10n.notificationsStatusOff
                                : s.exactAlarms
                                ? l10n.notificationsStatusOn
                                : l10n.notificationsStatusInexact,
                          ),
                          trailing: const Icon(LucideIcons.externalLink),
                          onTap: !s.notificationsAllowed || s.exactAlarms
                              ? cubit.openNotificationSettings
                              : cubit.allowExactAlarms,
                        ),
                        ListTile(
                          leading: const Icon(LucideIcons.sunMoon),
                          title: Text(l10n.themeTitle),
                          subtitle: Text(themeLabel(s.themeMode)),
                          onTap: () async {
                            final v = await _choose(
                              context,
                              title: l10n.themeTitle,
                              current: s.themeMode,
                              options: [
                                for (final m in ThemeMode.values)
                                  (m, themeLabel(m)),
                              ],
                            );
                            if (v != null) await cubit.setTheme(v);
                          },
                        ),
                        ListTile(
                          leading: const Icon(LucideIcons.wallet),
                          title: Text(l10n.budgetPeriodTitle),
                          subtitle: Text(l10n.budgetPeriodCalendarMonth),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l10n.settingsAbout),
                    GroupCard(
                      children: [
                        ListTile(
                          leading: const Icon(LucideIcons.shieldCheck),
                          title: Text(l10n.privacyTitle),
                          trailing: const Icon(LucideIcons.chevronRight),
                          onTap: () => context.push(LegalRoutes.privacy),
                        ),
                        ListTile(
                          leading: const Icon(LucideIcons.fileText),
                          title: Text(l10n.termsTitle),
                          trailing: const Icon(LucideIcons.chevronRight),
                          onTap: () => context.push(LegalRoutes.terms),
                        ),
                        ListTile(
                          leading: const Icon(LucideIcons.info),
                          title: Text(l10n.appInfoTitle),
                          subtitle: Text(l10n.appVersion(appVersion)),
                          onTap: () => showLicensePage(
                            context: context,
                            applicationName: l10n.appTitle,
                            applicationVersion: appVersion,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
}
