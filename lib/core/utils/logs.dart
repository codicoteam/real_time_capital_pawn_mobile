import 'package:logger/logger.dart';

class DevLogs {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.trace,
  );

  DevLogs(String s);

  static void logInfo(String msg) => _logger.i(msg);

  static void logSuccess(String msg) => _logger.i('✅ $msg');

  static void logWarning(String msg) => _logger.w(msg);

  static void logError(String msg) => _logger.e(msg);
}
