import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Rupee amount input (₹ prefix, digits and separators only).
class AmountField extends StatelessWidget {
  const AmountField({
    required this.controller,
    required this.onChanged,
    super.key,
    this.errorText,
    this.autofocus = false,
    this.large = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool autofocus;
  final bool large;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    autofocus: autofocus,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))],
    style: large ? Theme.of(context).textTheme.headlineSmall : null,
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixText: '${Money.currencySymbol} ',
      errorText: errorText,
    ),
  );
}

/// Asks for an amount above zero; returns paise or null if cancelled.
Future<int?> askAmount(
  BuildContext context, {
  required String title,
  int? initialPaise,
}) => showDialog<int>(
  context: context,
  builder: (_) => _AmountDialog(title: title, initialPaise: initialPaise),
);

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({required this.title, this.initialPaise});

  final String title;
  final int? initialPaise;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  late final _text = TextEditingController(
    text: switch (widget.initialPaise) {
      final p? => Money.toInput(p),
      null => '',
    },
  );
  bool _showError = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    final v = Money.parseRupees(_text.text);
    if (v == null || v <= 0) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: AmountField(
        controller: _text,
        autofocus: true,
        large: true,
        onChanged: (_) {
          if (_showError) setState(() => _showError = false);
        },
        errorText: _showError ? l10n.amountRequired : null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.saveAction)),
      ],
    );
  }
}
