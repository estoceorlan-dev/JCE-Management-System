import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/logger/app_logger.dart';
import 'core/routing/app_router.dart';
import 'core/startup/app_startup.dart';
import 'core/sync/background_sync.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBackgroundSync();

  final container = ProviderContainer();
  // The web engine resets its default route after the first navigation message.
  container.read(launchRouteProvider);
  final logger = container.read(appLoggerProvider);

  FlutterError.onError = (details) {
    logger.error(
      'Unhandled Flutter framework error.',
      scope: 'flutter',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error(
      'Unhandled platform error.',
      scope: 'platform',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };

  runApp(
    UncontrolledProviderScope(container: container, child: const AppStartup()),
  );
}
