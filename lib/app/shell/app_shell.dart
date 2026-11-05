import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Bottom-navigation shell. Each tab keeps its own navigation stack.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            NavigationDestination(
              icon: const Icon(LucideIcons.house),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.fileText),
              label: l10n.navDocuments,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.shoppingCart),
              label: l10n.navShopping,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.ellipsis),
              label: l10n.navMore,
            ),
          ],
        ),
      ),
    );
  }
}
