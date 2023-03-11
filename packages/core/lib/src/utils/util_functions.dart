import 'package:cloud_firestore/cloud_firestore.dart';

// Timestamp data can be received in two different formats - this function is used to handle both cases
// 1. Retrieving data from Firebase will return a Timestamp that can be directly converted to DateTime via toDate()
// 2. Retriving data from a cloud function will return a map with values for _seconds and _nanoseconds
DateTime convertToDateTime(dynamic timeValue) {
  if (timeValue is Timestamp) {
    return timeValue.toDate();
  }
  final timeFromSeconds = DateTime.fromMillisecondsSinceEpoch((timeValue['_seconds'] * 1000) as int);
  return timeFromSeconds;
}
