import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Every module, its route and icon (Dashboard quick access, More grid).
enum AppModule {
  personal('/personal', LucideIcons.user),
  passwords('/passwords', LucideIcons.keyRound),
  documents('/documents', LucideIcons.fileText),
  notes('/notes', LucideIcons.notebookPen),
  tasks('/tasks', LucideIcons.squareCheck),
  reminders('/reminders', LucideIcons.bell),
  shopping('/shopping', LucideIcons.shoppingCart),
  budget('/budget', LucideIcons.wallet),
  lending('/lending', LucideIcons.arrowLeftRight),
  medicine('/medicine', LucideIcons.pill),
  breathe('/breathe', LucideIcons.wind),
  drive('/drive', LucideIcons.cloud),
  backup('/backup', LucideIcons.databaseBackup),
  settings('/settings', LucideIcons.settings);

  AppModule(this.route, this.icon);

  final String route;
  final IconData icon;

  /// Dashboard "Quick access" (as designed; navigation only — no budget
  /// figures on the dashboard).
  static const List<AppModule> quickAccess = [
    personal,
    passwords,
    notes,
    tasks,
    reminders,
    budget,
    lending,
    breathe,
  ];

  /// Modules reached from the More tab (the rest have their own tab).
  static List<AppModule> get more =>
      values.where((m) => m != documents && m != shopping).toList();
}
