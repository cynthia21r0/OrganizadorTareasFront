import 'package:dio/dio.dart';

class ApiException extends DioException {
  final String friendlyMessage;

  ApiException({
    required this.friendlyMessage,
    required super.requestOptions,
    super.response,
    super.type,
  });

  @override
  String toString() => 'Exception: $friendlyMessage';
}

String buildFriendlyMessage(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Tiempo de espera agotado. Verifica tu conexión a internet.';
    case DioExceptionType.connectionError:
      return 'No se pudo conectar al servidor. Verifica tu conexión a internet.';
    case DioExceptionType.badCertificate:
      return 'Error de seguridad al conectar con el servidor.';
    case DioExceptionType.cancel:
      return 'La solicitud fue cancelada.';
    default:
      break;
  }

  final data = e.response?.data;
  if (data is Map && data['message'] != null) {
    final msg = data['message'];
    return msg is List ? msg.join(', ') : msg.toString();
  }

  switch (e.response?.statusCode) {
    case 400:
      return 'Datos inválidos. Revisa la información ingresada.';
    case 401:
      return 'Sesión inválida o expirada. Vuelve a iniciar sesión.';
    case 403:
      return 'No tienes permiso para realizar esta acción.';
    case 404:
      return 'No se encontró el recurso solicitado.';
    case 409:
      return 'Ya existe un registro con esos datos.';
    case 500:
    case 502:
    case 503:
      return 'El servidor no está disponible. Intenta más tarde.';
    default:
      return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}