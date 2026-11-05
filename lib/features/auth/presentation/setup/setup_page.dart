import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/security/biometric_auth.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/button_progress.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/ui/widgets/password_field.dart';
import 'package:personal_life_manager/features/auth/domain/password_strength.dart';
import 'package:personal_life_manager/features/auth/presentation/setup/setup_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SetupCubit, SetupState>(
          buildWhen: (a, b) => a.step != b.step,
          builder: (context, state) => switch (state.step) {
            SetupStep.welcome => const _WelcomeStep(),
            SetupStep.password => const _PasswordStep(),
            SetupStep.biometric => const _BiometricStep(),
          },
        ),
      ),
    );
  }
}

/// Scrolling step content with the step's buttons pinned below it, so
/// nothing overflows at large text sizes and the primary action stays at
/// the bottom of the screen.
class _StepLayout extends StatelessWidget {
  const _StepLayout({
    required this.step,
    required this.content,
    required this.actions,
  });

  final SetupStep step;
  final List<Widget> content;
  final List<Widget> actions;

  static const _totalSteps = 3;

  @override
  Widget build(BuildContext context) {
    final number = step.index + 1;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            children: [
              _StepIndicator(step: number, total: _totalSteps),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)
                    .setupStepLabel(number, _totalSteps),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              ...content,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: actions,
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Row(
        spacing: 6,
        children: [
          for (var i = 1; i <= total; i++)
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= step ? scheme.primary : scheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: text.headlineSmall?.copyWith(fontSize: 26)),
        ),
        if (subtitle case final s?)
          Text(
            s,
            style: text.bodyLarge?.copyWith(color: context.palette.formLabel),
          ),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _StepLayout(
      step: SetupStep.welcome,
      content: [
        _StepHeader(
          title: l10n.setupWelcomeTitle,
          subtitle: l10n.setupWelcomeBody,
        ),
        const SizedBox(height: 20),
        const _DataStorageCard(),
      ],
      actions: [
        FilledButton(
          onPressed: context.read<SetupCubit>().start,
          child: Text(l10n.continueAction),
        ),
      ],
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SetupCubit>();
    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, state) => AutofillGroup(
        child: _StepLayout(
          step: SetupStep.password,
          content: [
            _StepHeader(
              title: l10n.setupPasswordTitle,
              subtitle: l10n.setupPasswordSubtitle,
            ),
            const SizedBox(height: 20),
            PasswordField(
              label: l10n.passwordLabel,
              autofocus: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: cubit.passwordChanged,
              helper: state.password.isEmpty
                  ? null
                  : _StrengthMeter(strength: state.strength),
            ),
            const SizedBox(height: 14),
            PasswordField(
              label: l10n.confirmPasswordLabel,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: cubit.confirmationChanged,
              onSubmitted: (_) => cubit.submitPassword(),
              errorText: state.confirmationMismatch
                  ? l10n.passwordsDoNotMatch
                  : null,
            ),
            const SizedBox(height: 20),
            const _DataStorageCard(),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: state.acknowledged,
              onChanged: (v) => cubit.acknowledgedChanged(value: v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.dataStorageAcknowledge,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (state.error == SetupError.storage) ...[
              const SizedBox(height: 8),
              Text(
                l10n.secureStorageError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
          actions: [
            FilledButton(
              onPressed: state.canSubmitPassword ? cubit.submitPassword : null,
              child: state.busy
                  ? const ButtonProgress()
                  : Text(l10n.continueAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final fill = strength.isAcceptable ? scheme.primary : scheme.error;
    return Semantics(
      label: l10n.passwordStrengthSemantics(strength.name),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            const SizedBox(height: 2),
            Row(
              spacing: 4,
              children: [
                for (var i = 1; i <= 4; i++)
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= strength.score ? fill : scheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              l10n.passwordStrengthHint(
                strength.name,
                PasswordStrength.minLength,
              ),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: context.palette.formLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataStorageCard extends StatelessWidget {
  const _DataStorageCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget line(IconData icon, String text) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: context.palette.formLabel,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              l10n.dataStorageTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            line(LucideIcons.smartphone, l10n.dataStorageLocal),
            line(LucideIcons.cloud, l10n.dataStorageDrive),
            NoticeBanner(
              message: l10n.dataStorageNotEncrypted,
              tone: NoticeTone.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _BiometricStep extends StatelessWidget {
  const _BiometricStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SetupCubit>();
    return BlocBuilder<SetupCubit, SetupState>(
      builder: (context, state) {
        final kind = state.biometricKind ?? BiometricKind.generic;
        return _StepLayout(
          step: SetupStep.biometric,
          content: [
            _StepHeader(
              title: l10n.setupBiometricTitle(kind.name),
              subtitle: l10n.setupBiometricBody,
            ),
            const SizedBox(height: 32),
            Center(
              child: Icon(
                kind == BiometricKind.face
                    ? LucideIcons.scanFace
                    : LucideIcons.fingerprint,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 20),
              Text(
                state.error == SetupError.biometricFailed
                    ? l10n.biometricFailed
                    : l10n.secureStorageError,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
          actions: [
            FilledButton(
              onPressed: state.busy
                  ? null
                  : () => cubit.enableBiometric(
                      reason: l10n.biometricReasonEnable,
                    ),
              child: state.busy
                  ? const ButtonProgress()
                  : Text(l10n.setupBiometricEnable),
            ),
            OutlinedButton(
              onPressed: state.busy ? null : cubit.skipBiometric,
              child: Text(l10n.setupBiometricSkip),
            ),
          ],
        );
      },
    );
  }
}
