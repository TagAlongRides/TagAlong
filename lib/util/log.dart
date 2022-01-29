import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:tagalong/data/globals.dart' as globals;

final log = Logger('TagAlongLogger');

Level stringToLogLevel(final String levelString) {
  final Map<String, Level> stringToLevelMap = {
    'off': Level.OFF,
    'shout': Level.SHOUT,
    'severe': Level.SEVERE,
    'warning': Level.WARNING,
    'info': Level.INFO,
    'config': Level.CONFIG,
    'fine': Level.FINE,
    'finer': Level.FINER,
    'finest': Level.FINEST,
    'all': Level.INFO, // Default ALL to INFO
    'debug': Level.FINE // Default DEBUG to FINE
  };

  if (!stringToLevelMap.containsKey(levelString.toLowerCase())) {
    log.warning(
        'Invalid log level provided: $levelString\nDefaulting to \'ALL\'');
    return Level.ALL;
  }

  return stringToLevelMap[levelString.toLowerCase()] ?? Level.ALL;
}

void setupLogger([final Level logLevel = globals.tagAlongLogLevel]) {
  Logger.root.level = logLevel;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

void setLogLevelString(final String logLevelString) {
  final Level logLevel = stringToLogLevel(logLevelString);
  Logger.root.level = logLevel;
}

void setLogLevel(final Level logLevel) {
  Logger.root.level = logLevel;
}
