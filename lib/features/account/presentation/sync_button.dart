import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/sync/sync_engine.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/features/account/presentation/account_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// "Sync now" in the dashboard header: gets what another phone saved.
class SyncButton extends StatelessWidget {
  const SyncButton({required this.status, required this.onSync, super.key});

  final ValueListenable<SyncStatus> status;
  final Future<Result<SyncReport>> Function() onSync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder(
      valueListenable: status,
      builder: (context, s, _) {
        final busy = s.activity == SyncActivity.syncing;
        return IconButton(
          tooltip: l10n.syncNowAction,
          onPressed: busy
              ? null
              : () async {
                  final r = await onSync();
                  if (context.mounted) {
                    showSnack(context, syncResultText(l10n, r));
                  }
                },
          icon: busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Badge(
                  isLabelVisible: s.pending > 0 || s.failure != null,
                  smallSize: 8,
                  child: const Icon(LucideIcons.refreshCw),
                ),
        );
      },
    );
  }
}
