import 'package:flutter/material.dart';
import 'package:personal_life_manager/app/modules.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/features/dashboard/presentation/dashboard_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          16,
          AppSpacing.gutter,
          24,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.section),
            child: Semantics(
              header: true,
              child: Text(
                l10n.moreTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          ModuleGrid(modules: AppModule.more),
        ],
      ),
    );
  }
}

/// Full-screen page for a module whose milestone hasn't landed yet.
class ModulePlaceholderPage extends StatelessWidget {
  const ModulePlaceholderPage({required this.module, super.key});

  final AppModule module;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.moduleName(module.name)),
      ),
      body: EmptyState(icon: module.icon, title: l10n.sectionUnderConstruction),
    );
  }
}
