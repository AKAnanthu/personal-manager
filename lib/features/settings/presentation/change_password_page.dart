import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/ui/widgets/password_field.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/auth/domain/password_strength.dart';
import 'package:personal_life_manager/features/settings/presentation/settings_cubits.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ChangePasswordCubit>();
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listenWhen: (a, b) =>
          a.outcome != b.outcome || (b.storageError && !a.storageError),
      listener: (context, s) {
        if (s.outcome == ChangePasswordOutcome.changed) {
          showSnack(context, l10n.passwordChangedSnack);
          AppBackButton.popOrHome(context);
        } else if (s.storageError) {
          showSnack(context, l10n.errorGeneric);
        }
      },
      builder: (context, s) {
        final locked = s.lockedUntil;
        final attempts = s.attemptsLeft;
        String? currentError;
        if (locked != null) {
          currentError = l10n.lockedOut(AppFormats.of(context).time(locked));
        } else if (attempts != null) {
          currentError = l10n.wrongPassword(attempts);
        } else if (s.showErrors && s.current.isEmpty) {
          currentError = l10n.fieldRequired;
        }
        String? newError;
        if (s.showErrors && !s.strength.isAcceptable) {
          newError = l10n.passwordTooShort(PasswordStrength.minLength);
        } else if (s.showErrors && s.sameAsCurrent) {
          newError = l10n.passwordSameAsCurrent;
        }
        return FormPage(
          title: l10n.changePasswordTitle,
          saving: s.busy,
          onSave: locked != null && locked.isAfter(DateTime.now())
              ? null
              : cubit.submit,
          children: [
            PasswordField(
              label: l10n.currentPasswordLabel,
              autofocus: true,
              onChanged: cubit.currentChanged,
              errorText: currentError,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            PasswordField(
              label: l10n.newPasswordLabel,
              onChanged: cubit.replacementChanged,
              errorText: newError,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              helper: s.replacement.isEmpty
                  ? null
                  : Text(
                      l10n.passwordStrengthHint(
                        s.strength.name,
                        PasswordStrength.minLength,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
            ),
            const SizedBox(height: 14),
            PasswordField(
              label: l10n.confirmPasswordLabel,
              onChanged: cubit.confirmChanged,
              onSubmitted: (_) => cubit.submit(),
              autofillHints: const [AutofillHints.newPassword],
              errorText: s.showErrors && s.mismatch
                  ? l10n.passwordsDoNotMatch
                  : null,
            ),
            const SizedBox(height: 16),
            NoticeBanner(message: l10n.unlockInfo),
          ],
        );
      },
    );
  }
}
