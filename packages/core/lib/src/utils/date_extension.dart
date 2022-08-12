import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String format({String dateFormat = 'EEEE d MMMM'}) {
    return DateFormat(dateFormat).format(this);
  }
}
