import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/widgets/button_progress.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/features/account/presentation/sign_in_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Locked: the phone's screen lock opens the app. The prompt shows by
/// itself when the page opens.
class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  bool _prompted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prompted) return;
    _prompted = true;
    final reason = AppLocalizations.of(context).deviceUnlockReason;
    unawaited(context.read<UnlockCubit>().unlock(reason: reason));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cubit = context.read<UnlockCubit>();
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<UnlockCubit, UnlockState>(
          builder: (context, s) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      LucideIcons.layoutGrid,
                      size: 36,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.unlockSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                if (s.noScreenLock) ...[
                  NoticeBanner(
                    message: l10n.noScreenLock,
                    tone: NoticeTone.warning,
                  ),
                  TextButton(
                    onPressed: cubit.openSecuritySettings,
                    child: Text(l10n.openSecuritySettingsAction),
                  ),
                ],
                const Spacer(),
                FilledButton.icon(
                  onPressed: s.busy
                      ? null
                      : () => cubit.unlock(reason: l10n.deviceUnlockReason),
                  icon: s.busy
                      ? const ButtonProgress()
                      : const Icon(LucideIcons.fingerprint),
                  label: Text(l10n.unlockWithScreenLock),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
