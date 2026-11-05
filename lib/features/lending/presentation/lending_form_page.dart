import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/amount_field.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/pickers.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/lending/presentation/lending_form_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class LendingFormPage extends StatelessWidget {
  const LendingFormPage({required this.permissions, super.key});

  final NotificationPermissions permissions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<LendingFormCubit>();
    return BlocConsumer<LendingFormCubit, LendingFormState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        if (s.outcome != EditorOutcome.none) {
          if (s.notificationsBlocked) {
            showNotificationsBlocked(context, permissions);
          } else if (s.outcome == EditorOutcome.deleted) {
            showSnack(context, l10n.lendingDeletedSnack);
          }
          AppBackButton.popOrHome(context);
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
          cubit.clearFailure();
        }
      },
      buildWhen: (a, b) => a.loading != b.loading,
      builder: (context, s) => s.loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : const _Form(),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final LendingFormCubit _cubit = context.read<LendingFormCubit>();
  late final _person = TextEditingController(text: _cubit.state.person);
  late final _amount = TextEditingController(text: _cubit.state.amountText);
  late final _notes = TextEditingController(text: _cubit.state.notes);

  @override
  void dispose() {
    _person.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l10n.deleteLendingTitle,
      message: l10n.cannotUndoBody,
      confirmLabel: l10n.deleteAction,
    );
    if (ok) await _cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = AppFormats.of(context);
    return BlocBuilder<LendingFormCubit, LendingFormState>(
      builder: (context, s) {
        final given = s.givenOn;
        final due = s.dueOn;
        final lent = s.direction == LendingDirection.lent;
        return FormPage(
          title: s.isNew ? l10n.newLendingTitle : l10n.editLendingTitle,
          dirty: s.dirty,
          saving: s.busy,
          onSave: _cubit.save,
          actions: [
            if (!s.isNew)
              IconButton(
                tooltip: l10n.deleteAction,
                icon: const Icon(LucideIcons.trash2),
                onPressed: _confirmDelete,
              ),
          ],
          children: [
            SegmentedButton<LendingDirection>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: LendingDirection.lent,
                  label: Text(l10n.iLentMoney),
                ),
                ButtonSegment(
                  value: LendingDirection.borrowed,
                  label: Text(l10n.iBorrowedMoney),
                ),
              ],
              selected: {s.direction},
              onSelectionChanged: (v) => _cubit.directionChanged(v.first),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: l10n.personLabel,
              child: TextField(
                controller: _person,
                autofocus: s.isNew,
                textCapitalization: TextCapitalization.words,
                onChanged: _cubit.personChanged,
                decoration: InputDecoration(
                  errorText: s.showErrors && s.personMissing
                      ? l10n.fieldRequired
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: l10n.amountLabel,
              child: AmountField(
                controller: _amount,
                onChanged: _cubit.amountChanged,
                errorText: s.showErrors && s.amountPaise == null
                    ? l10n.amountRequired
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            PickerField(
              label: lent ? l10n.dateGivenLabel : l10n.dateBorrowedLabel,
              hint: l10n.pickDateHint,
              icon: LucideIcons.calendar,
              value: given == null ? null : fmt.fullDate(given),
              onTap: () async {
                final d = await pickDate(context, initial: given);
                if (d != null) _cubit.givenOnChanged(d);
              },
            ),
            const SizedBox(height: 14),
            PickerField(
              label: l10n.dueDateLabel,
              optional: true,
              hint: l10n.pickDateHint,
              icon: LucideIcons.calendarClock,
              value: due == null ? null : fmt.fullDate(due),
              errorText: s.showErrors && s.dueBeforeGiven
                  ? l10n.dueBeforeGivenError
                  : null,
              onTap: () async {
                final d = await pickDate(context, initial: due ?? given);
                if (d != null) _cubit.dueOnChanged(d);
              },
              onClear: () => _cubit.dueOnChanged(null),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: l10n.notesLabel,
              optional: true,
              child: TextField(
                controller: _notes,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _cubit.notesChanged,
                decoration: InputDecoration(hintText: l10n.lendingNotesHint),
              ),
            ),
            if (due != null) ...[
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: s.remind,
                onChanged: (v) => _cubit.remindChanged(value: v),
                title: Text(l10n.remindMeLabel),
                subtitle: Text(l10n.lendingRemindHelp),
              ),
            ],
            const SizedBox(height: 14),
            LabeledField(
              label: l10n.statusLabel,
              child: SegmentedButton<LendingStatus>(
                showSelectedIcon: false,
                segments: [
                  for (final st in LendingStatus.values)
                    ButtonSegment(
                      value: st,
                      label: Text(l10n.lendingStatus(st.name)),
                    ),
                ],
                selected: {s.status},
                onSelectionChanged: (v) => _cubit.statusChanged(v.first),
              ),
            ),
          ],
        );
      },
    );
  }
}
