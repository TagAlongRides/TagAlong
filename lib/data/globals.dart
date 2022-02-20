/// File for storing global variables
///  Note: this should not be used for storing shared state or other similar
///  types of information, but rather constants or un-changing values across
///  the entire application
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

const tagAlongLogLevel = Level.ALL;
