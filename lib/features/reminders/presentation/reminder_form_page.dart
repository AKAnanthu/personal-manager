import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/ui/widgets/pickers.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/reminders/presentation/reminder_form_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class ReminderFormPage extends StatelessWidget {
  const ReminderFormPage({required this.permissions, super.key});

  final NotificationPermissions permissions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ReminderFormCubit>();
    return BlocConsumer<ReminderFormCubit, ReminderFormState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        if (s.outcome != EditorOutcome.none) {
          if (s.notificationsBlocked) {
            showNotificationsBlocked(context, permissions);
          } else if (s.outcome == EditorOutcome.deleted) {
            showSnack(context, l10n.reminderDeletedSnack);
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
          : _ReminderForm(permissions: permissions),
    );
  }
}

class _ReminderForm extends StatefulWidget {
  const _ReminderForm({required this.permissions});

  final NotificationPermissions permissions;

  @override
  State<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<_ReminderForm> {
  late final ReminderFormCubit _cubit = context.read<ReminderFormCubit>();
  late final _title = TextEditingController(text: _cubit.state.title);
  late final _description = TextEditingController(
    text: _cubit.state.description,
  );

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  String _repeatHelp(
    AppLocalizations l10n,
    AppFormats fmt,
    ReminderFormState s,
  ) {
    final d = s.date;
    if (d == null) return '';
    return switch (s.repeat) {
      RepeatFrequency.none => l10n.repeatHelpOnce,
      RepeatFrequency.daily => l10n.repeatHelpDaily,
      RepeatFrequency.weekly => l10n.repeatHelpWeekly(fmt.weekdayName(d)),
      RepeatFrequency.monthly =>
        d.day > 28
            ? l10n.repeatHelpMonthlyEnd(d.day)
            : l10n.repeatHelpMonthly(d.day),
      RepeatFrequency.yearly =>
        d.month == 2 && d.day == 29
            ? l10n.repeatHelpLeapDay
            : l10n.repeatHelpYearly(fmt.dayMonth(d)),
    };
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l10n.deleteReminderTitle,
      message: l10n.cannotUndoBody,
      confirmLabel: l10n.deleteAction,
    );
    if (ok) await _cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = AppFormats.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<ReminderFormCubit, ReminderFormState>(
      builder: (context, s) {
        final date = s.date;
        final at = s.at;
        final pastError = s.showErrors && _cubit.timeInvalid;
        return FormPage(
          title: s.isNew ? l10n.newReminderTitle : l10n.editReminderTitle,
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
            LabeledField(
              label: l10n.titleLabel,
              child: TextField(
                controller: _title,
                autofocus: s.isNew,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _cubit.titleChanged,
                decoration: InputDecoration(
                  errorText: s.showErrors && s.titleMissing
                      ? l10n.fieldRequired
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: l10n.descriptionLabel,
              optional: true,
              child: TextField(
                controller: _description,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _cubit.descriptionChanged,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: 220,
                  child: PickerField(
                    label: l10n.dateLabel,
                    hint: l10n.pickDateHint,
                    icon: LucideIcons.calendar,
                    value: date == null ? null : fmt.weekdayDate(date),
                    errorText: pastError ? l10n.timeInPastError : null,
                    onTap: () async {
                      final d = await pickDate(
                        context,
                        initial: date,
                        now: _cubit.now,
                      );
                      if (d != null) _cubit.dateChanged(d);
                    },
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: PickerField(
                    label: l10n.timeLabel,
                    hint: l10n.pickTimeHint,
                    icon: LucideIcons.clock,
                    value: at == null ? null : fmt.time(at),
                    onTap: () async {
                      final h = s.hour;
                      final m = s.minute;
                      final t = await pickTime(
                        context,
                        initial: h == null || m == null
                            ? null
                            : TimeOfDay(hour: h, minute: m),
                      );
                      if (t != null) _cubit.timeChanged(t.hour, t.minute);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            Text(
              l10n.repeatSectionLabel,
              style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: AppSpacing.gap,
              runSpacing: AppSpacing.gap,
              children: [
                for (final r in RepeatFrequency.values)
                  ChoiceChip(
                    label: Text(l10n.repeatName(r.name)),
                    selected: s.repeat == r,
                    onSelected: (_) => _cubit.repeatChanged(r),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_repeatHelp(l10n, fmt, s), style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.section),
            NoticeBanner(message: l10n.reminderFormInfo),
            if (!widget.permissions.exactAlarmsAvailable) ...[
              const SizedBox(height: 10),
              NoticeBanner(
                message: l10n.exactAlarmsOffMessage,
                tone: NoticeTone.warning,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.permissions.requestExactAlarms,
                  child: Text(l10n.allowAction),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
