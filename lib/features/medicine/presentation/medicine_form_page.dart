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
import 'package:personal_life_manager/core/ui/widgets/pickers.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_cubits.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_text.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class MedicineFormPage extends StatelessWidget {
  const MedicineFormPage({required this.permissions, super.key});

  final NotificationPermissions permissions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<MedicineFormCubit>();
    return BlocConsumer<MedicineFormCubit, MedicineFormState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        if (s.outcome != EditorOutcome.none) {
          if (s.notificationsBlocked) {
            showNotificationsBlocked(context, permissions);
          } else if (s.outcome == EditorOutcome.deleted) {
            showSnack(context, l10n.medicineDeletedSnack);
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
          : _Form(permissions: permissions),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.permissions});

  final NotificationPermissions permissions;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final MedicineFormCubit _cubit = context.read<MedicineFormCubit>();
  late final _name = TextEditingController(text: _cubit.state.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _addTime() async {
    final last = _cubit.state.times.lastOrNull;
    final t = await pickTime(
      context,
      initial: last == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: (last.hour + 12) % 24, minute: last.minute),
    );
    if (t != null) _cubit.addTime(TimeOfDayMinutes(t.hour, t.minute));
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l10n.deleteMedicineTitle,
      message: l10n.cannotUndoBody,
      confirmLabel: l10n.deleteAction,
    );
    if (ok) await _cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return BlocBuilder<MedicineFormCubit, MedicineFormState>(
      builder: (context, s) => FormPage(
        title: s.isNew ? l10n.addMedicineAction : l10n.editMedicineTitle,
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
            label: l10n.medicineNameLabel,
            child: TextField(
              controller: _name,
              autofocus: s.isNew,
              textCapitalization: TextCapitalization.sentences,
              onChanged: _cubit.nameChanged,
              decoration: InputDecoration(
                errorText: s.showErrors && s.nameMissing
                    ? l10n.fieldRequired
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          SectionLabel(l10n.reminderTimesLabel),
          for (final t in s.times)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.gap),
              child: ListTile(
                leading: const Icon(LucideIcons.alarmClock),
                title: Text(
                  formatDoseTime(context, t),
                  style: theme.textTheme.titleMedium,
                ),
                trailing: IconButton(
                  tooltip: l10n.removeTimeTooltip(formatDoseTime(context, t)),
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => _cubit.removeTime(t),
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addTime,
              icon: const Icon(LucideIcons.plus),
              label: Text(
                s.times.isEmpty ? l10n.addTimeAction : l10n.addAnotherTime,
              ),
            ),
          ),
          if (s.showErrors && s.timesMissing)
            Text(
              l10n.medicineTimesRequired,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          const SizedBox(height: AppSpacing.section),
          SectionLabel(l10n.medicineDaysLabel),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: true, label: Text(l10n.medicineEveryDay)),
              ButtonSegment(
                value: false,
                label: Text(l10n.medicineSelectedDays),
              ),
            ],
            selected: {s.everyDay},
            onSelectionChanged: (v) => _cubit.everyDayChanged(value: v.first),
          ),
          if (!s.everyDay) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var d = 1; d <= 7; d++)
                  FilterChip(
                    showCheckmark: false,
                    label: Text(weekdayShort(locale, d)),
                    // Full name for screen readers ("Monday").
                    tooltip: weekdayLong(locale, d),
                    selected: s.weekdays.contains(d),
                    onSelected: (_) => _cubit.weekdayToggled(d),
                  ),
              ],
            ),
            if (s.showErrors && s.daysMissing)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.medicineDaysRequired,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.section),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: s.enabled,
            onChanged: (v) => _cubit.enabledChanged(value: v),
            title: Text(l10n.medicineRemindersOn),
            subtitle: Text(l10n.medicineRemindersOnHelp),
          ),
          if (s.enabled && !widget.permissions.exactAlarmsAvailable)
            Text(l10n.exactAlarmsOffMessage, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
