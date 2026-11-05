import 'package:flutter/material.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// One-field text dialog. Returns the trimmed text, or null when cancelled
/// or left empty.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String hint,
}) async {
  final r = await showDialog<String>(
    context: context,
    builder: (_) => _TextPromptDialog(title: title, hint: hint),
  );
  final t = r?.trim();
  return t == null || t.isEmpty ? null : t;
}

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _text,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_text.text),
          child: Text(l10n.addAction),
        ),
      ],
    );
  }
}
