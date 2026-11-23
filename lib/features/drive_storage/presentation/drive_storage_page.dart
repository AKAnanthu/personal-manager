import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/drive/drive_models.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/security/secure_screen.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/file_badge.dart';
import 'package:personal_life_manager/core/ui/widgets/image_viewer_page.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/ui/widgets/pdf_viewer_page.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/drive_storage/presentation/drive_browser_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Drive Storage (design: Drive.dc.html): the connection, then the app's
/// own folder: subfolders, files, uploads in progress.
class DriveStoragePage extends StatelessWidget {
  const DriveStoragePage({
    required this.pickers,
    required this.opener,
    required this.saver,
    super.key,
  });

  final FilePickers pickers;
  final FileOpener opener;
  final FileSaver saver;

  Future<void> _upload(BuildContext context) async {
    final cubit = context.read<DriveBrowserCubit>();
    final picked = await pickers.chooseDocument();
    if (picked == null) return;
    await cubit.upload(picked.file, picked.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DriveBrowserCubit>();
    return BlocConsumer<DriveBrowserCubit, DriveBrowserState>(
      listenWhen: (a, b) =>
          (b.failure != null && a.failure != b.failure) ||
          (b.notice != null && a.notice != b.notice),
      listener: (context, s) {
        if (s.failure case final f?) showSnack(context, f.message(l10n));
        if (s.notice case final n?) {
          showSnack(context, l10n.driveNotice(n.name));
        }
      },
      builder: (context, s) {
        final connected = s.account != null;
        final canUpload =
            connected && s.status == LoadStatus.ready && s.current != null;
        return PopScope(
          // System back walks up the folder path first.
          canPop: s.crumbs.length <= 1,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) cubit.up();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: const AppBackButton(),
              title: Text(l10n.moduleName('drive')),
              actions: [
                if (connected)
                  IconButton(
                    tooltip: l10n.refreshAction,
                    icon: const Icon(LucideIcons.refreshCw),
                    onPressed: s.status == LoadStatus.loading
                        ? null
                        : cubit.refresh,
                  ),
              ],
            ),
            floatingActionButton: canUpload
                ? FloatingActionButton.extended(
                    onPressed: () => _upload(context),
                    icon: const Icon(LucideIcons.upload),
                    label: Text(l10n.driveUploadAction),
                  )
                : null,
            body: RefreshIndicator(
              onRefresh: connected ? cubit.refresh : () async {},
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  4,
                  AppSpacing.gutter,
                  96,
                ),
                children: connected
                    ? _connected(context, s)
                    : [_NotConnected(state: s)],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _connected(BuildContext context, DriveBrowserState s) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<DriveBrowserCubit>();
    final current = s.current;
    return [
      _AccountCard(account: s.account ?? ''),
      const SizedBox(height: 14),
      if (s.crumbs.isNotEmpty) ...[
        _Breadcrumbs(crumbs: s.crumbs, onTap: cubit.openCrumb),
        const SizedBox(height: 14),
      ],
      if (s.status == LoadStatus.loading)
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (s.status == LoadStatus.failure)
        _Problem(problem: s.problem ?? DriveProblem.unknown)
      else ...[
        if (s.folders.isNotEmpty) ...[
          _FolderGrid(
            folders: s.folders,
            counts: s.counts,
            onOpen: cubit.openFolder,
          ),
          const SizedBox(height: AppSpacing.section),
        ],
        if (s.crumbs.length > 1 || s.files.isNotEmpty)
          SectionLabel(l10n.driveFilesIn(current?.name ?? '')),
        if (s.files.isEmpty && s.uploadsHere.isEmpty && s.crumbs.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.driveFolderEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (s.files.isNotEmpty || s.uploadsHere.isNotEmpty)
          GroupCard(
            children: [
              for (final f in s.files)
                _FileRow(
                  item: f,
                  busy: s.busyItemId == f.id,
                  onOpen: () => _open(context, f),
                  onSave: () => _save(context, f),
                  onDelete: () => _delete(context, f),
                ),
              for (final u in s.uploadsHere) _UploadRow(upload: u),
            ],
          ),
        if (s.nextPageToken != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: s.loadingMore
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton(
                    onPressed: cubit.loadMore,
                    child: Text(l10n.loadMoreAction),
                  ),
          ),
      ],
      const SizedBox(height: 14),
      Text(
        l10n.driveFooter,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ];
  }

  Future<void> _open(BuildContext context, DriveItem item) async {
    final cubit = context.read<DriveBrowserCubit>();
    final file = await cubit.fetch(item);
    if (file == null || !context.mounted) return;
    final type = SupportedFileType.fromName(item.name);
    if (type != null && type.hasInAppPreview) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SecureScreen(
            child: type.isImage
                ? ImageViewerPage(file: file, title: item.name)
                : PdfViewerPage(file: file, title: item.name),
          ),
        ),
      );
    } else if (!await opener.openExternally(file) && context.mounted) {
      showSnack(context, AppLocalizations.of(context).errorNoAppToOpen);
    }
  }

  Future<void> _save(BuildContext context, DriveItem item) async {
    final cubit = context.read<DriveBrowserCubit>();
    final file = await cubit.fetch(item);
    if (file == null) return;
    if (await saver.saveCopy(file, name: item.name)) cubit.saved();
  }

  Future<void> _delete(BuildContext context, DriveItem item) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DriveBrowserCubit>();
    final ok = await confirmDialog(
      context,
      title: l10n.driveDeleteTitle(item.name),
      message: l10n.driveDeleteBody,
      confirmLabel: l10n.driveDeleteAction,
    );
    if (ok) await cubit.delete(item);
  }
}

class _NotConnected extends StatelessWidget {
  const _NotConnected({required this.state});

  final DriveBrowserState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final cubit = context.read<DriveBrowserCubit>();
    Widget point(IconData icon, String text) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    CircleAvatar(
                      backgroundColor: palette.task.background,
                      foregroundColor: palette.task.foreground,
                      child: const Icon(LucideIcons.cloudOff, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        l10n.driveNotConnected,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                point(LucideIcons.folderLock, l10n.driveWhyOnlyAppFolder),
                point(LucideIcons.hand, l10n.driveWhyManual),
                point(LucideIcons.smartphone, l10n.driveWhyOptional),
                FilledButton.icon(
                  onPressed: state.connecting ? null : cubit.connect,
                  icon: state.connecting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.cloud),
                  label: Text(l10n.driveConnectAction),
                ),
              ],
            ),
          ),
        ),
        NoticeBanner(message: l10n.driveNotEncrypted, tone: NoticeTone.warning),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final String account;

  Future<void> _manage(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DriveBrowserCubit>();
    final disconnect = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.circleUser),
              title: Text(account),
              subtitle: Text(l10n.driveConnectedAs),
            ),
            ListTile(
              leading: const Icon(LucideIcons.unplug),
              title: Text(l10n.driveDisconnectAction),
              subtitle: Text(l10n.driveDisconnectHint),
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
    if (!(disconnect ?? false) || !context.mounted) return;
    final ok = await confirmDialog(
      context,
      title: l10n.driveDisconnectTitle,
      message: l10n.driveDisconnectBody,
      confirmLabel: l10n.driveDisconnectAction,
    );
    if (ok) await cubit.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
        child: Row(
          spacing: 12,
          children: [
            CircleAvatar(
              backgroundColor: palette.task.background,
              foregroundColor: palette.task.foreground,
              child: const Icon(LucideIcons.cloudCheck, size: 20),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.driveConnected,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    account,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _manage(context),
              child: Text(l10n.driveManageAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({required this.crumbs, required this.onTap});

  final List<DriveCrumb> crumbs;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      label: l10n.driveFolderPath,
      container: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: [
          for (var i = 0; i < crumbs.length; i++) ...[
            if (i > 0)
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            if (i == crumbs.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  crumbs[i].name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 44),
                ),
                onPressed: () => onTap(i),
                child: Text(crumbs[i].name),
              ),
          ],
        ],
      ),
    );
  }
}

class _FolderGrid extends StatelessWidget {
  const _FolderGrid({
    required this.folders,
    required this.counts,
    required this.onOpen,
  });

  final List<DriveItem> folders;
  final Map<String, int> counts;
  final void Function(DriveItem) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        // Three across, as designed; two on narrow screens or big text.
        final columns = c.maxWidth < 330 ? 2 : 3;
        const gap = 8.0;
        final width = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final f in folders)
              SizedBox(
                width: width,
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onOpen(f),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          Icon(
                            LucideIcons.folder,
                            color: theme.colorScheme.primary,
                          ),
                          Text(
                            f.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            switch (counts[f.id]) {
                              null => ' ',
                              final n => l10n.driveItemCount(n),
                            },
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final type = SupportedFileType.fromName(name);
    if (type != null) return FileTypeBadge(type, width: 36);
    final theme = Theme.of(context);
    return ExcludeSemantics(
      child: Container(
        width: 36,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(LucideIcons.file, size: 18),
      ),
    );
  }
}

enum _FileAction { open, save, delete }

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.item,
    required this.busy,
    required this.onOpen,
    required this.onSave,
    required this.onDelete,
  });

  final DriveItem item;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    final type = SupportedFileType.fromName(item.name);
    final size = item.sizeBytes;
    final modified = item.modifiedAt;
    final meta = [
      ?type?.label,
      if (size != null) fmt.fileSize(size),
      if (modified != null) fmt.shortDate(modified),
    ].join(' · ');
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 14, right: 4),
      leading: _Badge(name: item.name),
      title: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: busy
          ? Text(l10n.driveFetching)
          : (meta.isEmpty ? null : Text(meta)),
      onTap: busy ? null : onOpen,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              tooltip: l10n.driveDownloadNamed(item.name),
              color: theme.colorScheme.primary,
              icon: const Icon(LucideIcons.download),
              onPressed: onSave,
            ),
          PopupMenuButton<_FileAction>(
            tooltip: l10n.moreOptionsFor(item.name),
            icon: const Icon(LucideIcons.ellipsisVertical),
            enabled: !busy,
            onSelected: (a) => switch (a) {
              _FileAction.open => onOpen(),
              _FileAction.save => onSave(),
              _FileAction.delete => onDelete(),
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _FileAction.open,
                child: Text(l10n.openAction),
              ),
              PopupMenuItem(
                value: _FileAction.save,
                child: Text(l10n.driveSaveToPhone),
              ),
              PopupMenuItem(
                value: _FileAction.delete,
                child: Text(l10n.driveDeleteAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadRow extends StatelessWidget {
  const _UploadRow({required this.upload});

  final DriveUpload upload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<DriveBrowserCubit>();
    final failure = upload.failure;
    final percent = (upload.progress * 100).floor();
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 14, right: 4),
      leading: _Badge(name: upload.name),
      title: Text(upload.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          if (failure == null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(
                value: upload.progress,
                borderRadius: BorderRadius.circular(2),
                semanticsLabel: l10n.driveUploadingPercent(percent),
              ),
            ),
          Text(
            failure == null
                ? l10n.driveUploadingPercent(percent)
                : failure.message(l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: failure == null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
        ],
      ),
      trailing: failure == null
          ? IconButton(
              tooltip: l10n.driveCancelUpload,
              icon: const Icon(LucideIcons.x),
              onPressed: () => cubit.cancelUpload(upload.key),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.retryAction,
                  icon: const Icon(LucideIcons.rotateCw),
                  onPressed: () => cubit.retryUpload(upload.key),
                ),
                IconButton(
                  tooltip: l10n.dismissAction,
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => cubit.dismissUpload(upload.key),
                ),
              ],
            ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({required this.problem});

  final DriveProblem problem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DriveBrowserCubit>();
    final reconnect = problem == DriveProblem.authExpired;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        NoticeBanner(
          message: l10n.driveProblem(problem.name),
          tone: NoticeTone.warning,
        ),
        FilledButton.tonal(
          onPressed: reconnect ? cubit.reconnect : cubit.refresh,
          child: Text(reconnect ? l10n.driveReconnectAction : l10n.retryAction),
        ),
      ],
    );
  }
}
