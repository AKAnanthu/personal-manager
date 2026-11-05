import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/core/ui/widgets/button_progress.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/ui/widgets/password_field.dart';
import 'package:personal_life_manager/features/auth/presentation/unlock/unlock_cubit.dart';
import 'package:personal_life_manager/features/settings/presentation/erase_dialog.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key, this.onErase});

  /// "Forgot password?": erases everything on this phone (owner decision:
  /// with no server, a clean start is the only way back in). Hidden when
  /// null.
  final Future<void> Function()? onErase;

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  final _password = TextEditingController();
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs once: the cubit is created per page instance.
    if (_initialised) return;
    _initialised = true;
    final reason = AppLocalizations.of(context).biometricReasonUnlock;
    unawaited(context.read<UnlockCubit>().init(biometricReason: reason));
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    unawaited(context.read<UnlockCubit>().unlockWithPassword(_password.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<UnlockCubit, UnlockState>(
          listenWhen: (a, b) => a.error != b.error && b.error != null,
          listener: (context, state) {
            if (state.error is WrongPasswordError) _password.clear();
          },
          builder: (context, state) {
            final message = _message(l10n, state);
            final kind = state.biometricKind;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: AutofillGroup(
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
                          const SizedBox(height: 32),
                          PasswordField(
                            label: l10n.appPasswordLabel,
                            controller: _password,
                            enabled: !state.isLockedOut,
                            onSubmitted: (_) => _submit(),
                            errorText: message,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: state.busy || state.isLockedOut
                                ? null
                                : _submit,
                            child: state.busy
                                ? const ButtonProgress()
                                : Text(l10n.unlockAction),
                          ),
                          if (kind != null) ...[
                            const SizedBox(height: 16),
                            _OrDivider(label: l10n.orDivider),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: state.busy
                                  ? null
                                  : () => context
                                        .read<UnlockCubit>()
                                        .unlockWithBiometrics(
                                          reason: l10n.biometricReasonUnlock,
                                        ),
                              icon: Icon(
                                kind == BiometricKind.face
                                    ? LucideIcons.scanFace
                                    : LucideIcons.fingerprint,
                              ),
                              label: Text(l10n.useBiometric(kind.name)),
                            ),
                          ],
                          if (widget.onErase case final erase?)
                            TextButton(
                              onPressed: state.busy
                                  ? null
                                  : () async {
                                      if (await confirmErase(
                                        context,
                                        forgotPassword: true,
                                      )) {
                                        await erase();
                                      }
                                    },
                              child: Text(l10n.forgotPasswordAction),
                            ),
                          const Spacer(),
                          const SizedBox(height: 32),
                          NoticeBanner(message: l10n.unlockInfo),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String? _message(AppLocalizations l10n, UnlockState state) {
    if (state.lockoutRemaining case final left?) {
      return l10n.lockedOut(_formatDuration(left));
    }
    return switch (state.error) {
      WrongPasswordError(:final attemptsBeforeLockout) => l10n.wrongPassword(
        attemptsBeforeLockout,
      ),
      BiometricFailedError() => l10n.biometricFailed,
      StorageError() => l10n.secureStorageError,
      null => null,
    };
  }

  static String _formatDuration(Duration d) {
    // Round up so the countdown never shows 0:00 while still locked.
    final total = (d.inMilliseconds / 1000).ceil();
    final minutes = total ~/ 60;
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 12,
    children: [
      const Expanded(child: Divider()),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const Expanded(child: Divider()),
    ],
  );
}
