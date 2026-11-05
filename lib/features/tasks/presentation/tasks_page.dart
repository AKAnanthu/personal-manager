import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/tasks/domain/task.dart';
import 'package:personal_life_manager/features/tasks/presentation/tasks_bloc.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TasksBloc>();
    return BlocListener<TasksBloc, TasksState>(
      listenWhen: (a, b) =>
          (b.failure != null && a.failure != b.failure) ||
          (b.justCompleted != null && a.justCompleted != b.justCompleted),
      listener: (context, s) {
        if (s.failure case final f?) return showSnack(context, f.message(l10n));
        final id = s.justCompleted;
        if (id == null) return;
        showSnack(
          context,
          l10n.taskCompletedSnack,
          actionLabel: l10n.undoAction,
          onAction: () => bloc.add(TaskCompletionToggled(id, completed: false)),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: _searching
              ? TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.searchTasksHint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  onChanged: (q) => bloc.add(TasksQueryChanged(q)),
                )
              : Text(l10n.moduleName('tasks')),
          actions: [
            IconButton(
              tooltip: _searching ? l10n.closeAction : l10n.searchTasksHint,
              icon: Icon(_searching ? LucideIcons.x : LucideIcons.search),
              onPressed: () {
                if (_searching) bloc.add(const TasksQueryChanged(''));
                setState(() => _searching = !_searching);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/tasks/new'),
          icon: const Icon(LucideIcons.plus),
          label: Text(l10n.newTaskAction),
        ),
        body: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, s) => _TasksBody(state: s, now: widget.now()),
        ),
      ),
    );
  }
}

class _TasksBody extends StatelessWidget {
  const _TasksBody({required this.state, required this.now});

  final TasksState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TasksBloc>();
    final overdue = state.showCompleted
        ? const <Task>[]
        : state.tasks.where((t) => t.isOverdue(now)).toList();
    final rest = state.showCompleted
        ? state.tasks
        : state.tasks.where((t) => !t.isOverdue(now)).toList();

    Widget list(List<Task> tasks) => SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.section,
      ),
      sliver: SliverList.separated(
        itemCount: tasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.gap),
        itemBuilder: (_, i) => _TaskCard(task: tasks[i], now: now),
      ),
    );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            4,
            AppSpacing.gutter,
            AppSpacing.section,
          ),
          sliver: SliverToBoxAdapter(
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(l10n.tasksPendingTab(state.pendingCount)),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(l10n.tasksCompletedTab(state.completedCount)),
                ),
              ],
              selected: {state.showCompleted},
              onSelectionChanged: (v) =>
                  bloc.add(TasksTabChanged(completed: v.first)),
            ),
          ),
        ),
        if (state.status == LoadStatus.loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (state.tasks.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: LucideIcons.squareCheck,
              title: state.query.isNotEmpty
                  ? l10n.tasksNoResults
                  : state.showCompleted
                  ? l10n.tasksEmptyCompleted
                  : l10n.tasksEmptyPending,
              message: state.query.isEmpty && !state.showCompleted
                  ? l10n.tasksEmptyPendingBody
                  : null,
            ),
          )
        else ...[
          if (overdue.isNotEmpty) ...[_label(l10n.tasksOverdue), list(overdue)],
          if (overdue.isNotEmpty && rest.isNotEmpty && !state.showCompleted)
            _label(l10n.tasksUpcoming),
          list(rest),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ],
    );
  }

  static Widget _label(String text) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
    sliver: SliverToBoxAdapter(child: SectionLabel(text)),
  );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.now});

  final Task task;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = AppFormats.of(context);
    final bloc = context.read<TasksBloc>();
    final overdue = task.isOverdue(now);
    final due = task.dueDate;
    final reminder = task.reminderAt;
    final subtitle = [
      if (due != null)
        l10n.dueOn(fmt.shortDate(due, now: now))
      else
        l10n.taskNoDueDate,
      if (reminder != null && !task.isCompleted)
        fmt.relativeDateTime(reminder, now),
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/tasks/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, AppSpacing.rowPadding, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    semanticLabel: task.isCompleted
                        ? l10n.taskMarkNotDone(task.title)
                        : l10n.taskMarkDone(task.title),
                    shape: const CircleBorder(),
                    onChanged: (v) => bloc.add(
                      TaskCompletionToggled(task.id, completed: v ?? false),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: overdue ? theme.colorScheme.error : null,
                            fontWeight: overdue ? FontWeight.w600 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (task.checklist.isNotEmpty)
                    Text(
                      l10n.checklistProgress(
                        task.checklistDone,
                        task.checklist.length,
                      ),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              if (task.checklist.isNotEmpty && !task.isCompleted)
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Column(
                    children: [
                      for (final item in task.checklist)
                        CheckboxListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: item.isDone,
                          onChanged: (v) => bloc.add(
                            ChecklistItemToggled(item.id, done: v ?? false),
                          ),
                          title: Text(
                            item.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: item.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isDone
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
