import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/theme/app_palette.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Masked text field with a label above it and a reveal toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.label,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.helper,
    this.autofocus = false,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final Widget? helper;
  final bool autofocus;
  final bool enabled;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 13,
              color: context.palette.formLabel,
            ),
          ),
        ),
        Semantics(
          label: widget.label,
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            obscureText: _obscured,
            enableSuggestions: false,
            autocorrect: false,
            autofillHints: widget.autofillHints,
            textInputAction: widget.textInputAction,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              errorText: widget.errorText,
              errorMaxLines: 3,
              suffixIcon: IconButton(
                tooltip: _obscured ? l10n.showPassword : l10n.hidePassword,
                icon: Icon(_obscured ? LucideIcons.eye : LucideIcons.eyeOff),
                color: theme.colorScheme.onSurfaceVariant,
                onPressed: () => setState(() => _obscured = !_obscured),
              ),
            ),
          ),
        ),
        ?widget.helper,
      ],
    );
  }
}
