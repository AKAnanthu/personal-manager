import 'package:flutter/material.dart';

/// Spinner shown inside a button while its action runs.
class ButtonProgress extends StatelessWidget {
  const ButtonProgress({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 22,
    child: CircularProgressIndicator(strokeWidth: 2.4),
  );
}
