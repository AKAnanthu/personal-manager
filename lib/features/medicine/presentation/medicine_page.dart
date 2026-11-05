import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/features/medicine/domain/medicine.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_cubits.dart';
import 'package:personal_life_manager/features/medicine/presentation/medicine_text.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

abstract final class MedicineRoutes {
  static const root = '/medicine';
  static const add = '/medicine/new';
  static String edit(String id) => '/medicine/$id';
}

class MedicinePage extends StatelessWidget {
  const MedicinePage({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<MedicineListCubit, MedicineListState>(
      listenWhen: (a, b) => b.failure != null && a.failure != b.failure,
      listener: (context, s) {
        if (s.failure case final f?) showSnack(context, f.message(l10n));
      },
      builder: (context, s) {
        final next = nextDose(s.medicines, now());
        return Scaffold(
          appBar: AppBar(
            leading: const AppBackButton(),
            title: Text(l10n.moduleName('medicine')),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push(MedicineRoutes.add),
            icon: const Icon(LucideIcons.plus),
            label: Text(l10n.addMedicineAction),
          ),
          body: s.status == LoadStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    4,
                    AppSpacing.gutter,
                    96,
                  ),
                  children: [
                    if (next != null) ...[
                      _NextUp(dose: next, now: now()),
                      const SizedBox(height: AppSpacing.section),
                    ],
                    if (s.medicines.isEmpty)
                      EmptyState(
                        icon: LucideIcons.pill,
                        title: l10n.medicineEmptyTitle,
                        message: l10n.medicineEmptyBody,
                      )
                    else
                      for (final m in s.medicines)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.gap,
                          ),
                          child: _MedicineCard(medicine: m),
                        ),
                    const SizedBox(height: AppSpacing.section),
                    Text(
                      l10n.medicineDisclaimer,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _NextUp extends StatelessWidget {
  const _NextUp({required this.dose, required this.now});

  final ({Medicine medicine, DateTime at}) dose;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = context.palette.medicine;
    // Round up so "in 0 min" never shows before the time.
    final minutes = (dose.at.difference(now).inSeconds + 59) ~/ 60;
    final time = formatDoseTime(
      context,
      TimeOfDayMinutes(dose.at.hour, dose.at.minute),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.background,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        spacing: 14,
        children: [
          Icon(LucideIcons.alarmClock, color: accent.foreground),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  l10n.medicineNextUp(minutes ~/ 60, minutes % 60),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: accent.foreground,
                  ),
                ),
                Text(
                  '${dose.medicine.name} · $time',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accent.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = context.palette;
    final m = medicine;
    final muted = !m.enabled;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(MedicineRoutes.edit(m.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            spacing: 12,
            children: [
              IconTile(icon: LucideIcons.pill, colors: palette.medicine),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      m.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: muted
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final t in m.times)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: muted
                                  ? palette.mutedTile
                                  : palette.medicine.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              formatDoseTime(context, t),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: muted
                                    ? theme.colorScheme.onSurfaceVariant
                                    : palette.medicine.foreground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      [
                        daysLabel(context, m),
                        if (muted) l10n.medicinePaused,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: m.enabled,
                onChanged: (v) =>
                    context.read<MedicineListCubit>().setEnabled(m, value: v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
