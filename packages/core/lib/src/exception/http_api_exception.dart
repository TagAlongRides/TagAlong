import 'package:core/core.dart';

class HttpApiException implements Exception {
  final ErrorModel error;

  HttpApiException(this.error);
}
