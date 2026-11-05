import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_life_manager/app/router.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';

class PlmApp extends StatefulWidget {
  const PlmApp({
    required this.lock,
    super.key,
    this.router,
    this.initialLocation,
    this.notificationRoutes,
    this.themeMode,
  });

  final AppLock lock;

  /// The Settings theme choice; system default when null.
  final ValueListenable<ThemeMode>? themeMode;

  /// Where to start, e.g. the target of the notification that launched the
  /// app. The lock guard still applies.
  final String? initialLocation;

  /// Routes from notification taps while the app is running.
  final Stream<String>? notificationRoutes;

  /// Injectable for tests.
  final GoRouter? router;

  @override
  State<PlmApp> createState() => _PlmAppState();
}

class _PlmAppState extends State<PlmApp> {
  late final GoRouter _router =
      widget.router ??
      buildRouter(lock: widget.lock, initialLocation: widget.initialLocation);
  StreamSubscription<String>? _taps;

  @override
  void initState() {
    super.initState();
    _taps = widget.notificationRoutes?.listen(_router.go);
  }

  @override
  void dispose() {
    unawaited(_taps?.cancel());
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: widget.themeMode ?? _system,
    builder: (context, mode, _) => MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: appSupportedLocales,
      routerConfig: _router,
    ),
  );

  static final ValueNotifier<ThemeMode> _system = ValueNotifier(
    ThemeMode.system,
  );
}

/// Shown when local storage can't be opened, so the user isn't left with a
/// blank screen.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                AppLocalizations.of(context).startupFailed,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
