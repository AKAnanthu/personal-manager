import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/backup_restore/domain/backup.dart';
import 'package:personal_life_manager/features/backup_restore/presentation/backup_cubits.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _restoreTab = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.moduleName('backup')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          4,
          AppSpacing.gutter,
          32,
        ),
        children: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: false, label: Text(l10n.backupTab)),
              ButtonSegment(value: true, label: Text(l10n.restoreTab)),
            ],
            selected: {_restoreTab},
            onSelectionChanged: (v) => setState(() => _restoreTab = v.first),
          ),
          const SizedBox(height: AppSpacing.section),
          if (_restoreTab) const _RestoreTab() else const _BackupTab(),
        ],
      ),
    );
  }
}

String _size(BuildContext context, int bytes) =>
    AppFormats.of(context).fileSize(bytes);

String _categoryName(AppLocalizations l10n, BackupCategory c) =>
    l10n.backupCategory(c.name);

// ---- Back up ---------------------------------------------------------------

class _BackupTab extends StatelessWidget {
  const _BackupTab();

  Future<void> _confirm(BuildContext context, BackupState s) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<BackupCubit>();
    final e = s.estimate;
    if (e == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupSummaryTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              for (final c in BackupCategory.values)
                if (e.counts[c] case final n?)
                  Row(
                    children: [
                      Expanded(child: Text(_categoryName(l10n, c))),
                      if (c != BackupCategory.preferences)
                        Text(l10n.backupRecordCount(n)),
                    ],
                  ),
              const Divider(),
              Text(l10n.backupEstimatedSize(_size(context, e.bytes))),
              const SizedBox(height: 6),
              NoticeBanner(
                tone: NoticeTone.warning,
                message: s.includesSensitive
                    ? l10n.backupSensitiveWarning
                    : l10n.backupUnencryptedWarning,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.backupCreateAction),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await cubit.build();
    } else {
      await cubit.cancel();
    }
  }

  Future<void> _deliver(BuildContext context, BackupState s) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<BackupCubit>();
    final d = await showModalBottomSheet<BackupDestination>(
      context: context,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                l10n.backupReady(_size(context, s.size ?? 0)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.hardDriveDownload),
              title: Text(l10n.backupSaveToDevice),
              onTap: () => Navigator.of(context).pop(BackupDestination.device),
            ),
            ListTile(
              leading: const Icon(LucideIcons.share2),
              title: Text(l10n.backupShare),
              subtitle: Text(l10n.backupShareHint),
              onTap: () => Navigator.of(context).pop(BackupDestination.share),
            ),
            ListTile(
              leading: const Icon(LucideIcons.x),
              title: Text(l10n.cancelAction),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
    if (d == null) {
      await cubit.cancel();
    } else {
      await cubit.deliver(d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<BackupCubit>();
    return BlocConsumer<BackupCubit, BackupState>(
      listenWhen: (a, b) => a.phase != b.phase || (b.error && !a.error),
      listener: (context, s) {
        if (s.error) showSnack(context, l10n.backupFailed);
        switch (s.phase) {
          case BackupPhase.confirming:
            unawaited(_confirm(context, s));
          case BackupPhase.built:
            unawaited(_deliver(context, s));
          case BackupPhase.done:
            final last = s.lastBackup;
            if (last != null) {
              showSnack(context, l10n.backupSaved(_size(context, last.size)));
            }
            unawaited(cubit.cancel()); // back to idle
          case BackupPhase.idle ||
              BackupPhase.estimating ||
              BackupPhase.building:
            break;
        }
      },
      builder: (context, s) {
        final last = s.lastBackup;
        final locked = s.phase != BackupPhase.idle;
        Widget box(BackupCategory c) => CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: s.selected.contains(c),
          onChanged: locked ? null : (_) => cubit.toggle(c),
          title: Row(
            spacing: 8,
            children: [
              Flexible(child: Text(_categoryName(l10n, c))),
              if (c.sensitive)
                _Tag(text: l10n.sensitiveTag, colors: context.palette.reminder),
            ],
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              last == null
                  ? l10n.backupNever
                  : l10n.backupLast(
                      AppFormats.of(context).fullDate(last.at),
                      _size(context, last.size),
                    ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.section),
            SectionLabel(l10n.backupIncludedByDefault),
            for (final c in BackupCategory.values)
              if (c.defaultSelected) box(c),
            const SizedBox(height: 8),
            SectionLabel(l10n.backupOptional),
            for (final c in BackupCategory.values)
              if (!c.defaultSelected) box(c),
            const SizedBox(height: AppSpacing.section),
            SectionLabel(l10n.backupSaveTo),
            RadioGroup<bool>(
              groupValue: false,
              onChanged: (_) {},
              child: Column(
                children: [
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    enabled: false,
                    title: Text(l10n.googleDrive),
                    subtitle: Text(l10n.backupDriveLater),
                  ),
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    value: false,
                    title: Text(l10n.backupThisDevice),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            NoticeBanner(
              tone: NoticeTone.warning,
              message: s.includesSensitive
                  ? l10n.backupSensitiveWarning
                  : l10n.backupUnencryptedWarning,
            ),
            const SizedBox(height: 16),
            if (s.busy)
              _Working(
                text: s.phase == BackupPhase.estimating
                    ? l10n.backupChecking
                    : l10n.backupPreparing,
                onCancel: cubit.cancel,
              )
            else
              FilledButton(
                onPressed: s.selected.isEmpty || locked ? null : cubit.prepare,
                child: Text(l10n.backupCreateCount(s.selected.length)),
              ),
          ],
        );
      },
    );
  }
}

// ---- Restore ---------------------------------------------------------------

class _RestoreTab extends StatelessWidget {
  const _RestoreTab();

  Future<void> _confirm(BuildContext context, RestoreState s) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<RestoreCubit>();
    final names = [
      for (final c in BackupCategory.values)
        if (s.selected.contains(c)) _categoryName(l10n, c),
    ].join(', ');
    final replace = s.strategy == RestoreStrategy.replace;
    final ok = await confirmDialog(
      context,
      title: replace ? l10n.restoreReplaceTitle : l10n.restoreMergeTitle,
      message: replace
          ? l10n.restoreReplaceBody(names)
          : l10n.restoreMergeBody(names),
      confirmLabel: replace ? l10n.restoreReplaceAction : l10n.restoreAction,
      destructive: replace,
    );
    if (ok) await cubit.restore();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<RestoreCubit>();
    return BlocConsumer<RestoreCubit, RestoreState>(
      listenWhen: (a, b) =>
          (b.problem != null && a.problem != b.problem) ||
          (b.error && !a.error),
      listener: (context, s) {
        if (s.problem case final p?) {
          unawaited(
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.restoreCannotUse),
                content: Text(l10n.backupProblem(p.name)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.closeAction),
                  ),
                ],
              ),
            ),
          );
        } else if (s.error) {
          showSnack(context, l10n.restoreFailed);
        }
      },
      builder: (context, s) {
        switch (s.phase) {
          case RestorePhase.idle:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                Text(l10n.restoreIntro, style: theme.textTheme.bodyMedium),
                FilledButton.icon(
                  onPressed: cubit.pick,
                  icon: const Icon(LucideIcons.folderOpen),
                  label: Text(l10n.restoreChooseFile),
                ),
                NoticeBanner(message: l10n.restoreDriveLater),
              ],
            );
          case RestorePhase.checking:
            return _Working(text: l10n.restoreChecking, onCancel: cubit.cancel);
          case RestorePhase.restoring:
            return _Working(text: l10n.restoreRestoring);
          case RestorePhase.done:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                NoticeBanner(message: l10n.restoreDone),
                GroupCard(
                  children: [
                    for (final e in s.restored.entries)
                      ListTile(
                        title: Text(_categoryName(l10n, e.key)),
                        trailing: e.key == BackupCategory.preferences
                            ? null
                            : Text(l10n.backupRecordCount(e.value)),
                      ),
                  ],
                ),
                OutlinedButton(
                  onPressed: cubit.cancel,
                  child: Text(l10n.doneAction),
                ),
              ],
            );
          case RestorePhase.preview:
            final preview = s.preview;
            if (preview == null) return const SizedBox.shrink();
            return _Preview(
              state: s,
              preview: preview,
              onRestore: () => _confirm(context, s),
            );
        }
      },
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.state,
    required this.preview,
    required this.onRestore,
  });

  final RestoreState state;
  final BackupPreview preview;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<RestoreCubit>();
    final m = preview.manifest;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final created = DateFormat.yMMMd(locale)
        .add_jm()
        .format(m.createdAt.toLocal());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            leading: const Icon(LucideIcons.archive),
            title: Text(l10n.restoreBackupFrom(created)),
            subtitle: Text(_size(context, preview.fileSize)),
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        SectionLabel(l10n.restoreChooseCategories),
        for (final c in m.categories)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: state.selected.contains(c),
            onChanged: (_) => cubit.toggle(c),
            title: Text(_categoryName(l10n, c)),
            secondary: c == BackupCategory.preferences
                ? null
                : Text(
                    l10n.backupRecordCount(m.counts[c] ?? 0),
                    style: theme.textTheme.bodySmall,
                  ),
          ),
        const SizedBox(height: AppSpacing.section),
        SectionLabel(l10n.restoreHow),
        SegmentedButton<RestoreStrategy>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: RestoreStrategy.merge,
              label: Text(l10n.restoreMerge),
            ),
            ButtonSegment(
              value: RestoreStrategy.replace,
              label: Text(l10n.restoreReplace),
            ),
          ],
          selected: {state.strategy},
          onSelectionChanged: (v) => cubit.strategyChanged(v.first),
        ),
        const SizedBox(height: 8),
        Text(
          state.strategy == RestoreStrategy.merge
              ? l10n.restoreMergeHelp
              : l10n.restoreReplaceHelp,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: state.selected.isEmpty ? null : onRestore,
          child: Text(l10n.restoreCount(state.selected.length)),
        ),
        TextButton(onPressed: cubit.cancel, child: Text(l10n.cancelAction)),
      ],
    );
  }
}

class _Working extends StatelessWidget {
  const _Working({required this.text, this.onCancel});

  final String text;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cancel = onCancel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(text, style: Theme.of(context).textTheme.titleSmall),
            const LinearProgressIndicator(),
            if (cancel != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: cancel,
                  child: Text(l10n.cancelAction),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.colors});

  final String text;
  final AccentPair colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: colors.foreground, fontWeight: FontWeight.w700),
    ),
  );
}
