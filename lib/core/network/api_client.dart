import 'package:dio/dio.dart';

/// Cliente HTTP único para toda la app. Cambia [baseUrl] según dónde
/// corras el backend:
/// - Emulador Android -> http://10.0.2.2:3000/api
/// - Dispositivo físico en tu misma red Wi-Fi -> http://TU_IP_LOCAL:3000/api
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10)));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  static const String baseUrl = 'http://192.168.100.13:3000/api';

  late final Dio _dio;
  Dio get dio => _dio;

  // Token en memoria; se setea tras login y se limpia al cerrar sesión.
  String? token;
}