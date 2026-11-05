import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/widgets/button_progress.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Full-screen form: ✕ to cancel, a pill Save button in the app bar.
/// Leaving with unsaved changes asks for confirmation.
class FormPage extends StatelessWidget {
  const FormPage({
    required this.title,
    required this.children,
    required this.onSave,
    super.key,
    this.dirty = false,
    this.saving = false,
    this.actions = const [],
  });

  final String title;
  final List<Widget> children;

  /// Null disables Save (e.g. invalid input).
  final VoidCallback? onSave;
  final bool dirty;
  final bool saving;

  /// Extra app-bar actions (e.g. a delete menu) placed before Save.
  final List<Widget> actions;

  Future<void> _leave(BuildContext context) async {
    if (!dirty) {
      AppBackButton.popOrHome(context);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final discard = await confirmDialog(
      context,
      title: l10n.discardChangesTitle,
      message: l10n.discardChangesBody,
      confirmLabel: l10n.discardAction,
    );
    if (discard && context.mounted) AppBackButton.popOrHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave(context));
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            tooltip: l10n.closeAction,
            onPressed: () => _leave(context),
          ),
          title: Text(title),
          actions: [
            ...actions,
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(72, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  textStyle: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                onPressed: saving ? null : onSave,
                child: saving ? const ButtonProgress() : Text(l10n.saveAction),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              8,
              AppSpacing.gutter,
              32,
            ),
            children: children,
          ),
        ),
      ),
    );
  }
}
