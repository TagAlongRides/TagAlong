import 'dart:developer';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';

class HttpApiClient {
  static HttpApiClient? _instance;

  static HttpApiClient get instance => _instance ??= HttpApiClient._internal();

  HttpApiClient._internal() {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl + apiVersion,
      connectTimeout: 15000,
      receiveTimeout: 15000,
      contentType: 'application/json',
      responseType: ResponseType.json,
    );

    _dio = Dio(baseOptions);

    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        //Pass auth header here
        if (_token != null && _token!.isNotEmpty) {
          options.headers[HttpHeaders.authorizationHeader] = 'Bearer $_token';
        }
        handler.next(options);
      },
    ));
    _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (logs) {
          log(logs as String);
        }));

    DioError;
  }

  String? _token;

  set token(String? token) => _token = token;

  late Dio _dio;

  Dio call() => _dio;

  Future<dynamic> post(String path,
      {dynamic data, Map<String, String>? headers}) async {
    try {
      final response =
          await _dio.post(path, data: data, options: Options(headers: headers));
      return response.data;
    } on DioError catch (error) {
      _errorHandle(error);
    }
  }

  Future<dynamic> put(String path,
      {dynamic data, Map<String, String>? headers}) async {
    try {
      final response =
          await _dio.put(path, data: data, options: Options(headers: headers));
      return response.data;
    } on DioError catch (error) {
      _errorHandle(error);
    }
  }

  Future<dynamic> get(String path,
      {dynamic data, Map<String, String>? headers}) async {
    try {
      final response = await _dio.get(path,
          queryParameters: data, options: Options(headers: headers));
      return response.data;
    } on DioError catch (error) {
      _errorHandle(error);
    }
  }

  void _errorHandle(DioError error) {
    switch (error.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.cancel:
      case DioErrorType.other:
        throw Exception('Somthing Went Wrong, Please try again');
      case DioErrorType.response:
        throw HttpApiException(ErrorModel.fromJson(error.response!.data));
    }
  }
}
