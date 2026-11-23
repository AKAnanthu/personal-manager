import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/app/modules.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/sync/sync_engine.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/button_progress.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/account/presentation/account_cubit.dart';
import 'package:personal_life_manager/features/settings/presentation/erase_dialog.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// "Account & sync": the Google account, "Sync now", Drive storage, and
/// signing out or leaving (with the option to keep a copy first).
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static String statusText(
    AppLocalizations l10n,
    AppFormats formats,
    SyncStatus s,
  ) => switch (s) {
    SyncStatus(activity: SyncActivity.syncing, :final total, :final done)
        when total > 0 =>
      l10n.syncProgress(done, total),
    SyncStatus(activity: SyncActivity.syncing) => l10n.syncRunning,
    SyncStatus(activity: SyncActivity.saving) => l10n.syncSaving,
    SyncStatus(:final pending) when pending > 0 => l10n.syncPending(pending),
    SyncStatus(:final lastSyncedAt?) => l10n.syncAllSavedLast(
      '${formats.shortDate(lastSyncedAt)} ${formats.time(lastSyncedAt)}',
    ),
    _ => l10n.syncAllSaved,
  };

  Future<void> _signOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AccountCubit>();
    final go = await confirmDialog(
      context,
      title: l10n.signOutTitle,
      message: l10n.signOutBody,
      confirmLabel: l10n.signOutAction,
    );
    if (!go || !context.mounted) return;
    final unsaved = await cubit.signOut();
    if (unsaved == null || !context.mounted) return;
    final anyway = await confirmDialog(
      context,
      title: l10n.signOutUnsavedTitle,
      message: l10n.signOutUnsavedBody(unsaved.count),
      confirmLabel: l10n.signOutAnywayAction,
    );
    if (anyway) await cubit.signOut(force: true);
  }

  Future<void> _deleteAll(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AccountCubit>();
    if (!await confirmErase(context)) return;
    final r = await cubit.deleteEverything();
    if (r case Err(:final failure) when context.mounted) {
      showSnack(context, l10n.deleteAllFailed(failure.message(l10n)));
    }
  }

  Future<void> _sync(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final r = await context.read<AccountCubit>().syncNow();
    if (!context.mounted) return;
    showSnack(context, syncResultText(l10n, r));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formats = AppFormats.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<AccountCubit>();
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, s) {
        final syncing = s.sync.activity == SyncActivity.syncing;
        final quota = s.quota;
        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(),
            title: Text(l10n.accountTitle),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              4,
              AppSpacing.gutter,
              32,
            ),
            children: [
              GroupCard(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        (s.account ?? '?').substring(0, 1).toUpperCase(),
                      ),
                    ),
                    title: Text(s.account ?? ''),
                    subtitle: Text(l10n.signedInWithGoogle),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              SectionLabel(l10n.syncSection),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      Text(
                        statusText(l10n, formats, s.sync),
                        style: theme.textTheme.titleSmall,
                      ),
                      if (s.sync.failure case final f?)
                        NoticeBanner(
                          message: l10n.syncFailed(f.message(l10n)),
                          tone: NoticeTone.warning,
                        ),
                      FilledButton.icon(
                        onPressed: syncing ? null : () => _sync(context),
                        icon: syncing
                            ? const ButtonProgress()
                            : const Icon(LucideIcons.refreshCw),
                        label: Text(l10n.syncNowAction),
                      ),
                      Text(
                        l10n.syncHowItWorks,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              if (!s.clockAutomatic) ...[
                const SizedBox(height: AppSpacing.gap),
                NoticeBanner(
                  message: l10n.clockNotAutomatic,
                  tone: NoticeTone.warning,
                ),
                TextButton(
                  onPressed: cubit.openDateSettings,
                  child: Text(l10n.openDateSettingsAction),
                ),
              ],
              const SizedBox(height: AppSpacing.section),
              SectionLabel(l10n.driveStorageSection),
              GroupCard(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.hardDrive),
                    title: Text(l10n.appDataInDrive),
                    subtitle: Text(
                      s.appBytes == null
                          ? (s.storageFailed
                                ? (s.storageFailure?.message(l10n) ??
                                      l10n.storageUnavailable)
                                : l10n.loadingLabel)
                          : l10n.appDataSummary(
                              formats.fileSize(s.appBytes!),
                              s.records,
                              s.files,
                            ),
                    ),
                    trailing: IconButton(
                      tooltip: l10n.refreshAction,
                      icon: const Icon(LucideIcons.rotateCw),
                      onPressed: cubit.loadStorage,
                    ),
                  ),
                  if (quota != null)
                    ListTile(
                      leading: const Icon(LucideIcons.cloud),
                      title: Text(l10n.googleStorage),
                      subtitle: Text(
                        quota.limitBytes == null
                            ? l10n.googleStorageUsed(
                                formats.fileSize(quota.usedBytes),
                              )
                            : l10n.googleStorageUsedOf(
                                formats.fileSize(quota.usedBytes),
                                formats.fileSize(quota.limitBytes!),
                              ),
                      ),
                    ),
                  ListTile(
                    leading: const Icon(LucideIcons.fileUp),
                    title: Text(l10n.fileLimitTitle),
                    subtitle: Text(
                      l10n.fileLimitBody(
                        formats.fileSize(FileTypeValidator.maxBytes),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              SectionLabel(l10n.leavingSection),
              GroupCard(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.download),
                    title: Text(l10n.saveCopyToPhone),
                    subtitle: Text(l10n.saveCopyToPhoneBody),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: s.busy
                        ? null
                        : () => context.push(AppModule.backup.route),
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.logOut),
                    title: Text(l10n.signOutAction),
                    subtitle: Text(l10n.signOutSubtitle),
                    onTap: s.busy ? null : () => unawaited(_signOut(context)),
                  ),
                  ListTile(
                    leading: Icon(
                      LucideIcons.trash2,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(
                      l10n.eraseTitle,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    subtitle: Text(l10n.deleteAllSubtitle),
                    onTap: s.busy ? null : () => unawaited(_deleteAll(context)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gap),
              Text(l10n.uninstallNote, style: theme.textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}

/// Snack text after "Sync now".
String syncResultText(AppLocalizations l10n, Result<SyncReport> r) =>
    switch (r) {
      Ok(value: SyncReport(received: 0, removed: 0)) => l10n.syncUpToDate,
      Ok(value: SyncReport(:final received, :final removed)) => l10n.syncDone(
        received,
        removed,
      ),
      Err(:final failure) => l10n.syncFailed(failure.message(l10n)),
    };
