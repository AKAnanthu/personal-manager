import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_life_manager/app/app.dart';
import 'package:personal_life_manager/app/di.dart';
import 'package:personal_life_manager/app/flavor.dart';
import 'package:personal_life_manager/core/notifications/notification_scheduler.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:personal_life_manager/core/utils/app_logger.dart';
import 'package:personal_life_manager/features/settings/data/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final flavor = AppFlavor.current;

  try {
    await configureDependencies(flavor);
  } on Exception catch (e, st) {
    // File-system and platform-channel failures while opening storage.
    // The logger records only the error type, never its message (paths).
    AppLogger(verbose: flavor.isDev).error('startup failed', e, st);
    runApp(const StartupErrorApp());
    return;
  }

  final logger = sl<AppLogger>();
  FlutterError.onError = (details) {
    logger.error('flutter error', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('uncaught error', error, stack);
    return true;
  };

  unawaited(
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  );
  final notifications = sl<NotificationScheduler>();
  runApp(
    PlmApp(
      lock: sl<AppLock>(),
      initialLocation: await notifications.launchRoute(),
      notificationRoutes: notifications.tapRoutes,
      themeMode: sl<AppSettings>().themeMode,
    ),
  );
}
