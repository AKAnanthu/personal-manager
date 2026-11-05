import 'package:logger/logger.dart';

/// App-wide logger. Never pass record contents, passwords, ID numbers,
/// personal document file names or Google tokens to it.
final class AppLogger {
  AppLogger({required bool verbose})
    : _logger = Logger(
        level: verbose ? Level.debug : Level.warning,
        printer: SimplePrinter(colors: false),
      );

  final Logger _logger;

  void debug(String message) => _logger.d(message);
  void info(String message) => _logger.i(message);
  void warning(String message) => _logger.w(message);

  /// Only the error *type* and stack are logged; exception messages can embed
  /// user data (paths, values).
  void error(String message, Object error, [StackTrace? stackTrace]) =>
      _logger.e(message, error: error.runtimeType, stackTrace: stackTrace);
}
