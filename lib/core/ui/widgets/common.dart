import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Back arrow that pops, or goes home when the page was opened directly
/// (deep link / notification tap).
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.icon = LucideIcons.arrowLeft});

  final IconData icon;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon),
    tooltip: icon == LucideIcons.x
        ? AppLocalizations.of(context).closeAction
        : MaterialLocalizations.of(context).backButtonTooltip,
    onPressed: () => popOrHome(context),
  );

  static void popOrHome(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      // Outside the app router (dialog-style pushes, isolated tests).
      Navigator.of(context).maybePop();
    } else if (router.canPop()) {
      router.pop();
    } else {
      router.go('/home');
    }
  }
}

/// Upper-case grey section heading ("PINNED", "RECENT").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.gap),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

/// Card containing rows separated by hairline dividers.
class GroupCard extends StatelessWidget {
  const GroupCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(),
          children[i],
        ],
      ],
    ),
  );
}

/// Rounded square icon on a coloured background.
class IconTile extends StatelessWidget {
  const IconTile({
    required this.icon,
    required this.colors,
    super.key,
    this.size = 40,
  });

  final IconData icon;
  final AccentPair colors;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadii.iconTile),
      ),
      child: Icon(icon, size: size / 2, color: colors.foreground),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          if (message case final m?)
            Text(
              m,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

/// Label above a form field, as in the designs.
class LabeledField extends StatelessWidget {
  const LabeledField({
    required this.label,
    required this.child,
    super.key,
    this.optional = false,
  });

  final String label;
  final Widget child;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelLarge?.copyWith(
      fontSize: 13,
      color: context.palette.formLabel,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        ExcludeSemantics(
          child: Text.rich(
            TextSpan(
              text: label,
              children: [
                if (optional)
                  TextSpan(
                    text: ' ${AppLocalizations.of(context).optionalSuffix}',
                    style: style?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            style: style,
          ),
        ),
        Semantics(label: label, child: child),
      ],
    );
  }
}

/// Read-only field that opens a picker on tap, with an optional clear button.
class PickerField extends StatelessWidget {
  const PickerField({
    required this.label,
    required this.hint,
    required this.onTap,
    required this.icon,
    super.key,
    this.value,
    this.onClear,
    this.errorText,
    this.optional = false,
  });

  final String label;
  final String hint;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String? errorText;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clear = onClear;
    return LabeledField(
      label: label,
      optional: optional,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.control),
        child: InputDecorator(
          isEmpty: value == null,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: value != null && clear != null
                ? IconButton(
                    tooltip: AppLocalizations.of(context).clearAction,
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: clear,
                  )
                : null,
          ),
          child: value == null
              ? null
              : Text(value ?? '', style: theme.textTheme.bodyLarge),
        ),
      ),
    );
  }
}

/// Destructive confirmation. Returns true when confirmed.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? message,
  bool destructive = true,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? TextButton.styleFrom(foregroundColor: scheme.error)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

void showSnack(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
}
