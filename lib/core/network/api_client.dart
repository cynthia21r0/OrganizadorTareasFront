import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) {
          final friendlyMessage = buildFriendlyMessage(e);

          if (kDebugMode) {
            debugPrint(
              '[API ERROR] ${e.requestOptions.method} ${e.requestOptions.path} '
              '-> ${e.response?.statusCode}: $friendlyMessage',
            );
          }

          handler.reject(
            ApiException(
              friendlyMessage: friendlyMessage,
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
            ),
          );
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  static const String baseUrl =
      'https://organizadortareasback.onrender.com/api';

  late final Dio _dio;
  Dio get dio => _dio;

  String? token;
}