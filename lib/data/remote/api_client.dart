import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:tagalong/util/constants.dart';


class ApiClient {
  static bool apiDebuggin = true;
  static Dio? dio;

  static Dio getClient() {
    if (dio == null) {
      BaseOptions baseOptions = BaseOptions(
        baseUrl: Constants.BASE_URL,
        connectTimeout: 60000,
        receiveTimeout: 60000,
        responseType: ResponseType.json,
      );

      dio = Dio(baseOptions);
      dio!.interceptors.add(LogInterceptor(
          responseBody: true,
          requestBody: true,
          logPrint: (data) {
            log(data.toString());
          }));
    }

    return dio!;
  }
}
