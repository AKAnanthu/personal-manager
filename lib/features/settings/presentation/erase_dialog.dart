import 'package:flutter/material.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Explains what erasing means and only confirms once the user types the
/// confirmation word, so it can't happen by an accidental tap.
Future<bool> confirmErase(
  BuildContext context, {
  required bool forgotPassword,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => _EraseDialog(forgotPassword: forgotPassword),
    ) ??
    false;

class _EraseDialog extends StatefulWidget {
  const _EraseDialog({required this.forgotPassword});

  final bool forgotPassword;

  @override
  State<_EraseDialog> createState() => _EraseDialogState();
}

class _EraseDialogState extends State<_EraseDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final word = l10n.eraseConfirmWord;
    final ready = _text.text.trim().toUpperCase() == word.toUpperCase();
    return AlertDialog(
      title: Text(
        widget.forgotPassword ? l10n.forgotPasswordTitle : l10n.eraseTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            if (widget.forgotPassword) Text(l10n.forgotPasswordBody),
            NoticeBanner(message: l10n.eraseBody, tone: NoticeTone.warning),
            Text(l10n.eraseKeepsBackups, style: theme.textTheme.bodySmall),
            TextField(
              controller: _text,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.eraseTypeToConfirm(word),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelAction),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          onPressed: ready ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.eraseAction),
        ),
      ],
    );
  }
}
