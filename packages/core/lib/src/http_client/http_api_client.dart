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
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
      responseType: ResponseType.json,
    );

    _dio = Dio(baseOptions);

    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        // Every API route requires a Firebase ID token. Fetched per request
        // rather than cached, because they expire after an hour and the
        // provider hands back a refreshed one.
        final token = await _resolveToken();
        if (token != null && token.isNotEmpty) {
          options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
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

  }

  String? _token;

  /// Supplies a fresh Firebase ID token for each request.
  ///
  /// Set by the app at startup. Kept as a callback so this package doesn't
  /// have to depend on firebase_auth.
  Future<String?> Function()? tokenProvider;

  set token(String? token) => _token = token;

  /// Prefers the provider, falling back to a token set directly via [token].
  Future<String?> _resolveToken() async {
    if (tokenProvider != null) {
      try {
        return await tokenProvider!();
      } catch (error) {
        log('Could not obtain an auth token: $error');
        return null;
      }
    }
    return _token;
  }

  late Dio _dio;

  Dio call() => _dio;

  Future<dynamic> post(String path,
      {dynamic data, Map<String, String>? headers}) async {
    try {
      final response =
          await _dio.post(path, data: data, options: Options(headers: headers));
      return response.data;
    } on DioException catch (error) {
      _errorHandle(error);
    }
  }

  Future<dynamic> put(String path,
      {dynamic data, Map<String, String>? headers}) async {
    try {
      final response =
          await _dio.put(path, data: data, options: Options(headers: headers));
      return response.data;
    } on DioException catch (error) {
      _errorHandle(error);
    }
  }

  Future<dynamic> get(String path,
      {dynamic data, Map<String, String>? headers}) async {
    try {
      final response = await _dio.get(path,
          queryParameters: data, options: Options(headers: headers));
      return response.data;
    } on DioException catch (error) {
      _errorHandle(error);
    }
  }

  Future<dynamic> delete(String path,
      {dynamic data, Map<String, String>? headers}) async {
    try {
      final response = await _dio.delete(path,
          data: data, options: Options(headers: headers));
      return response.data;
    } on DioException catch (error) {
      _errorHandle(error);
    }
  }

  void _errorHandle(DioException error) {
    // The server answered and told us what went wrong - surface that.
    if (error.type == DioExceptionType.badResponse && error.response?.data != null) {
      throw HttpApiException(ErrorModel.fromJson(error.response!.data));
    }
    // Timeouts, cancellation, TLS and connection failures all read the same to
    // the user.
    throw Exception('Somthing Went Wrong, Please try again');
  }
}
