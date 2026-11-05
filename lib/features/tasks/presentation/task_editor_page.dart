import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/ui/widgets/pickers.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/tasks/presentation/task_editor_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class TaskEditorPage extends StatelessWidget {
  const TaskEditorPage({required this.permissions, super.key});

  final NotificationPermissions permissions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<TaskEditorCubit>();
    return BlocConsumer<TaskEditorCubit, TaskEditorState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        if (s.outcome != EditorOutcome.none) {
          if (s.notificationsBlocked) {
            showNotificationsBlocked(context, permissions);
          } else if (s.outcome == EditorOutcome.deleted) {
            showSnack(context, l10n.taskDeletedSnack);
          }
          AppBackButton.popOrHome(context);
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
          cubit.clearFailure();
        }
      },
      buildWhen: (a, b) => a.loading != b.loading || a.isNew != b.isNew,
      builder: (context, s) => s.loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _TaskForm(permissions: permissions),
    );
  }
}

class _TaskForm extends StatefulWidget {
  const _TaskForm({required this.permissions});

  final NotificationPermissions permissions;

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  late final TaskEditorCubit _cubit = context.read<TaskEditorCubit>();
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

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l10n.deleteTaskTitle,
      message: l10n.cannotUndoBody,
      confirmLabel: l10n.deleteAction,
    );
    if (ok) await _cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = AppFormats.of(context);
    return BlocBuilder<TaskEditorCubit, TaskEditorState>(
      builder: (context, s) {
        final due = s.dueDate;
        final reminder = s.reminderAt;
        return FormPage(
          title: s.isNew ? l10n.newTaskTitle : l10n.editTaskTitle,
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
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _cubit.descriptionChanged,
              ),
            ),
            const SizedBox(height: 14),
            PickerField(
              label: l10n.dueDateLabel,
              optional: true,
              hint: l10n.pickDateHint,
              icon: LucideIcons.calendar,
              value: due == null ? null : fmt.weekdayDate(due),
              onTap: () async {
                final d = await pickDate(context, initial: due);
                if (d != null) _cubit.dueDateChanged(d);
              },
              onClear: () => _cubit.dueDateChanged(null),
            ),
            const SizedBox(height: 14),
            PickerField(
              label: l10n.reminderLabel,
              optional: true,
              hint: l10n.pickTimeHint,
              icon: LucideIcons.bell,
              value: reminder == null
                  ? null
                  : l10n.whenDateTime(
                      fmt.weekdayDate(reminder),
                      fmt.time(reminder),
                    ),
              errorText: s.showErrors && _cubit.reminderInvalid
                  ? l10n.timeInPastError
                  : null,
              onTap: () async {
                final d = await pickDateTime(context, initial: reminder ?? due);
                if (d != null) _cubit.reminderChanged(d);
              },
              onClear: () => _cubit.reminderChanged(null),
            ),
            if (reminder != null &&
                !widget.permissions.exactAlarmsAvailable) ...[
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
            const SizedBox(height: AppSpacing.section),
            SectionLabel(l10n.checklistLabel),
            for (final item in s.items)
              _ChecklistRow(key: ValueKey(item.key), item: item),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _cubit.addItem,
                icon: const Icon(LucideIcons.plus),
                label: Text(l10n.addChecklistItem),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChecklistRow extends StatefulWidget {
  const _ChecklistRow({required this.item, super.key});

  final EditableItem item;

  @override
  State<_ChecklistRow> createState() => _ChecklistRowState();
}

class _ChecklistRowState extends State<_ChecklistRow> {
  late final _text = TextEditingController(text: widget.item.label);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<TaskEditorCubit>();
    final item = widget.item;
    return Row(
      children: [
        Checkbox(
          value: item.isDone,
          semanticLabel: item.label,
          onChanged: (v) => cubit.itemToggled(item.key, done: v ?? false),
        ),
        Expanded(
          child: TextField(
            controller: _text,
            autofocus: item.label.isEmpty && item.id == null,
            onChanged: (v) => cubit.itemChanged(item.key, v),
            decoration: InputDecoration(
              hintText: l10n.checklistItemHint,
              isDense: true,
            ),
          ),
        ),
        IconButton(
          tooltip: l10n.removeChecklistItem,
          icon: const Icon(LucideIcons.x),
          onPressed: () => cubit.removeItem(item.key),
        ),
      ],
    );
  }
}
