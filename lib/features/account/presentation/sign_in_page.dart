import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/widgets/button_progress.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/features/account/presentation/sign_in_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

abstract final class LegalRoutes {
  static const privacy = '/privacy';
  static const terms = '/terms';
}

/// First screen: "Continue with Google", a short notice of how data is
/// kept, then the first download from Drive and one screen-lock check.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SignInCubit>();
    unawaited(cubit.checkClock());
    // Back from the phone's settings: check again.
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(cubit.checkClock()),
    );
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SignInCubit>();
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SignInCubit, SignInState>(
          builder: (context, s) => CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _AppMark(),
                      const SizedBox(height: 24),
                      ...switch (s.step) {
                        SignInStep.welcome ||
                        SignInStep.signingIn => _welcome(context, l10n, s),
                        SignInStep.downloading => _downloading(
                          context,
                          l10n,
                          s,
                        ),
                        SignInStep.syncFailed => [
                          NoticeBanner(
                            message: l10n.signInSyncFailed(
                              s.failure?.message(l10n) ?? l10n.errorGeneric,
                            ),
                            tone: NoticeTone.warning,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: cubit.retrySync,
                            child: Text(l10n.retryAction),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: cubit.continueWithoutSync,
                            child: Text(l10n.signInContinueLater),
                          ),
                        ],
                        SignInStep.unlock => _unlock(context, l10n, s),
                      },
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _welcome(
    BuildContext context,
    AppLocalizations l10n,
    SignInState s,
  ) {
    final theme = Theme.of(context);
    final cubit = context.read<SignInCubit>();
    final busy = s.step == SignInStep.signingIn;
    return [
      Text(
        l10n.signInTagline,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 24),
      _Point(icon: LucideIcons.cloud, text: l10n.signInPointDrive),
      _Point(icon: LucideIcons.refreshCw, text: l10n.signInPointSync),
      _Point(icon: LucideIcons.fingerprint, text: l10n.signInPointLock),
      if (!s.clockAutomatic) ...[
        const SizedBox(height: 8),
        NoticeBanner(message: l10n.clockNotAutomatic, tone: NoticeTone.warning),
        TextButton(
          onPressed: cubit.openDateSettings,
          child: Text(l10n.openDateSettingsAction),
        ),
      ],
      if (s.failure case final f?) ...[
        const SizedBox(height: 8),
        NoticeBanner(message: f.message(l10n), tone: NoticeTone.warning),
      ],
      const Spacer(),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: busy ? null : cubit.signIn,
        icon: busy ? const ButtonProgress() : const Icon(LucideIcons.logIn),
        label: Text(l10n.continueWithGoogle),
      ),
      const SizedBox(height: 12),
      Text(
        l10n.signInAgreement,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => context.push(LegalRoutes.terms),
            child: Text(l10n.termsTitle),
          ),
          TextButton(
            onPressed: () => context.push(LegalRoutes.privacy),
            child: Text(l10n.privacyTitle),
          ),
        ],
      ),
    ];
  }

  List<Widget> _downloading(
    BuildContext context,
    AppLocalizations l10n,
    SignInState s,
  ) => [
    const SizedBox(height: 32),
    Center(
      child: Semantics(
        label: l10n.signInDownloading,
        child: s.total == 0
            ? const CircularProgressIndicator()
            : CircularProgressIndicator(value: s.done / s.total),
      ),
    ),
    const SizedBox(height: 16),
    Text(l10n.signInDownloading, textAlign: TextAlign.center),
    if (s.total > 0)
      Text(
        l10n.signInDownloadProgress(s.done, s.total),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
  ];

  List<Widget> _unlock(
    BuildContext context,
    AppLocalizations l10n,
    SignInState s,
  ) {
    final cubit = context.read<SignInCubit>();
    return [
      Text(
        l10n.signInConfirmLock,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 16),
      if (s.noScreenLock) ...[
        NoticeBanner(message: l10n.noScreenLock, tone: NoticeTone.warning),
        TextButton(
          onPressed: cubit.openSecuritySettings,
          child: Text(l10n.openSecuritySettingsAction),
        ),
      ],
      const Spacer(),
      FilledButton.icon(
        onPressed: () => cubit.unlock(reason: l10n.deviceUnlockReason),
        icon: const Icon(LucideIcons.fingerprint),
        label: Text(l10n.unlockWithScreenLock),
      ),
    ];
  }
}

class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Container(
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
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 26),
          ),
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
