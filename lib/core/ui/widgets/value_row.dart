import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/security/sensitive_clipboard.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Copies [value] and confirms with a snackbar. Sensitive values are cleared
/// from the clipboard after 30 s.
Future<void> copyValue(
  BuildContext context,
  SensitiveClipboard clipboard, {
  required String label,
  required String value,
  bool sensitive = false,
}) async {
  final l10n = AppLocalizations.of(context);
  await clipboard.copy(value, sensitive: sensitive);
  if (!context.mounted) return;
  showSnack(
    context,
    sensitive ? l10n.copiedSensitiveSnack(label) : l10n.copiedSnack(label),
  );
}

/// Small label over a value, with copy and (when [masked] is set) a reveal
/// toggle. Used for login details and personal-detail fields.
class ValueRow extends StatefulWidget {
  const ValueRow({
    required this.label,
    required this.value,
    required this.onCopy,
    super.key,
    this.masked,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 4, 10),
    this.background,
    this.monospace = false,
  });

  final String label;
  final String value;

  /// Shown instead of [value] until revealed. Null: never masked.
  final String? masked;
  final VoidCallback onCopy;
  final EdgeInsets padding;
  final Color? background;

  /// Letter-spaced, for ID numbers and passwords.
  final bool monospace;

  @override
  State<ValueRow> createState() => _ValueRowState();
}

class _ValueRowState extends State<ValueRow> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final masked = widget.masked;
    final hidden = masked != null && !_revealed;
    final row = Padding(
      padding: widget.padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  widget.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Semantics(
                  // Never read a hidden value aloud.
                  label: hidden ? l10n.hiddenValueSemantics : null,
                  excludeSemantics: hidden,
                  child: Text(
                    hidden ? masked : widget.value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      letterSpacing: widget.monospace || hidden ? 0.6 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (masked != null)
            IconButton(
              tooltip: _revealed
                  ? l10n.hideValueTooltip(widget.label)
                  : l10n.showValueTooltip(widget.label),
              color: theme.colorScheme.onSurfaceVariant,
              icon: Icon(_revealed ? LucideIcons.eyeOff : LucideIcons.eye),
              onPressed: () => setState(() => _revealed = !_revealed),
            ),
          IconButton(
            tooltip: l10n.copyTooltip(widget.label),
            color: theme.colorScheme.primary,
            icon: const Icon(LucideIcons.copy),
            onPressed: widget.onCopy,
          ),
        ],
      ),
    );
    final bg = widget.background;
    return bg == null
        ? row
        : DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: row,
          );
  }
}
